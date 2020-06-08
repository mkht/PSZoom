<#

.SYNOPSIS
Update a user's status.
.DESCRIPTION
Update a user's status.
.PARAMETER UserId
The user ID or email address.
.PARAMETER Action
The action types:
Activate - Set user status to active.
Deactivate - Set user status to inactive.
.PARAMETER ApiKey
The API key.
.PARAMETER ApiSecret
THe API secret.
.OUTPUTS
No output. Can use PassThru switch to pass the UserId as an output.
.EXAMPLE`
Update-ZoomUserStatus -UserId helpdesk@lawfirm.com
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userstatus

#>

function Update-ZoomUserStatus {    
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Medium')]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('Email', 'Emails', 'EmailAddress', 'EmailAddresses', 'Id', 'ids', 'user_id', 'user', 'users', 'userids')]
        [string[]]$UserId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [ValidateSet('activate', 'deactivate')]
        [string]$Action,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,
        
        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret,

        [switch]$PassThru
    )
    
    process {
        foreach ($user in $UserId) {
            #Generate JWT (JSON Web Token) using the Api Key/Secret
            $Token = New-ZoomApiToken -ApiKey $ApiKey -ApiSecret $ApiSecret -ValidforSeconds 30

            $request = [System.UriBuilder]"https://api.zoom.us/v2/users/$user/status"
            $requestBody = @{
                'action' = $Action.ToLower()
            }
    
            $requestBody = $requestBody | ConvertTo-Json
    
            if ($PSCmdlet.ShouldProcess($user, $Action)) {
                $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Body $requestBody -Method PUT -Token $Token

                if ($PassThru) {
                    Write-Output $UserId
                }
                else {
                    Write-Output $response
                }
            }
        }
    }
}