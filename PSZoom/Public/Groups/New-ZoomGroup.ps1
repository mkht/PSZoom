<#

.SYNOPSIS
Create a group under your account.

.DESCRIPTION
Create a group under your account.
Prerequisite: Pro, Business, or Education account

.PARAMETER Name
The group name.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
The Zoom response (an object)
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/groupcreate

.EXAMPLE
Create two groups.
New-ZoomGroup -name 'Light Side', 'Dark Side'
#>

function New-ZoomGroup {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [Alias('New-ZoomGroups')]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0
        )]
        [Alias('groupname', 'groupnames', 'names')]
        [string[]]$Name,

        [string]$ApiKey,
        
        [string]$ApiSecret,

        [switch]$PassThru
    )

    begin {
        #Generate JWT (JSON Web Token) using the Api Key/Secret
        $Token = New-ZoomApiToken -ApiKey $ApiKey -ApiSecret $ApiSecret -ValidforSeconds 30

        $Request = [System.UriBuilder]"https://api.zoom.us/v2/groups"
    }

    process {
        foreach ($n in $Name) {
            if ($PSCmdlet.ShouldProcess($n, 'New')) {
                $requestBody = @{
                    name = $n
                }

                $requestBody = $requestBody | ConvertTo-Json
                $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Body $requestBody -Method POST -Token $Token
                Write-Verbose "Creating group $n."
                Write-Output $response
            }
        }
    }
}