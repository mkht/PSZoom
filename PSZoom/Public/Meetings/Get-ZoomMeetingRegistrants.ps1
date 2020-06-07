<#

.SYNOPSIS
List registrants of a meeting.
.DESCRIPTION
List registrants of a meeting.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER OccurenceId
The meeting Occurrence ID.
.PARAMETER Status
The registrant status:
Pending - Registrant's status is pending.
Approved - Registrant's status is approved.
Denied - Registrant's status is denied.
.PARAMETER PageSize
The number of records returned within a single API call. Default value is 30. Maximum value is 300.
.PARAMETER PageNumber
The current page number of returned records. Default value is 1.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
.LINK
.EXAMPLE
Get-ZoomMeetingRegistrants 123456789

#>

function Get-ZoomMeetingRegistrants {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('meeting_id')]
        [string]$MeetingId,

        [ValidateSet('pending', 'approved', 'denied')]
        [string]$Status = 'approved',
        
        [ValidateRange(1, 300)]
        [Alias('page_size')]
        [int]$PageSize = 30,

        [Alias('page_number')]
        [int]$PageNumber = 1,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret

        #Need to add an all switch
    )

    begin {
        #Generate JWT (JSON Web Token) using the Api Key/Secret
        $Token = New-ZoomApiToken -ApiKey $ApiKey -ApiSecret $ApiSecret -ValidforSeconds 30
    }

    process {
        $request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/registrants"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
        $query.Add('status', $Status)
        $query.Add('page_size', $PageSize)
        $query.Add('page_number', $PageNumber)
        $request.Query = $query.ToString()

        $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Method GET -Token $Token
        Write-Output $response
    }
}