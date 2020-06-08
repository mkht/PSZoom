<#

.SYNOPSIS
Delete a specific scheduler.

.DESCRIPTION
Delete a specific scheduler. Schedulers are the users to whom the current user has assigned  on the user's behalf.

.PARAMETER UserId
The user ID or email address.

.PARAMETER SchedulerId
The scheduler ID or email address.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
No output. Can use PassThru switch to pass UserId to output.

.EXAMPLE
Remove-ZoomSpecificUsersScheduler jmcevoy@lawfirm.com

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userschedulerdelete

#>

function Remove-ZoomSpecificUserScheduler {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Email', 'EmailAddress', 'Id', 'user_id')]
        [string[]]$UserId,

        [Parameter(
            Mandatory = $True, 
            Position = 1,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('scheduler_id')]
        [string[]]$SchedulerId,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret,

        [switch]$PassThru
    )

    process {
        foreach ($user in $UserId) {
            foreach ($scheduler in $schedulerId) {
                #Generate JWT (JSON Web Token) using the Api Key/Secret
                $Token = New-ZoomApiToken -ApiKey $ApiKey -ApiSecret $ApiSecret -ValidforSeconds 30

                if ($PSCmdlet.ShouldProcess($user, "Remove $scheduler")) {
                    $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$user/schedulers/$scheduler"

                    try {
                        Invoke-ZoomApiRestMethod -Uri $Request.Uri -Method DELETE -Token $Token
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
        }
    }
}