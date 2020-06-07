<#

.SYNOPSIS
Retrieve the details of a meeting.

.DESCRIPTION
Retrieve the details of a meeting.

.PARAMETER MeetingId
The meeting ID.

.PARAMETER OcurrenceId
The Occurrence ID.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS

.LINK

.EXAMPLE
Get-ZoomMeeting 123456789

.EXAMPLE
Get the host of a Zoom meeting.
Get-ZoomMeeting 123456789 | Select-Object host_id | Get-ZoomUser

#>

function Get-ZoomMeeting {
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
        [Alias('ocurrence_id')]
        [string]$OccurrenceId,

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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('OccurrenceId')) {
            $query.Add('occurrence_id', $OccurrenceId)
            $Request.Query = $query.toString()
        }

        $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Method GET -Token $Token
        Write-Output $response
    }
}
