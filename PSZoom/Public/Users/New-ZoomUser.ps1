<#
.SYNOPSIS
Create a user using your account.

.PARAMETER Action
Specify how to create the new user:
create - User will get an email sent from Zoom. There is a confirmation link in this email. The user will then need to use the link to activate their Zoom account. 
The user can then set or change their password.
autoCreate - This action is provided for the enterprise customer who has a managed domain. This feature is 
disabled by default because of the security risk involved in creating a user who does not belong to your domain.
custCreate - This action is provided for API partners only. A user created in this way has no password and 
is not able to log into the Zoom web site or client.
ssoCreate - This action is provided for the enabled “Pre-provisioning SSO User” option. A user created in 
this way has no password. If not a basic user, a personal vanity URL using the user name (no domain) of 
the provisioning email will be generated. If the user name or PMI is invalid or occupied, it will use a random 
number or random personal vanity URL.
.PARAMETER Email
User email address.

.PARAMETER Type
Basic (1)
Pro (2)
Corp (3)

.PARAMETER FirstName
User's first name: cannot contain more than 5 Chinese words.

.PARAMETER LastName
User's last name: cannot contain more than 5 Chinese words.

.PARAMETER PASSWORD
User password. Only used for the "autoCreate" function. The password has to have a minimum of 8 characters and maximum of 32 characters. 
It must have at least one letter (a, b, c..), at least one number (1, 2, 3...) and include both uppercase and lowercase letters. 
It should not contain only one identical character repeatedly ('11111111' or 'aaaaaaaa') and it cannot contain consecutive characters ('12345678' or 'abcdefgh').

.PARAMETER ApiKey
The API key.

.PARAMETER ApiSecret
THe API secret.

.OUTPUTS
An object with the Zoom API response. 

.EXAMPLE
New-ZoomUser -Action ssoCreate -Email jsmith@lawfirm.com -Type Pro -FirstName Joseph -LastName Smith -ApiKey $ApiKey -ApiSecret $ApiSecret

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/usercreate

#>

function New-ZoomUser {    
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateLength(1, 128)]
        [Alias('EmailAddress', 'UserId', 'User_Id', 'Id', 'Identity')]
        [string]$Email,
        
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True        
        )]
        [ValidateSet('create', 'autoCreate', 'custCreate', 'ssoCreate')]
        [string]$Action,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateSet('Basic', 'Pro', 'Corp', 1, 2, 3)]
        $Type,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateLength(1, 64)]
        [Alias('first_name')]
        [string]$FirstName,

        [Parameter(ValueFromPipelineByPropertyName = $True)]        
        [ValidateLength(1, 64)]
        [Alias('last_name')]
        [string]$LastName,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Password,
        
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
        $request = [System.UriBuilder]'https://api.zoom.us/v2/users'

        #Request Body
        $requestBody = @{
            'action' = $Action
        }

        $Type = switch ($Type) {
            'Basic' { 1 }
            'Pro' { 2 }
            'Corp' { 3 }
            Default { $Type }
        }

        #These parameters are mandatory and are added automatically.
        $UserInfo = @{
            'email' = $Email
            'type'  = $Type
        }

        #These parameters are optional.
        $userInfoKeyValues = @{
            'first_name' = 'FirstName'
            'last_name'  = 'LastName'
            'password'   = 'Password'
        }

        function Remove-NonPSBoundParameters {
            param (
                $Obj,
                $Parameters = $PSBoundParameters
            )

            process {
                $newObj = @{ }
        
                foreach ($Key in $Obj.Keys) {
                    if ($Parameters.ContainsKey($Obj.$Key)) {
                        $newobj.Add($Key, (get-variable $Obj.$Key).value)
                    }
                }
        
                return $newObj
            }
        }

        #Determines if optional parameters were provided in the function call.
        $userInfoKeyValues = Remove-NonPSBoundParameters($userInfoKeyValues)

        #Adds parameters to UserInfo object.
        $userInfoKeyValues.Keys | ForEach-Object {
            $UserInfo.Add($_, $userInfoKeyValues.$_)
        }

        $requestBody.add('user_info', $UserInfo)

        $requestBody = $requestBody | ConvertTo-Json

        if ($PSCmdlet.ShouldProcess) {
            $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Body $requestBody -Method POST -Token $Token

            if ($PassThru) {
                Write-Output $Email
            }
            else {
                Write-Output $response
            }
        }
    }
}