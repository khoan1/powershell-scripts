# enable-rdp.ps1
# This script checks and enables Remote Desktop if disabled
# Please run script as adminstrator in PowerShell since script also enables Network Level Authetication and Firewall Rules for RDP 

# Function to get current RDP status
function Get-RDPStatus {
    $status = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -ErrorAction SilentlyContinue
    # check if $status object is null or not
    if ($status) {
        # check if RDP is enabled or not
        if ($status.fDenyTSConnections -eq 0) { 
            return $true 
        } else { return $false }
    } else {
        Write-Warning "Could not read RDP status from registry."
        return $false
    }
}

Write-Host "Checking current Remote Desktop (RDP) status..." -ForegroundColor Cyan
$rdpEnabled = Get-RDPStatus

if ($rdpEnabled) {
    Write-Host "[O] Remote Desktop is already enabled." -ForegroundColor Green
} else {
    Write-Host "[!] Remote Desktop is currently disabled. Enabling now..." -ForegroundColor Yellow

    # Enable RDP
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

    # Enable Network Level Authentication for more secure connection
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1

    # Enable Firewall rules for RDP
    Write-Host "Enabling Windows Firewall rules for Remote Desktop..."
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

    # Start TermService (RDP service name) if stopped
    $rdpService = Get-Service -Name TermService -ErrorAction SilentlyContinue
    if ($rdpService.Status -ne 'Running') {
        Write-Host "Starting Remote Desktop Service..."
        Start-Service -Name TermService
    }

    Write-Host "`n[O] Remote Desktop has been enabled successfully." -ForegroundColor Green
}
