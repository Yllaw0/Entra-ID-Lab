<#
.SYNOPSIS
    Creates a recurring access review on one of the lab's department groups, so a
    reviewer has to periodically recertify who still belongs in it.
.NOTES
    Requires Entra ID P2. Run 00-Connect-Graph.ps1 first.
#>

. "$PSScriptRoot/Config.ps1"
Import-Module Microsoft.Graph.Identity.Governance

$groupName   = "IAM-Lab-IT"
$reviewerUpn = "sokafor@$TenantDomain"   # IT Manager reviews the IT group

$group    = Get-MgGroup -Filter "displayName eq '$groupName'"
$reviewer = Get-MgUser -Filter "userPrincipalName eq '$reviewerUpn'"

$params = @{
    displayName             = "IAM Lab - Quarterly review of $groupName"
    descriptionForAdmins    = "Recurring access review for the $groupName department group"
    descriptionForReviewers = "Please confirm each member still needs access to this group."
    scope = @{
        "@odata.type" = "#microsoft.graph.accessReviewQueryScope"
        query         = "/groups/$($group.Id)/transitiveMembers"
        queryType     = "MicrosoftGraph"
    }
    reviewers = @(
        @{ query = "/users/$($reviewer.Id)"; queryType = "MicrosoftGraph" }
    )
    settings = @{
        mailNotificationsEnabled        = $true
        reminderNotificationsEnabled    = $true
        justificationRequiredOnApproval = $true
        defaultDecisionEnabled          = $false
        instanceDurationInDays          = 7
        recommendationsEnabled          = $true
        recurrence = @{
            pattern = @{ type = "absoluteMonthly"; interval = 3 }
            range   = @{ type = "noEnd"; startDate = (Get-Date).ToString("yyyy-MM-dd") }
        }
    }
}

New-MgIdentityGovernanceAccessReviewDefinition -BodyParameter $params
Write-Host "Created quarterly access review on '$groupName', reviewed by $($reviewer.DisplayName)." -ForegroundColor Green
