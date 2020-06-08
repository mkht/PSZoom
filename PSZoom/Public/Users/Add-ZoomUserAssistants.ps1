<#

.SYNOPSIS
Add assistants to user(s).

.DESCRIPTION
Add assistants to user(s). Assistants are the users to whom the current user has assigned scheduling privilege on the user's behalf.

.PARAMETER UserId
The user ID or email address.

.PARAMETER AssistantId
The ID of the assistant. If using an assistant's ID, an email is not needed.

.PARAMETER AssistantEmail
The email of the assistant. If using an assistant's Email, an id is not needed.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.EXAMPLE
Add an assistant to a user.
Add-ZoomUserAssistants -UserId 'dsidious@thesith.com' -AssistantEmail 'dmaul@thesith.com'

.EXAMPLE
Add assistants to a user.
Add-ZoomUserAssistants -UserId  'okenobi@thejedi.com' -AssistantId '123456789','987654321'

.EXAMPLE
Add assistant to multiple users.
Add-ZoomUserAssistants -UserId  'okenobi@thejedi.com', 'dsidious@thesith.com' -AssistantId 'dvader@thesith.com',

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userassistantcreate

.OUTPUTS
A hashtable with the Zoom API response.

#>

function Add-ZoomUserAssistants {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Email', 'EmailAddress', 'ID', 'user_id', 'UserIds', 'Emails', 'IDs')]
        [string[]]$UserId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('assistantemails')]
        [string[]]$AssistantEmail,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('assistantids')]
        [string[]]$AssistantId,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret,

        [switch]$PassThru
    )

    process {
        foreach ($Id in $UserId) {
            #Generate JWT (JSON Web Token) using the Api Key/Secret
            $Token = New-ZoomApiToken -ApiKey $ApiKey -ApiSecret $ApiSecret -ValidforSeconds 30

            $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$Id/assistants"

            $assistants = @()
    
            foreach ($email in $AssistantEmail) {
                $assistants += @{'email' = $email }
            }
    
            foreach ($id in $AssistantId) {
                $assistants += @{'id' = $id }
            }
    
            $RequestBody = @{
                'assistants' = $assistants
            }
            
            $RequestBody = $RequestBody | ConvertTo-Json
            $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Body $RequestBody -Method POST -Token $Token
            
            if ($PassThru) {
                Write-Output $UserId
            }
            else {
                Write-Output $response
            }
        }
    }
}
