Import-Module Microsoft.Graph.Identity.SignIns

# Policy 1: Require MFA for all users
$mfaParams = @{
    displayName = "IAM Lab - Require MFA for all users"
    state       = "enabledForReportingButNotEnforced"
    conditions  = @{
        clientAppTypes = @("all")
        applications   = @{ includeApplications = @("All") }
        users          = @{ includeUsers = @("All") }
    }
    grantControls = @{
        operator        = "OR"
        builtInControls = @("mfa")
    }
}

New-MgIdentityConditionalAccessPolicy -BodyParameter $mfaParams
Write-Host "Created policy: Require MFA for all users (report-only)" -ForegroundColor Green

# Policy 2: Block legacy authentication
$legacyAuthParams = @{
    displayName = "IAM Lab - Block legacy authentication"
    state       = "enabledForReportingButNotEnforced"
    conditions  = @{
        clientAppTypes = @("exchangeActiveSync", "other")
        applications   = @{ includeApplications = @("All") }
        users          = @{ includeUsers = @("All") }
    }
    grantControls = @{
        operator        = "OR"
        builtInControls = @("block")
    }
}

New-MgIdentityConditionalAccessPolicy -BodyParameter $legacyAuthParams
Write-Host "Created policy: Block legacy authentication (report-only)" -ForegroundColor Green

Write-Host "`nBoth policies are in report-only mode. Check Entra ID > Monitoring > Sign-in logs for a few days, then flip 'state' to 'enabled' with Update-MgIdentityConditionalAccessPolicy once you're confident nobody gets locked out." -ForegroundColor Cyan
