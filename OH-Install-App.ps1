param(
    [string]$Path # path to .hap file or .zip/.rar archive
)

if (!$Path) {
    Write-Host -ForegroundColor RED "[✗] " -NoNewline
    Write-Output "Error: Path parameter is required."
    return
}

# Validate path exists
if (!(Test-Path $Path)) {
    Write-Host -ForegroundColor RED "[✗] " -NoNewline
    Write-Output "Error: File not found - $Path"
    return
}

$temp_dir = "data/local/tmp/aa1dbdb65a2c4d9b80567965e3c422f6"
$file_name = Split-Path -Leaf $Path
$file_ext = [System.IO.Path]::GetExtension($file_name).ToLower()

# Check if path is archive (zip or rar) or .hap file
if ($file_ext -eq '.zip' -or $file_ext -eq '.rar') {
    # Extract archive to temporary directory
    $extract_dir = Join-Path $env:TEMP "oh_install_$([System.Guid]::NewGuid().ToString().Substring(0, 8))"
    
    Write-Output "Extracting archive to $extract_dir..."
    
    if ($file_ext -eq '.zip') {
        Expand-Archive -Path $Path -DestinationPath $extract_dir -Force
    }
    else {
        # For .rar files, check if WinRAR is installed
        $winrar_path = "C:\Program Files\WinRAR\UnRAR.exe"
        if (!(Test-Path $winrar_path)) {
            Write-Host -ForegroundColor RED "[✗] " -NoNewline
            Write-Output "Error: WinRAR not found. Please install WinRAR or use .zip archives."
            return
        }
        
        & $winrar_path x -y $Path $extract_dir | Out-Null
    }
    
    # Find .hap file in extracted directory
    $hap_files = @(Get-ChildItem -Path $extract_dir -Filter "*.hap" -Recurse)
    
    if ($hap_files.Count -eq 0) {
        Write-Host -ForegroundColor RED "[✗] " -NoNewline
        Write-Output "Error: No .hap files found in archive."
        Remove-Item -Path $extract_dir -Recurse -Force
        return
    }
    elseif ($hap_files.Count -gt 1) {
        Write-Host -ForegroundColor YELLOW "[!] " -NoNewline
        Write-Output "Warning: Multiple .hap files found. Installing first one: $($hap_files[0].Name)"
    }
    
    $hap_path = $hap_files[0].FullName
    $install_file = $hap_files[0].Name
}
else {
    $hap_path = $Path
    $install_file = $file_name
    $extract_dir = $null
}

Load-Env

Write-Output "Sending $install_file to device..."
hdc file send $hap_path $temp_dir

Write-Output "Installing app on device..."
hdc shell bm install -p $temp_dir

# Cleanup
Write-Output "Cleaning up device..."
hdc shell rm -rf $temp_dir

if ($extract_dir) {
    Write-Output "Cleaning up local extraction..."
    Remove-Item -Path $extract_dir -Recurse -Force
}

OH-Start-App

Unload-Env

Write-Host -ForegroundColor GREEN "[√] " -NoNewline
Write-Output "install app successfully."
