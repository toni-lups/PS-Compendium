# Get the number of CPU cores
$numberOfLogicalCores = (
    (Get-CimInstance -ClassName Win32_Processor).NumberOfLogicalProcessors | Measure-Object -Sum
).Sum

# Get the total RAM in GB
$totalRamGB = [Math]::Round((Get-CimInstance -Class win32_computersystem -ComputerName localhost).TotalPhysicalMemory / 1Gb, 2)

# Get available disk space for all drives
$disks = Get-CimInstance -Class Win32_LogicalDisk -Filter "DriveType=3"  # Filter only local disks (type 3)

Write-Host "Number of Logical CPU Cores: ${numberOfLogicalCores}"
Write-Host "Total RAM: ${totalRamGB} GB"
Write-Host "Available Disk Space on Drives:"

foreach ($disk in $disks) {
    $availableSpaceGB = [math]::round($disk.FreeSpace / 1GB, 2)
    $totalSpaceGB = [math]::round($disk.Size / 1GB, 2)
    Write-Host "   $($disk.DeviceID) ${availableSpaceGB} GB free out of ${totalSpaceGB} GB"
}
