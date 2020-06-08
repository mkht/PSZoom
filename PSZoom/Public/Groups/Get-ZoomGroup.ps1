<#

.SYNOPSIS
Get a group under your account.
.DESCRIPTION
Get a group under your account.
Prerequisite: Pro, Business, or Education account
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
Zoom response as an object.
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/group
.EXAMPLE
Get-ZoomGroup 24e50639b5bb4fab9c3c

#>

function Get-ZoomGroup {
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True, 
            Position = 0
        )]
        [Alias('group_id', 'group', 'id')]
        [string]$GroupId,

        [string]$ApiKey,
        
        [string]$ApiSecret
    )

    process {
        #Generate JWT (JSON Web Token) using the Api Key/Secret
        $Token = New-ZoomApiToken -ApiKey $ApiKey -ApiSecret $ApiSecret -ValidforSeconds 30

        $Request = [System.UriBuilder]"https://api.zoom.us/v2/groups/$GroupId"
        $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Method GET -Token $Token
        Write-Output $response
    }
}