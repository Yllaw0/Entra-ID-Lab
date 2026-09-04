
$RequiredModules = @(
    'Microsoft.Graph.Authentication',
    'Microsoft.Graph.Users',
    'Microsoft.Graph.Groups',
    'Microsoft.Graph.Identity.SignIns',
    'Microsoft.Graph.Identity.Governance',
    'Microsoft.Graph.Applications',
    'Microsoft.Graph.Reports'
)

foreach ($module in $RequiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing $module..." -ForegroundColor Cyan
        Install-Module -Name $module -Scope CurrentUser -Force -AllowClobber
    }
    Import-Module $module
}

# Scopes needed across every script in this lab
$Scopes = @(
    'User.ReadWrite.All',
    'Group.ReadWrite.All',
    'Policy.ReadWrite.ConditionalAccess',
    'Policy.Read.All',
    'Application.ReadWrite.All',
    'AppRoleAssignment.ReadWrite.All',
    'RoleManagement.ReadWrite.Directory',
    'RoleEligibilitySchedule.ReadWrite.Directory',
    'AccessReview.ReadWrite.All',
    'AuditLog.Read.All',
    'Directory.Read.All'
)

Connect-MgGraph -Scopes $Scopes

$context = Get-MgContext
Write-Host "Connected to tenant: $($context.TenantId) as $($context.Account)" -ForegroundColor Green
Write-Host "Granted scopes: $($context.Scopes -join ', ')" -ForegroundColor Gray
