
. "$PSScriptRoot/Config.ps1"

$csvPath = Join-Path $PSScriptRoot "../data/lab-users.csv"
$users   = Import-Csv -Path $csvPath

# Create one security group per department first
$departments = $users.Department | Select-Object -Unique
$groupIds    = @{}

foreach ($dept in $departments) {
    $groupName = "IAM-Lab-$dept"
    $existing  = Get-MgGroup -Filter "displayName eq '$groupName'"

    if ($existing) {
        Write-Host "Group '$groupName' already exists, skipping." -ForegroundColor Yellow
        $groupIds[$dept] = $existing.Id
        continue
    }

    $group = New-MgGroup -DisplayName $groupName `
        -MailEnabled:$false `
        -MailNickname ($groupName -replace '\s', '') `
        -SecurityEnabled:$true `
        -Description "IAM lab department group: $dept"

    $groupIds[$dept] = $group.Id
    Write-Host "Created group: $groupName" -ForegroundColor Green
}

# Create each user and add them to their department group
foreach ($u in $users) {
    $upn = "$($u.MailNickname)@$TenantDomain"
    $existingUser = Get-MgUser -Filter "userPrincipalName eq '$upn'" -ErrorAction SilentlyContinue

    if ($existingUser) {
        Write-Host "User '$upn' already exists, skipping." -ForegroundColor Yellow
        $userId = $existingUser.Id
    }
    else {
        # Random 16-char temp password; user must change it at first sign-in
        $tempPassword = -join ((48..57) + (65..90) + (97..122) + (33, 35, 36, 37) |
            Get-Random -Count 16 | ForEach-Object { [char]$_ })

        $passwordProfile = @{
            Password                      = $tempPassword
            ForceChangePasswordNextSignIn = $true
        }

        $newUser = New-MgUser -DisplayName $u.DisplayName `
            -UserPrincipalName $upn `
            -MailNickname $u.MailNickname `
            -AccountEnabled:$true `
            -PasswordProfile $passwordProfile `
            -JobTitle $u.JobTitle `
            -Department $u.Department

        $userId = $newUser.Id
        Write-Host "Created user: $($u.DisplayName) <$upn>" -ForegroundColor Green
    }

    New-MgGroupMember -GroupId $groupIds[$u.Department] -DirectoryObjectId $userId -ErrorAction SilentlyContinue
}

Write-Host "`nDone: $($users.Count) users across $($departments.Count) department groups." -ForegroundColor Cyan
