# Microsoft Entra ID - IAM Home Lab

Identity and access management lab for a simulated ~12-person company across
three departments (IT, Finance, Sales), built and automated entirely with the
Microsoft Graph PowerShell SDK.

## What this demonstrates

- Least-privilege role assignment and PIM-based just-in-time admin access
- Conditional Access policies enforcing MFA and blocking legacy authentication
- Recurring access reviews for periodic recertification of group membership
- Group-based application access instead of per-user assignment
- Bulk identity operations and reporting done through scripted automation

## Setup

1. Edit `scripts/Config.ps1` and set `$TenantDomain` to the tenant's default
   domain.
2. Open PowerShell in the `scripts` folder and run the scripts **in order**:

   ```powershell
   ./00-Connect-Graph.ps1          # installs modules, connects, once per session
   ./01-New-LabUsersAndGroups.ps1  # 12 users, 3 department groups
   ./02-New-ConditionalAccessPolicies.ps1
   ./03-Enable-PIMEligibility.ps1  # requires P2
   ./04-New-AccessReview.ps1       # requires P2
   ./05-New-TestAppRegistration.ps1
   ./06-Get-IAMReport.ps1          # exports CSVs to ../reports
   ```

3. Each script is idempotent-ish (checks for existing users/groups before
   creating), so it's safe to re-run `01` if it's interrupted partway through.

> Graph SDK cmdlet names occasionally shift between module versions. If a
> command isn't found, run `Find-MgGraphCommand -Command <partial-name>` to
> locate the current name for your installed version.

## Environment Setup

Screenshots from an actual run against a live Entra tenant, in order:

**1. Tenant domain confirmed**
![Tenant domain](screenshots/01-tenant-domain-confirmed.png)
`Get-MgDomain` confirming the tenant's default domain before running any provisioning scripts.

**2. Users and department groups created**
![Users and groups](screenshots/02-users-and-groups-created.png)
`01-New-LabUsersAndGroups.ps1` bulk-creating 3 department groups and 12 users from a CSV.

Confirmed in the portal:
![Portal users list](screenshots/08-portal-users-list.png)
![Portal groups list](screenshots/09-portal-groups-list.png)

**3. Conditional Access policies created**
![Conditional Access](screenshots/03-conditional-access-policies-created.png)
`02-New-ConditionalAccessPolicies.ps1` creating the MFA-enforcement and legacy-auth-block policies in report-only mode.

Confirmed in the portal:
![Portal Conditional Access policies](screenshots/10-portal-conditional-access-policies.png)

**4. PIM eligibility assigned**
![PIM eligibility](screenshots/04-pim-eligibility-assigned.png)
`03-Enable-PIMEligibility.ps1` granting just-in-time role eligibility instead of standing admin access.

**5. Access review created**
![Access review](screenshots/05-access-review-created.png)
`04-New-AccessReview.ps1` setting up a recurring quarterly recertification of the IT group's membership.

Confirmed in the portal:
![Portal access reviews](screenshots/11-portal-access-reviews.png)

**6. Test app registered and assigned**
![Test app](screenshots/06-test-app-registered.png)
`05-New-TestAppRegistration.ps1` registering a test app and restricting sign-in to the Sales group only.

Confirmed in the portal:
![Portal enterprise applications](screenshots/12-portal-enterprise-applications.png)

**7. Reports generated**
![IAM report](screenshots/07-iam-report-generated.png)
`06-Get-IAMReport.ps1` exporting sign-in, PIM eligibility, and group membership data to CSV.

