<#

.SYNOPSIS
Check if the user's personal meeting room name exists.

.DESCRIPTION
Check if the user's personal meeting room name exists.

.PARAMETER VanityName
Personal meeting room name.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Get-ZoomPersonalMeetingRoomName 'Joes Room'

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/uservanityname


#>

function Get-ZoomPersonalMeetingRoomName {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('vanity_name', 'vanitynames')]
        [string[]]$VanityName,

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
        foreach ($name in $VanityName) {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/vanity_name"
    
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
            $query.Add('vanity_name', $VanityName)
            $Request.Query = $query.ToString()

            $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Method GET -Token $Token
            Write-Output $response
        }
    }
}