<#

.SYNOPSIS
Retrieve an active or inactive host report for a specified period of time. 

.DESCRIPTION
Retrieve an active or inactive host report for a specified period of time. 
The time range for the report is limited to a month and the month should fall under the past six months.

.PARAMETER Month

.PARAMETER Year

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.EXAMPLE
Get-ZoomDailyUsageReport -Year 2019 -Month 2

.OUTPUTS
A hashtable with the Zoom API response.

#>

function Get-ZoomDailyUsageReport {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [int]$Year,

        [Parameter( 
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [int]$Month,

        [string]$ApiKey,

        [string]$ApiSecret
    )

    begin {
        #Generate JWT (JSON Web Token) using the Api Key/Secret
        $Token = New-ZoomApiToken -ApiKey $ApiKey -ApiSecret $ApiSecret -ValidforSeconds 30
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/report/daily"

        if ($Year -or $Query) {
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
        }
        
        if ($Year) {
            $query.Add('year', $Year)
        }

        if ($Month) {
            $query.Add('month', $Month)
        }

        if ($query) {
            $Request.Query = $query.ToString()
        }

        $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Method GET -Token $Token
        Write-Output $response
    }
}