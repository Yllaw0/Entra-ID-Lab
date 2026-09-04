. "$PSScriptRoot/Config.ps1"
Import-Module Microsoft.Graph.Identity.Governance

# Map: user mail nickname -> role they should be ELIGIBLE for
$eligibilityMap = @{
    "sokafor" = "User Administrator"      # IT Manager
    "jrivera" = "Helpdesk Administrator"  # IT Support Specialist
}

foreach ($nickname in $eligibilityMap.Keys) {
    $roleName = $eligibilityMap[$nickname]
    $upn      = "$nickname@$TenantDomain"

    $user = Get-MgUser -Filter "userPrincipalName eq '$upn'"
    $role = Get-MgRoleManagementDirectoryRoleDefinition -Filter "displayName eq '$roleName'"

    if (-not $user -or -not $role) {
        Write-Warning "Could not resolve user '$upn' or role '$roleName' - skipping. (If this cmdlet errors, run 'Find-MgGraphCommand RoleDefinition' to check the current cmdlet name for your SDK version.)"
        continue
    }

    $params = @{
        action           = "adminAssign"
        justification    = "IAM lab: baseline PIM-eligible assignment for $roleName"
        roleDefinitionId = $role.Id
        directoryScopeId = "/"
        principalId      = $user.Id
        scheduleInfo     = @{
            startDateTime = (Get-Date).ToUniversalTime().ToString("o")
            expiration    = @{ type = "noExpiration" }
        }
    }

    New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $params
    Write-Host "Made $($user.DisplayName) ELIGIBLE for '$roleName' (not active - must be activated when needed)" -ForegroundColor Green
}

Write-Host "`nThese users can now activate their role from 'My Access' / PIM in the portal, with justification and a time limit, instead of holding it permanently." -ForegroundColor Cyan
