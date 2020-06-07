<#

.SYNOPSIS
Update a meeting's live stream.
.DESCRIPTION
Update a meeting's live stream.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
.LINK
.EXAMPLE
Update-ZoomMeetingLiveStream  123456789

22
#>

function Update-ZoomMeetingLiveStreamStatus {
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

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateLength(0, 1024)]
        [Alias('stream_url')]
        [string]$StreamUrl,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateLength(0, 512)]
        [Alias('stream_key')]
        [string]$StreamKey,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateLength(0, 1024)]
        [Alias('page_url')]
        [string]$PageUrl,

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
        $Uri = "https://api.zoom.us/v2/meetings/$MeetingId/livestream/status"
        $requestBody = @{ }

        if ($PSBoundParameters.ContainsKey('StreamUrl')) {
            $requestBody.Add('stream_url', $StreamUrl)
        }

        if ($PSBoundParameters.ContainsKey('StreamKey')) {
            $requestBody.Add('stream_key', $StreamKey)
        }

        if ($PSBoundParameters.ContainsKey('PageUrl')) {
            $requestBody.Add('page_url', $PageUrl)
        }
        
        $requestBody = $requestBody | ConvertTo-Json

        $response = Invoke-ZoomApiRestMethod -Uri $Uri -Body $requestBody -Method PATCH -Token $Token
        Write-Output $response
    }
}