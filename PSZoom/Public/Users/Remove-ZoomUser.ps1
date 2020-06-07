<#

.SYNOPSIS
Delete a user on your account.

.DESCRIPTION
Delete a user on your account.

.PARAMETER Action
Delete action options:
disassociate - Disassociate a user. This is the default.
delete - Permanently delete a user.
Note: To delete pending user in the account, use disassociate.

.PARAMETER TransferEmail
Transfer email.

.PARAMETER TransferMeeting
Transfer meeting.

.PARAMETER TransferWebinar
Transfer webinar.

.PARAMETER TransferRecording
Transfer recording.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
No output. Can use PassThru switch to pass UserId to output.

.EXAMPLE
Remove-ZoomUser 'sjackson@lawfirm.com' -action 'delete' -TransferEmail 'jsmith@lawfirm.com' -TransferMeeting

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userdelete

#>

function Remove-ZoomUser {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Medium')]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Email', 'id')]
        [string[]]$UserId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('disassociate', 'delete')]
        [string]$Action = 'disassociate',
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('transfer_email')]
        [string]$TransferEmail,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('transfer_meeting')]
        [switch]$TransferMeeting,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('transfer_webinar')]
        [switch]$TransferWebinar,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('transfer_recording')]
        [switch]$TransferRecording,

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
            $request = [System.UriBuilder]"https://api.zoom.us/v2/users/$user"
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
            $query.Add('action', $Action)

            if ($PSBoundParameters.ContainsKey('TransferEmail')) {
                $query.Add('transfer_email', $TransferEmail)
            }

            if ($PSBoundParameters.ContainsKey('TransferMeeting')) {
                $query.Add('transfer_meeting', $TransferMeeting)
            }

            if ($PSBoundParameters.ContainsKey('TransferWebinar')) {
                $query.Add('transfer_webinar', $TransferWebinar)
            }

            if ($PSBoundParameters.ContainsKey('TransferRecording')) {
                $query.Add('transfer_recording', $TransferRecording)
            }
            
            $request.Query = $query.ToString().ToLower()
            
            if ($PSCmdlet.ShouldProcess($user, 'Remove')) {
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
}