# enable-rdp-startup.ps1
# This script runs at client startup. Script checks and enables Remote Desktop if disabled
# Script will also enables Network Level Authetication and Firewall Rules for RDP
# Script will log results to enable-RDP-startup.log

# Specify location of logfile
$logPath = "\\HOSP-DC1\CentralLogs\enable-RDP.log"

# Fucntion will receive string message and append current date, then will pipe result to $logPath
function Log-Message {
    param ([string]$msg)
    "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $msg" | Out-File -Append -FilePath $logPath
}

Log-Message "==== Running enable-rdp-startup.ps1 ===="

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
        Log-Message "Could not read RDP status from registry."
        return $false
    }
}

Log-Message "Checking current Remote Desktop (RDP) status..." 
$rdpEnabled = Get-RDPStatus

if ($rdpEnabled) {
    Log-Message "[O] Remote Desktop is already enabled."
} else {
    Log-Message "[!] Remote Desktop is currently disabled. Enabling now..." 

    # Enable RDP
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

    # Enable Network Level Authentication for more secure connection
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1

    # Enable Firewall rules for RDP
    Log-Message "Enabling Windows Firewall rules for Remote Desktop..."
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

    # Start TermService (RDP service name) if stopped and skip if Get-Service returns null
    $rdpService = Get-Service -Name TermService -ErrorAction SilentlyContinue
    if ($rdpService -and $rdpService.Status -ne 'Running') {
        Log-Message "Starting Remote Desktop Service..."
        Start-Service -Name TermService
    }

    Log-Message "`n[O] Remote Desktop has been enabled successfully."
}

Log-Message "==== Script completed. Remote Desktop configuration done. ===="
