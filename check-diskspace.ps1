# check-diskspace.ps1
# Logs only drives with less than 10% free space

$threshold = 10                   # under 10% free space
$logPath = ".\low-diskspace.log"  # this path can be changed if needed

# Gets only local drives then calculate free space percentage
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $freeGB = [math]::Round($_.FreeSpace / 1GB, 2)
    $totalGB = [math]::Round($_.Size / 1GB, 2)
    $percentFree = [math]::Round(($freeGB / $totalGB) * 100, 2)

    # Check if free space percentage is below the threshold
    if ($percentFree -lt $threshold) {
        # Create timestamp
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        
        # Format message
        $msg = "$timestamp - $($_.DeviceID) Drive has LOW DISK SPACE - $freeGB GB free / $totalGB GB total ($percentFree`%)"
        
        # Print to console
        Write-Output $msg

        # Append to log file
        Add-Content -Path $logPath -Value $msg
    }
    
    # If free space is above the threshold, print a normal message
    else {
        # Create timestamp
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        
        # Format message
        $msg = "$timestamp - $($_.DeviceID) Drive has NORMAL DISK SPACE - $freeGB GB free / $totalGB GB total ($percentFree`%)"
        
        # Print to console
        Write-Output $msg
    }
}
