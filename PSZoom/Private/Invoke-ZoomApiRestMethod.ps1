<#

.SYNOPSIS
Invoke REST API request for Zoom API.
.EXAMPLE
Invoke-ZoomApiRestMethod -Uri 'https://api.zoom.us/v2/users/foo@example.com' -Method GET -ApiKey $ApiKey -ApiSecret $ApiSecret
.OUTPUTS
Generic dictionary.

#>

function Invoke-ZoomApiRestMethod {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'ApiKey')]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Token')]
        [System.Uri]$Uri,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [HashTable]$Query,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        $Body,

        [Parameter()]
        [ValidateSet('POST', 'GET', 'PUT', 'PATCH', 'DELETE')]
        [string]$Method = 'GET',

        [Parameter(Mandatory = $true, ParameterSetName = 'ApiKey')]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [Parameter(Mandatory = $true, ParameterSetName = 'ApiKey')]
        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret,

        [Parameter(Mandatory = $true, ParameterSetName = 'Token')]
        [ValidateNotNullOrEmpty()]
        [string]$Token
    )

    begin {
        switch ($PScmdlet.ParameterSetName) {
            'ApiKey' { 
                #Get Zoom Api Credentials
                $Credentials = Get-ZoomApiCredentials -ZoomApiKey $ApiKey -ZoomApiSecret $ApiSecret
                $ApiKey = $Credentials.ApiKey
                $ApiSecret = $Credentials.ApiSecret

                #Generate Header with JWT (JSON Web Token)
                $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
                break
            }

            'Token' {
                #Generate Header with Access Token
                $Headers = New-ZoomHeaders -Token $Token
            }

            Default { return }
        }
    }

    process {
        $Request = [System.UriBuilder]$Uri
        
        if ($PSBoundParameters.ContainsKey('Query')) {
            $parsedQuery = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
            foreach ($key in $Query.Keys) {
                $parsedQuery.Add($key, $Query[$key])
            }
            $Request.Query = $parsedQuery.ToString()
        }

        $invokeParams = @{
            Headers = $Headers
            Method  = $Method
            Uri     = $Request.Uri
        }

        if ($PSBoundParameters.ContainsKey('Body')) {
            $invokeParams.Add('Body', $Body)
        }

        if ($PScmdlet.ShouldProcess) {
            try {
                $Response = Invoke-RestMethod @invokeParams -UseBasicParsing
            }
            catch {
                Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
            }
            finally {
                Write-Output $Response
            }
        }
    }
    
    end { }
}