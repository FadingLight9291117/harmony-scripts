param(
    [string]$Path = "$env:USERPROFILE\oh-photo"  # save path
)

# Create target directory if not exists
if (!(Test-Path $Path -PathType Container)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
}

$oh_path = '/storage/media/100/local/files/Photo'
$local_path = $Path

Write-Host "Checking device photos..." -ForegroundColor Yellow

# Check if photos exist on device
try {
    $check_result = hdc shell "ls $oh_path 2>/dev/null | wc -l"
    $photo_count = [int]$check_result
    
    if ($photo_count -eq 0) {
        Write-Output "No photos found on device"
        return
    }
    
    Write-Output "Found approximately $photo_count photo(s) on device"
} catch {
    Write-Output "Warning: Could not count photos, proceeding with export..."
}

Write-Host "Exporting photos from device..." -ForegroundColor Yellow

# Export photos
try {
    hdc file recv $oh_path $local_path
    
    # Count exported files
    $exported_files = @(Get-ChildItem -Path $local_path -Recurse -File)
    $total_size = ($exported_files | Measure-Object -Property Length -Sum).Sum / 1MB
    
    Write-Host ""
    Write-Host -ForegroundColor GREEN "[√] " -NoNewline
    Write-Output "Exported $($exported_files.Count) file(s) ($('{0:F2}' -f $total_size) MB)"
    
    $full_local_path = (Get-Item -Path $local_path).FullName
    Write-Output "Location: $full_local_path"
    
    # Open folder
    Invoke-Item -Path $full_local_path
    
} catch {
    Write-Output "Error during export: $_"
    return
}
