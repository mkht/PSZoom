<#

.SYNOPSIS
End a meeting by updating its status.
.DESCRIPTION
End a meeting by updating its status.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER Action
The update action. Available actions: end.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/meetings/meetingstatus
.EXAMPLE
Ends a meeting.
Update-MeetingStatus -MeetingId '123456789'

#>

function Update-ZoomMeetingStatus {
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

        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position = 1
        )]
        [ValidateSet('end')]
        [string]$Action = 'end',

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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/status"

        $requestBody = @{
            'action' = $Action
        }

        $requestBody = $requestBody | ConvertTo-Json

        $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Body $requestBody -Method PUT -Token $Token
        Write-Output $response
    }
}