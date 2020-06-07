<#

.SYNOPSIS
Retrieve the meeting invitation
.DESCRIPTION
Retrieve the meeting invitation
.PARAMETER MeetingId
The meeting ID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
.LINK
.EXAMPLE
Get-ZoomMeetingInvitation 123456789

#>

function Get-ZoomMeetingInvitation {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('meeting_id')]
        [string]$MeetingId,

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
        $Uri = "https://api.zoom.us/v2/meetings/$MeetingId/invitation"
        $response = Invoke-ZoomApiRestMethod -Uri $Uri -Method GET -Token $Token
        Write-Output $response
    }
}
