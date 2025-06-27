# backup-dhcp-config.ps1
# This script backs up DHCP server configuration to a timestamped folder

# Configuration setup
$dhcpServer = "localhost"  # Change to specific server if remote
$backupRoot = "C:\DHCP-Backups"  # Change to preferred path if needed

# Create backup path with timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupPath = Join-Path -Path $backupRoot -ChildPath $timestamp

# Ensure backup directory exists
if (!(Test-Path $backupPath)) {
    New-Item -ItemType Directory -Path $backupPath | Out-Null
}

# Backup DHCP using both native command "netsh" and cmdlet "Export-DhcpServer"
try {
    Write-Host "Backing up DHCP config to $backupPath..."
    
    # older command for backup
    netsh dhcp server export "$backupPath\dhcp-config.xml" all
    
    # newer cmdlet for backup including current lease info
    Export-DhcpServer -ComputerName $dhcpServer -Leases -File "$backupPath\dhcp-export.xml" -Verbose

    Write-Host "[O] Backup completed successfully to: $backupPath"
}
catch {
    Write-Host "[X] Failed to backup DHCP config: $_"
}
