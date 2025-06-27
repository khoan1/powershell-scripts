# create-ou-structure.ps1
# This script will create a organizational unit (OU) structure based on input prompt

# Prompt for the parent OU name
$parentOU = Read-Host "Enter the name of the parent OU (e.g., Staff)"

# Prompt for sub-OUs, comma-separated for each entry
$subOUsInput = Read-Host "Enter the names of sub-OUs to create (comma-separated)"
$subOUs = $subOUsInput -split "," | ForEach-Object { $_.Trim() }   # each entry extra spacing will be omitted

# Build DN (DistinguishedName) for parent OU
$domainDN = (Get-ADDomain).DistinguishedName    # will get current domain DN (e.g., "DC=hospital,DC=local")
$parentOUDN = "OU=$parentOU,$domainDN"          # (e.g., "OU=Staff,DC=hospital,DC=local")

# Create parent OU if it doesn't exist
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$parentOU'" -SearchBase $domainDN -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name $parentOU -Path $domainDN
    Write-Host "[O] Created parent OU: $parentOU" -ForegroundColor Green
} else {
    Write-Host "[!] Parent OU '$parentOU' already exists." -ForegroundColor Yellow
}

# Create each sub-OU under the parent OU
foreach ($ou in $subOUs) {
    $ouPath = "OU=$ou,$parentOUDN"   # (e.g, "OU=Doctors,OU=Staff,DC=hospital,DC=local")
    
    # create sub OU if it doesn't exist
    if (-not (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$ouPath)" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $ou -Path $parentOUDN
        Write-Host "[O] Created sub-OU: $ou" -ForegroundColor Green
    } else {
        Write-Host "[!] Sub-OU '$ou' already exists." -ForegroundColor Yellow
    }
}
