# test-dns-resolution.ps1
# This script tests DNS name resolution and logs the results

# Path to central log
$logPath = "\\HOSP-DC1\CentralLogs\dns-resolution.log"

# Domains to test
$domainsToTest = @(
    "hospital.local",        # Internal domain
    "HOSP-DC1",              # Domain Controller hostname
    "www.google.com",        # Public domain
    "www.microsoft.com"      # Public domain
)

# Function to write log
function Log-Message {
    param([string]$msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] $msg" | Out-File -FilePath $logPath -Append
}

# Start log
Log-Message "=== DNS Resolution Test Started ==="

foreach ($domain in $domainsToTest) {
    try {
        $resolved = Resolve-DnsName -Name $domain -ErrorAction Stop
        $ip = $resolved[0].IPAddress
        Log-Message "SUCCESS: '$domain' resolved to $ip"
    }
    catch {
        Log-Message "FAILURE: Could not resolve '$domain' - $_"
    }
}

Log-Message "=== DNS Resolution Test Finished ==="
