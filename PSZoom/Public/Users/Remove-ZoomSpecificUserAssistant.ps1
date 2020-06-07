<#

.SYNOPSIS
Delete a specific assistant.

.DESCRIPTION
Delete a specific assistant. Assistants are the users to whom the current user has assigned  on the user's behalf.

.PARAMETER UserId
The user ID or email address.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
A hashtable with the Zoom API response.

.EXAMPLE
Remove-ZoomSpecificUserAssistant jmcevoy@lawfirm.com

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userassistantdelete

#>

function Remove-ZoomSpecificUserAssistant {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Email', 'EmailAddress', 'Id', 'user_id')]
        [string[]]$UserId,

        [Parameter(
            Mandatory = $True, 
            Position = 1,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('assistant_id')]
        [string[]]$AssistantId,

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
        foreach ($id in $UserId) {
            foreach ($aid in $AssistantId) {
                $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$id/assistants/$aid"
                $response = Invoke-ZoomApiRestMethod -Uri $Request.Uri -Method DELETE -Token $Token
                Write-Output $response
            }
        }
    }
}