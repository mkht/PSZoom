<#

.SYNOPSIS
Retrieve the details of a meeting.
.DESCRIPTION
Retrieve the details of a meeting.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER OcurrenceId
The Occurrence IDs.
.PARAMETER email
A valid email address of registrant.
.PARAMETER FirstName
User's first name.
.PARAMETER LastName
User's last name.
.PARAMETER Address
User's address.
.PARAMETER City
User's city.
.PARAMETER Country
User's country.
.PARAMETER Zip
User's zip.
.PARAMETER State
User's state.
.PARAMETER Phone
User's phone.
.PARAMETER Industry
User's industry.
.PARAMETER Org
User's organization.
.PARAMETER JobTitle
User's job title.
.PARAMETER PurchasingTimeFrame
Purchasing timeframe.
Within a month
1-3 months
4-6 months
more than 6 months
no timeframe
.PARAMETER RoleInPurchaseProcess
Role in purchase process.
Decision makeEvaluator/Recommender
Influencer
Not involved
.PARAMETER NoOfEmployees
Number of employees.
1-20 
21-50 
51-100 
101-500
500-1,000
1,001-5,000
5,001-10,000
More than 10,000
.PARAMETER Comments
The user's comments.
.PARAMETER CustomQuestions
The user's custom questions.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
.LINK
.EXAMPLE
Add-ZoomMeetingRegistrant 123456789 -email jsmith@lawfirm.com -firstname joe -lastname smith

#>

function Add-ZoomMeetingRegistrant {
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
        [Alias('')]
        [string]$OcurrenceId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Email,

        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('first_name')]
        [string]$FirstName,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('last_name')]
        [string]$LastName,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Address,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$City,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Country,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Zip,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$State,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Phone,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Industry,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Org,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('job_title')]
        [string]$JobTitle,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('Within a month', '1-3 months', '4-6 months', 'more than 6 months', 'no timeframe')]
        [Alias('purchasing_time_Frame')]
        [string]$PurchasingTimeFrame,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('Decision Maker', 'Evaluator/Recommender', 'Influencer', 'Not involved')]
        [Alias('role_in_purchase_process')]
        [string]$RoleInPurchaseProcess,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('1-20', '21-50', '51-100', '101-500', '500-1,000', '1,001-5,000', '5,001-10,000', 'More than 10,000')]
        [Alias('no_of_employees')]
        [string]$NoOfEmployees,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Comments,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('custom_questions')]
        [hashtable]$CustomQuestions,
        
        [string]$ApiKey,
        
        [string]$ApiSecret
    )

    process {
        #Generate JWT (JSON Web Token) using the Api Key/Secret
        $Token = New-ZoomApiToken -ApiKey $ApiKey -ApiSecret $ApiSecret -ValidforSeconds 30

        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/registrants"

        if ($PSBoundParameters.ContainsKey('OcurrenceIds')) {
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty) 
            $query.Add('occurrence_id', $OcurrenceId)
            $Request.Query = $query.toString()
        }

        $RequestParameters = @{
            'email'                    = 'email'
            'first_name'               = 'FirstName'
            'last_name'                = 'LastName'
            'address'                  = 'Address'
            'city'                     = 'City'
            'country'                  = 'Country'
            'zip'                      = 'Zip'
            'state'                    = 'State'
            'phone'                    = 'Phone'
            'industry'                 = 'Industry'
            'org'                      = 'Org'
            'job_title'                = 'JobTitle'
            'purchasing_time_frame'    = 'PurchasingTimeFrame'
            'role_in_purchase_process' = 'RoleInPurchaseProcess'
            'no_of_employees'          = 'NoOfEmployees'
            'comments'                 = 'Comments'
            'custom_questions'         = 'CustomQuestions'
        }

        function Remove-NonPSBoundParameters {
            param (
                $Obj,
                $Parameters = $PSBoundParameters
            )

            $NewObj = @{ }
    
            foreach ($Key in $Obj.Keys) {
                if ($Parameters.ContainsKey($Obj.$Key)) {
                    $NewObj.Add($Key, (get-variable $Obj.$Key).value)
                }
            }
    
            return $NewObj
        }

        $RequestParameters = Remove-NonPSBoundParameters($RequestParameters)
        $requestBody = @{ }

        $RequestParameters.Keys | ForEach-Object {
            $requestBody.Add($_, $RequestParameters.$_)
        }

        $requestBody = $requestBody | ConvertTo-Json
        try {
            $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Body $requestBody -Method POST -Token $Token
        }
        catch {
            Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
        }
        finally {
            Write-Output $response
        }        
    }
}