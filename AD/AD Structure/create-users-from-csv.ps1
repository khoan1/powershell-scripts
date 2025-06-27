# create-users-from-csv.ps1
# This script will create users from imported CSV file

$csvPath = ".\new-users.csv"
$domainDN = (Get-ADDomain).DistinguishedName
$parentOU = "Staff"  # Change this if OUs are under a different parent

# Check if CSV file exists
if (!(Test-Path $csvPath)) {
    Write-Host "[X] CSV file not found at $csvPath" -ForegroundColor Red
    exit
}

# Import CSV
$importUsers = Import-Csv -Path $csvPath

foreach ($user in $importUsers) {
    $ouPath = "OU=$($user.Department),OU=$parentOU,$domainDN"
    $securePass = ConvertTo-SecureString $user.Password -AsPlainText -Force
    $userPrincipal = "$($user.Username)@$((Get-ADDomain).DNSRoot)"

    try {
        New-ADUser -Name "$($user.FirstName) $($user.LastName)" `
            -SamAccountName $user.Username `
            -UserPrincipalName $userPrincipal `
            -GivenName $user.FirstName `
            -Surname $user.LastName `
            -AccountPassword $securePass `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -Path $ouPath

        Write-Host "[O] Created user: $($user.Username)" -ForegroundColor Green
    }
    catch {
        Write-Host "[X] Failed to create user: $($user.Username) — $_" -ForegroundColor Red
    }
}
