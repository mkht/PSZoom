<#

.SYNOPSIS
Update a user's email.

.DESCRIPTION
Update a user's email.

.PARAMETER UserId
The user ID or email address.

.PARAMETER Email
User's email. The length should be less than 128 characters.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
No output. Can use PassThru switch to pass UserId to output.

.EXAMPLE
Update-ZoomUserEmail lskywalker@thejedi.com

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/useremailupdate

#>

function Update-ZoomUserEmail {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Id')]
        [string]$UserId,

        [Parameter(
            Mandatory = $True,
            Position = 1,
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateLength(0, 128)]
        [string]$Email,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret,

        [switch]$PassThru
    )

    process {
        #Generate JWT (JSON Web Token) using the Api Key/Secret
        $Token = New-ZoomApiToken -ApiKey $ApiKey -ApiSecret $ApiSecret -ValidforSeconds 30

        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId/email"

        $requestBody = @{
            'email' = $Email
        } 
        $requestBody = $requestBody | ConvertTo-Json

        try {
            Invoke-ZoomApiRestMethod -Uri $Request.Uri -Body $requestBody -Method PUT -Token $Token
        }
        catch {
            Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
        }
        finally {
            if ($PassThru) {
                Write-Output $UserId
            }
        }
    }
}