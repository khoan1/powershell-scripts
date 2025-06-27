# dhcp-scope-client.ps1
# This scripts collect DHCP scope info from client such as: IP, Subnet, MAC, DHCP server, and Lease expire time

$logPath = "\\HOSP-DC1\CentralLogs\dhcp-scope-client.log"
$hostname = $env:COMPUTERNAME

# Function to write message to log with timestamp
function Log-Message {
    param([string]$msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $msg" | Out-File -FilePath $logPath -Append
}

# Convert prefix length to dotted-decimal subnet mask (e.g. 255.255.255.0)
function ConvertTo-SubnetMask {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateRange(0,32)]
        [int]$PrefixLength
    )

    # Predefined mask bits
    $masks = @(
        '0.0.0.0', '128.0.0.0', '192.0.0.0', '224.0.0.0', '240.0.0.0',
        '248.0.0.0', '252.0.0.0', '254.0.0.0', '255.0.0.0', '255.128.0.0',
        '255.192.0.0', '255.224.0.0', '255.240.0.0', '255.248.0.0', '255.252.0.0',
        '255.254.0.0', '255.255.0.0', '255.255.128.0', '255.255.192.0',
        '255.255.224.0', '255.255.240.0', '255.255.248.0', '255.255.252.0',
        '255.255.254.0', '255.255.255.0', '255.255.255.128', '255.255.255.192',
        '255.255.255.224', '255.255.255.240', '255.255.255.248',
        '255.255.255.252', '255.255.255.254', '255.255.255.255'
    )
    return $masks[$PrefixLength]
}

# Get the active IPv4 network adapter configuration
$adapter = Get-NetIPConfiguration | Where-Object { $_.IPv4Address -and $_.NetAdapter.Status -eq "Up" } | Select-Object -First 1

if ($adapter) {
    $ipAddress = $adapter.IPv4Address.IPAddress
    $prefixLength = $adapter.IPv4Address.PrefixLength
    $subnetMask = ConvertTo-SubnetMask $prefixLength
    $macAddress = $adapter.NetAdapter.MacAddress

    # Run ipconfig and parse DHCP info
    $ipconfig = ipconfig /all
    $dhcpServer = ($ipconfig | Where-Object { $_ -match "DHCP Server" }) -replace ".*:\s+", ""
    $leaseExpires = ($ipconfig | Where-Object { $_ -match "Lease Expires" }) -replace ".*:\s+", ""

    if (-not $dhcpServer) { $dhcpServer = "N/A" }
    if (-not $leaseExpires) { $leaseExpires = "N/A" }

    $logMsg = "$timestamp - $hostname - IP: $ipAddress - Subnet: $subnetMask (/$prefixLength) - MAC: $macAddress - DHCP Server: $dhcpServer - Lease Expires: $leaseExpires"
    Log-Message $logMsg
} 
else {
    Log-Message "$hostname - No active IPv4 adapter with DHCP"
}
