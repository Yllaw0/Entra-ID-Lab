Import-Module Microsoft.Graph.Reports
Import-Module Microsoft.Graph.Identity.Governance
Import-Module Microsoft.Graph.Groups

$reportDate = Get-Date -Format "yyyy-MM-dd"
$outputDir  = Join-Path $PSScriptRoot "../reports"
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

# 1. Recent sign-ins
$signIns = Get-MgAuditLogSignIn -Top 100 |
    Select-Object CreatedDateTime, UserPrincipalName, AppDisplayName,
                  @{N = 'Status'; E = { $_.Status.ErrorCode } },
                  @{N = 'City'; E = { $_.Location.City } },
                  @{N = 'Country'; E = { $_.Location.CountryOrRegion } },
                  IsInteractive

$signIns | Export-Csv -Path (Join-Path $outputDir "signins-$reportDate.csv") -NoTypeInformation

# 2. Current PIM-eligible role assignments
$eligible = Get-MgRoleManagementDirectoryRoleEligibilitySchedule -All -ExpandProperty "principal,roleDefinition"

$eligibleReport = $eligible | Select-Object `
    @{N = 'User'; E = { $_.Principal.AdditionalProperties.displayName } },
    @{N = 'Role'; E = { $_.RoleDefinition.DisplayName } },
    @{N = 'Status'; E = { $_.Status } },
    @{N = 'StartDateTime'; E = { $_.StartDateTime } }

$eligibleReport | Export-Csv -Path (Join-Path $outputDir "pim-eligibility-$reportDate.csv") -NoTypeInformation

# 3. Department group membership
$deptGroups = Get-MgGroup -Filter "startswith(displayName,'IAM-Lab-')" -All
$membershipReport = foreach ($g in $deptGroups) {
    Get-MgGroupMember -GroupId $g.Id -All | ForEach-Object {
        [PSCustomObject]@{
            Group = $g.DisplayName
            User  = $_.AdditionalProperties.displayName
            UPN   = $_.AdditionalProperties.userPrincipalName
        }
    }
}

$membershipReport | Export-Csv -Path (Join-Path $outputDir "group-membership-$reportDate.csv") -NoTypeInformation

Write-Host "Reports written to $outputDir :" -ForegroundColor Green
Write-Host " - signins-$reportDate.csv ($($signIns.Count) rows)"
Write-Host " - pim-eligibility-$reportDate.csv ($($eligibleReport.Count) rows)"
Write-Host " - group-membership-$reportDate.csv ($($membershipReport.Count) rows)"
