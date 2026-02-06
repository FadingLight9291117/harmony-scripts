param(
    [string]$Path = "$env:USERPROFILE\oh-photo"  # save path
)

# Create target directory if not exists
if (!(Test-Path $Path -PathType Container)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
}

# Generate random temp directory name
$random_id = [guid]::NewGuid().ToString("N").Substring(0, 16)
$device_temp = "/data/local/tmp/oh_export_$random_id"
$source_photo_path = '/storage/media/100/local/files/Photo'
$local_path = $Path

Write-Host "Preparing to export photos..." -ForegroundColor Yellow

# Step 1: Create temp directory on device
Write-Output "Creating temporary directory on device..."
try {
    hdc shell mkdir -p $device_temp
} catch {
    Write-Output "Error: Failed to create temp directory"
    return
}

# Step 2: Copy photos to temp directory (with permissions)
Write-Output "Copying photos to accessible location..."
try {
    $copy_result = hdc shell "cp -r $source_photo_path/* $device_temp/ 2>&1"
    
    # Check if copy was successful
    $file_count = hdc shell "ls $device_temp 2>/dev/null | wc -l"
    $photo_count = [int]$file_count
    
    if ($photo_count -eq 0) {
        Write-Output "No photos found or permission denied"
        Write-Output "Source path: $source_photo_path"
        hdc shell rm -rf $device_temp
        return
    }
    
    Write-Output "Found $photo_count file(s) to export"
} catch {
    Write-Output "Error: Failed to copy photos"
    hdc shell rm -rf $device_temp
    return
}

# Step 3: Export photos from temp directory
Write-Host "Downloading photos from device..." -ForegroundColor Yellow

try {
    hdc file recv $device_temp $local_path
    
    # Count exported files
    $exported_files = @(Get-ChildItem -Path $local_path -Recurse -File)
    $total_size = ($exported_files | Measure-Object -Property Length -Sum).Sum / 1MB
    
    Write-Host ""
    Write-Host -ForegroundColor GREEN "[√] " -NoNewline
    Write-Output "Exported $($exported_files.Count) file(s) ($('{0:F2}' -f $total_size) MB)"
    
    $full_local_path = (Get-Item -Path $local_path).FullName
    Write-Output "Location: $full_local_path"
    
    # Cleanup device temp directory
    Write-Output "Cleaning up device..."
    hdc shell rm -rf $device_temp
    
    # Open folder
    Invoke-Item -Path $full_local_path
    
} catch {
    Write-Output "Error during export: $_"
    hdc shell rm -rf $device_temp
    return
}
