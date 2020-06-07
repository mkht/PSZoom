<#

.SYNOPSIS
List meetings for a user.
.DESCRIPTION
List meetings for a user.
.PARAMETER UserId
The user ID or email address.
.PARAMETER Type
Scheduled - All of the scheduled meetings.
Live - All of the live meetings.
Upcoming -  All of the upcoming meetings.
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
Get-ZoomMeetingsFromUser jsmith@lawfirm.com

#>


function Get-ZoomMeetingsFromUser {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Email', 'EmailAddress', 'Id', 'user_id')]
        [string]$UserId,

        [ValidateSet('scheduled', 'live', 'upcoming')]
        [string]$Type = 'live',
        
        [ValidateRange(1, 300)]
        [Alias('page_size')]
        [int]$PageSize = 30,

        [Alias('page_number')]
        [int]$PageNumber = 1,

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
        $request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId/meetings"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
        $query.add('type', $Type)
        $query.add('page_size', $PageSize)
        $query.add('page_number', $PageNumber)
        $request.Query = $query.ToString()
        
        $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Method GET -Token $Token
        Write-Output $response
    }
}