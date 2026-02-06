param(
    [string]$Path = "$env:USERPROFILE\oh-photo",  # save path
    [switch]$NoClipboard,                          # skip copying to clipboard
    [switch]$NoOpen                                # skip opening file
)

# Create target directory if not exists
if (!(Test-Path $Path -PathType Container)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
}

Write-Host "Taking screenshot..." -ForegroundColor Yellow

# Generate filename with timestamp
$currentTime = Get-Date
$timestamp = [Math]::Round((New-TimeSpan -Start "01/01/1970" -End $currentTime).TotalSeconds)
$readable_time = $currentTime.ToString("yyyyMMdd_HHmmss")

$file_name = "screenshot_${timestamp}.jpeg"
$out_file_name = "screenshot_${readable_time}.jpg"

$oh_path = "/data/local/tmp/$file_name"
$local_path = "${Path}\$out_file_name"

# Take screenshot on device
try {
    $result = hdc shell snapshot_display -f $oh_path 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to take screenshot on device"
        return
    }
} catch {
    Write-Output "Error: Screenshot command failed - $_"
    return
}

Write-Host "Downloading screenshot..." -ForegroundColor Yellow

# Download screenshot from device
try {
    hdc file recv $oh_path $local_path | Out-Null
    
    if (!(Test-Path $local_path)) {
        Write-Output "Error: Failed to download screenshot"
        hdc shell rm -f $oh_path
        return
    }
    
    # Cleanup device temp file
    hdc shell rm -f $oh_path | Out-Null
    
} catch {
    Write-Output "Error: Download failed - $_"
    hdc shell rm -f $oh_path
    return
}

# Get file info
$file_info = Get-Item -Path $local_path
$file_size = $file_info.Length / 1KB
$full_local_path = $file_info.FullName

Write-Host ""
Write-Host -ForegroundColor GREEN "[√] " -NoNewline
Write-Output "Screenshot saved ($('{0:F1}' -f $file_size) KB)"
Write-Output "Location: $full_local_path"

# Copy to clipboard (unless -NoClipboard specified)
if (!$NoClipboard) {
    try {
        Write-Host "Copying to clipboard..." -ForegroundColor Yellow
        Add-Type -AssemblyName System.Drawing
        Add-Type -AssemblyName System.Windows.Forms
        $image = [System.Drawing.Image]::FromFile($full_local_path)
        [System.Windows.Forms.Clipboard]::SetImage($image)
        $image.Dispose()
        Write-Host -ForegroundColor GREEN "[√] " -NoNewline
        Write-Output "Copied to clipboard"
    } catch {
        Write-Output "Warning: Failed to copy to clipboard - $_"
    }
}

# Open file (unless -NoOpen specified)
if (!$NoOpen) {
    Invoke-Item -Path $full_local_path
}
