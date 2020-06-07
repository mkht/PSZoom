<#

.SYNOPSIS
Delete a meeting.
.DESCRIPTION
Delete a meeting.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER OccurrenceId
The Occurrence ID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
.LINK
.EXAMPLE
Remove-ZoomMeeting 123456789

#>

function Remove-ZoomMeeting {
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
        [Alias('occurrence_id')]
        [string]$OccurrenceId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position = 1
        )]
        [Alias('schedule_for_reminder')]
        [string]$ScheduleForReminder,

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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId"

        if ($PSBoundParameters.ContainsKey('OccurrenceId') -or $PSBoundParameters.ContainsKey('ScheduleForReminder')) {
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
            
            if ($PSBoundParameters.ContainsKey('OccurrenceId')) {
                $query.Add('occurrence_id', $OccurrenceId)
            }  

            if ($PSBoundParameters.ContainsKey('ScheduleForReminder')) {
                $query.Add('schedule_for_reminder', $ScheduleForReminder)
            }

            $Request.Query = $query.ToString()
        }

        $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Method DELETE -Token $Token

        if (-not $PassThru) {
            Write-Output $response
        }
        else {
            Write-Output $PassThru
        }
    }
}