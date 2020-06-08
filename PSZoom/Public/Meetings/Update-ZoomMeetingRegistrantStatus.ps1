<#

.SYNOPSIS
Update a meeting registrant's status.
.DESCRIPTION
Update a meeting registrant's status.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
.LINK
.EXAMPLE
Update-ZoomMeetingRegistrantStatus  123456789


#>

function Update-ZoomMeetingRegistrantStatus {
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
            Mandatory = $True,    
            ValueFromPipelineByPropertyName = $True, 
            Position = 2
        )]
        [ValidateSet('approve', 'cancel', 'deny')]
        [string]$Action,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position = 3
        )]
        [hashtable[]]$Registrants,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    process {
        #Generate JWT (JSON Web Token) using the Api Key/Secret
        $Token = New-ZoomApiToken -ApiKey $ApiKey -ApiSecret $ApiSecret -ValidforSeconds 30

        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/registrants/status"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('OccurrenceId')) {
            $query.Add('occurrence_id', $OccurrenceId)
            $Request.Query = $query.toString()
        }
        
        $requestBody = @{
            'action' = $Action
        }

        if ($PSBoundParameters.ContainsKey('registrants')) {
            $requestBody.Add('registrants', ($Registrants))
        }

        $requestBody = $requestBody | ConvertTo-Json

        $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Body $requestBody -Method PUT -Token $Token
        Write-Output $response
    }
}