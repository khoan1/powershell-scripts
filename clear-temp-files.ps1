# clear-temp-files.ps1
# This script deletes temp files from Windows Temp and all user Temp folders (script will work even if C:\ is not root drive)
# If temp files fail to delete, errors messages will be send to TempCleanupErrors.log file
# clear-temp-files.ps1 needs to be ran under PowerShell Administrator to delete restricted files in Temp folders

Write-Output "`n==== Clearing Temporary Files ===="

# path for log file
$logFile = "$env:SystemDrive\TempCleanupErrors.log"

# Clear Windows Temp
$windowsTemp = "$env:SystemRoot\Temp"    # gets system root path for temp folder
Write-Output "`n[+] Cleaning: $windowsTemp"

# try to clear files in temp folders, will send error to log file if unable to clear
try {
    # getErr and remErr are error objects from Get-ChildItem and Remove-Item cmdlets
    $errors = @()
    Get-ChildItem -Path $windowsTemp -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable getErr |
        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue -ErrorVariable remErr
    $errors += $getErr
    $errors += $remErr

    # if errors exist, send errors messages to log file
    if ($errors.Count -gt 0) {
        Write-Output "    [!] Some files could not be deleted. See $logFile for details."
        $errors | Out-File -FilePath $logFile -Append
    } else {
        Write-Output "    [O] Windows Temp cleared."
    }
} catch {
    Write-Output "    [X] Failed to clear Windows Temp: $_"
    $_ | Out-File -FilePath $logFile -Append
}

# get user profile names, from any root drive, whose names are not in the list of system/default names
$userProfiles = Get-ChildItem "$env:SystemDrive\Users" -Directory | Where-Object {
    $_.Name -notin @("Default", "Default User", "Public", "All Users")
}

# path for log file
$logFile = "$env:SystemDrive\TempCleanupErrors.log"

# Clear each user's Temp folder
foreach ($user in $userProfiles) {
    # get the path to the user's Temp folder
    $tempPath = "$env:SystemDrive\Users\$($user.Name)\AppData\Local\Temp"
    Write-Output "`n[+] Cleaning: $tempPath"

    # check if temp folder exists in user's profile
    if (Test-Path $tempPath) {
        # try to clear files in temp folders, will send error to log file if unable to clear
        try {
            # getErr and remErr are error objects from Get-ChildItem and Remove-Item cmdlets
            $errors = @()
            Get-ChildItem -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable getErr |
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue -ErrorVariable remErr
            $errors += $getErr
            $errors += $remErr

            # if errors exist, send errors messages to log file
            if ($errors.Count -gt 0) {
                Write-Output "    [!] Some files could not be deleted for user $($user.Name). See $logFile for details."
                $errors | Out-File -FilePath $logFile -Append
            } else {
                Write-Output "    [O] Temp cleared for user: $($user.Name)"
            }
        } catch {
            Write-Output "    [X] Failed to clear temp for user $($user.Name): $_"
            $_ | Out-File -FilePath $logFile -Append
        }
    } else {
        Write-Output "    [X] No temp folder found for user $($user.Name)"
    }
}

Write-Output "`n[O] Done cleaning all temp folders.`n"
