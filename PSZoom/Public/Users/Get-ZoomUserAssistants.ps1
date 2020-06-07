<#

.SYNOPSIS
List user assistants.

.DESCRIPTION
List user assistants.

.PARAMETER UserId
The user ID or email address.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.EXAMPLE
Get-ZoomUserAssistants jmcevoy@lawfirm.com

.OUTPUTS
A hastable with the Zoom API response.


#>

function Get-ZoomUserAssistants {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Email', 'EmailAddress', 'Id', 'user_id', 'userids', 'ids', 'emailaddresses', 'emails')]
        [string[]]$UserId,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate JWT (JSON Web Token) using the Api Key/Secret
        $Token = New-ZoomApiToken -ApiKey $ApiKey -ApiSecret $ApiSecret -ValidforSeconds 30
    }

    process {
        foreach ($id in $UserId) {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$Id/assistants"
            $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Method GET -Token $Token
            Write-Output $response
        }
    }
}