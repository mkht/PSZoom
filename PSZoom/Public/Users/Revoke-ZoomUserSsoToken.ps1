<#

.SYNOPSIS
Revoke a user’s SSO token.

.DESCRIPTION
Revoke a user’s SSO token.

.PARAMETER UserId
The user ID or email address.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
No output. Can use PassThru switch to pass UserId to output.

.EXAMPLE
Revoke-UserSsoToken jsmith@lawfirm.com

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userssotokendelete

#>

function Revoke-ZoomUserSsoToken {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Email', 'EmailAddress', 'Id', 'user_id')]
        [string[]]$UserId,
        
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret,

        [switch]$PassThru
    )

    begin {
        #Generate JWT (JSON Web Token) using the Api Key/Secret
        $Token = New-ZoomApiToken -ApiKey $ApiKey -ApiSecret $ApiSecret -ValidforSeconds 30
    }

    process {
        foreach ($user in $UserId) {
            $request = [System.UriBuilder]"https://api.zoom.us/v2/users/$user/token"
            
            $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Method DELETE -Token $Token
            if ($PassThru) {
                Write-Output $UserId
            }
            else {
                Write-Output $response
            }
        }
    }
}