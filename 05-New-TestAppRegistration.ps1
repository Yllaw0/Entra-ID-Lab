<#
.SYNOPSIS
    Registers a test application (simulating SSO to a SaaS app), then assigns the
    Sales department group as its only authorized users - access driven by group
    membership instead of assigning individuals one at a time.
.NOTES
    Run 00-Connect-Graph.ps1 first.
#>

. "$PSScriptRoot/Config.ps1"
Import-Module Microsoft.Graph.Applications

$groupName = "IAM-Lab-Sales"

# Register the app and its service principal (the "Enterprise Application")
$app = New-MgApplication -DisplayName "IAM Lab - Test SaaS App" -SignInAudience "AzureADMyOrg"
$sp  = New-MgServicePrincipal -AppId $app.AppId

Write-Host "Registered app '$($app.DisplayName)' (AppId: $($app.AppId))" -ForegroundColor Green

# Require assignment, so only explicitly assigned users/groups can sign in
Update-MgServicePrincipal -ServicePrincipalId $sp.Id -AppRoleAssignmentRequired:$true

$group = Get-MgGroup -Filter "displayName eq '$groupName'"

$assignmentParams = @{
    principalId = $group.Id
    resourceId  = $sp.Id
    appRoleId   = "00000000-0000-0000-0000-000000000000"  # default "User" access role
}

New-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $sp.Id -BodyParameter $assignmentParams

Write-Host "Assigned group '$groupName' to the app - only its members can sign in now." -ForegroundColor Green
Write-Host "`nAppId to reference later: $($app.AppId)" -ForegroundColor Cyan
