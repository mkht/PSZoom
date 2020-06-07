<#

.SYNOPSIS
Updates a Zoom meeting poll.
.DESCRIPTION
Updates a Zoom meeting poll.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER Title
Poll title.
.PARAMETER Questions
Array of questions. Requires three values:
[string]name - Question name
[string]type - Question type
    single - Single choice
    multiple - Multiple choice

Example:
    $Questions = @(
        @('Favorite number?', 'multiple', @('1', '2', '3')), @('Favorite letter?', 'multiple', @('a', 'b', 'c'))
    )
Can also pass New-ZoomMeetingPollQuestion as an array. Example:
$Questions = @(
    (New-ZoomMeetingPollQuestion -Name 'Favorite Number?' -type 'multiple' -answers '1,2,3'), 
    (New-ZoomMeetingPollQuestion -Name 'Favorite letter??' -type 'multiple' -answers 'a,b,c))
)
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
.LINK
.EXAMPLE
$Questions = @(
    @('Favorite number?', 'multiple', @('1', '2', '3')), @('Favorite letter?', 'multiple', @('a', 'b', 'c'))
)

Update-ZoomMeetingPoll 123456789 -Title 'Favorite numbers and letters' -Questions $Questions


#>

function Update-ZoomMeetingPoll {
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
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('poll_id')]
        [string]$PollId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Title,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [hashtable[]]$Questions,
        
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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/polls/$PollId"
        $requestBody = @{ }

        if ($PSBoundParameters.ContainsKey('Title')) {
            $requestBody.Add('title', $Title)
        }        
        
        if ($PSBoundParameters.ContainsKey('Questions')) {
            $requestBody.Add('questions', $Questions)
        }

        $requestBody = ConvertTo-Json $requestBody -Depth 10 #Uses -Depth because the questions.answers array is flattened without it.

        $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Body $requestBody -Method PUT -Token $Token
        Write-Output $response
    }
}

<#
function New-ZoomMeetingPollQuestion {
    param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [string]$Name,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('single', 'multiple')]
        [string]$Type,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [Alias('answer')]
        [string[]]$Answers
    )
    process {
        $Question = @(
            $Name, $Type, $Answers
        )

        return $Question
    }
    
}
#>