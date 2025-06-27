# get-system-info.ps1
# This script collects system information and writes it to a log file

$logFile = "$env:SystemDrive\SystemInfo_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Collect info
$hostname     = $env:COMPUTERNAME
$serial       = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
$os           = Get-CimInstance -ClassName Win32_OperatingSystem
$cpu          = (Get-CimInstance -ClassName Win32_Processor).Name
$ramGB        = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$gpuList      = Get-CimInstance -ClassName Win32_VideoController | Select-Object -ExpandProperty Name
$ipList       = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "169.*"} | Select-Object -ExpandProperty IPAddress
$macList      = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'-and $_.MacAddress} | Select-Object -ExpandProperty MacAddress
$motherboard  = Get-CimInstance -ClassName Win32_BaseBoard | Select-Object Manufacturer, Product

# Calculate uptime
$uptime       = (Get-Date) - $os.LastBootUpTime
$uptimeString = "{0} days, {1} hours, {2} minutes" -f $uptime.Days, $uptime.Hours, $uptime.Minutes

# Format output
$output = @()
$output += "===== System Info Report ====="
$output += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$output += "Hostname: $hostname"
$output += "Serial Number: $serial"
$output += "OS: $($os.Caption) $($os.Version)"
$output += "Uptime: $uptimeString"
$output += "RAM: $ramGB GB"
$output += "CPU: $cpu"
$output += "GPU(s): $($gpuList -join ', ')"
$output += "IPv4 Address(es): $($ipList -join ', ')"
$output += "MAC Address(es): $($macList -join ', ')"
$output += "Motherboard: $($motherboard.Manufacturer) $($motherboard.Product)"
$output += "================================"

# Output to console and log file
$output | Tee-Object -FilePath $logFile

Write-Host "`n[O] System information written to: $logFile" -ForegroundColor Green
