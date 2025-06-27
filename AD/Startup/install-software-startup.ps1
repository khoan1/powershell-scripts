# install-software-startup.ps1
# This scripts will install specific software

# Define log file location in Domain Controller central log folder
$logPath = "\\HOSP-DC1\CentralLogs\software-install.log"

# Function to write messages to log
function Log-Message {
    param([string]$msg)
    "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $msg" | Out-File -FilePath $logPath -Append
}

Log-Message "=== Software install script started ==="

# List of software to manage
$softwareList = @(
    @{ Name = "Google Chrome"; Installer = "\\HOSP-DC1\Installers\chrome_installer.exe"; CheckPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome" },
    @{ Name = "7-Zip"; Installer = "\\HOSP-DC1\Installers\7zip_installer.msi"; CheckPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" }
)

# Check if software has been installed or not
function Is-SoftwareInstalled {
    param([string]$displayName)

    $softwarePaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($path in $softwarePaths) {
        # Get-ItemProperty reads all the registry entries (subkeys) under given uninstall path
        # Each subkey represents an installed application, which lets you get the DisplayName property
        $registryEntries = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
        foreach ($entry in $registryEntries) {
            if ($entry.DisplayName -like "*$displayName*") {
                return $true
            }
        }
    }

    return $false
}

foreach ($software in $softwareList) {
    Log-Message "Checking $($software.Name)..."

    # Check if software is installed 
    $isInstalled = Is-SoftwareInstalled $software.Name

    if ($isInstalled) {
        Log-Message "$($software.Name) is already installed. Skipping."
    }
    else {
        Log-Message "$($software.Name) is not installed. Installing now..."
        # Silent install commands (modify based on installer type)
        if ($software.Installer -like "*.msi") {
            Start-Process msiexec.exe -ArgumentList "/i `"$($software.Installer)`" /qn /norestart" -Wait
        }
        else {
            Start-Process -FilePath $software.Installer -ArgumentList "/silent /norestart" -Wait
        }
        Log-Message "$($software.Name) installation attempted."
    }
}

Log-Message "=== Software install script finished ==="
