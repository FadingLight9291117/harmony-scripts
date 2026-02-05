param(
    [string]$Path # path to .hap file or .zip/.rar archive
)

function Log-Message([string]$Message, [string]$Level = "INFO") {
    $timestamp = Get-Date -Format "HH:mm:ss"
    switch ($Level) {
        "INFO" {
            Write-Output "[$timestamp] [INFO] $Message"
        }
        "SUCCESS" {
            Write-Host -ForegroundColor GREEN "[√] [$timestamp] [SUCCESS] $Message"
        }
        "WARNING" {
            Write-Host -ForegroundColor YELLOW "[!] [$timestamp] [WARNING] $Message"
        }
        "ERROR" {
            Write-Host -ForegroundColor RED "[✗] [$timestamp] [ERROR] $Message"
        }
    }
}

$start_time = Get-Date
Log-Message "Starting installation process" "INFO"
Log-Message "Input path: $Path" "INFO"

if (!$Path) {
    Log-Message "Path parameter is required" "ERROR"
    return
}

# Validate path exists
if (!(Test-Path $Path)) {
    Log-Message "File not found: $Path" "ERROR"
    return
}

$file_name = Split-Path -Leaf $Path
$file_size = (Get-Item $Path).Length / 1MB
Log-Message "File: $file_name ($('{0:F2}' -f $file_size) MB)" "INFO"

$temp_dir = "data/local/tmp/aa1dbdb65a2c4d9b80567965e3c422f6"
$file_ext = [System.IO.Path]::GetExtension($file_name).ToLower()

# Check if path is archive (zip or rar) or .hap file
if ($file_ext -eq '.zip' -or $file_ext -eq '.rar') {
    Log-Message "Archive detected: $file_ext" "INFO"
    
    # Extract archive to temporary directory
    $extract_dir = Join-Path $env:TEMP "oh_install_$([System.Guid]::NewGuid().ToString().Substring(0, 8))"
    Log-Message "Creating extraction directory: $extract_dir" "INFO"
    
    try {
        if ($file_ext -eq '.zip') {
            Log-Message "Extracting ZIP archive..." "INFO"
            Expand-Archive -Path $Path -DestinationPath $extract_dir -Force
            Log-Message "ZIP extraction completed successfully" "SUCCESS"
        }
        else {
            # For .rar files, check if WinRAR is installed
            $winrar_path = "C:\Program Files\WinRAR\UnRAR.exe"
            if (!(Test-Path $winrar_path)) {
                Log-Message "WinRAR not found at $winrar_path" "ERROR"
                Log-Message "Please install WinRAR or use .zip archives" "ERROR"
                return
            }
            
            Log-Message "Extracting RAR archive with WinRAR..." "INFO"
            & $winrar_path x -y $Path $extract_dir | Out-Null
            Log-Message "RAR extraction completed successfully" "SUCCESS"
        }
    }
    catch {
        Log-Message "Extraction failed: $_" "ERROR"
        if (Test-Path $extract_dir) {
            Remove-Item -Path $extract_dir -Recurse -Force
        }
        return
    }
    
    # Find .hap file in extracted directory
    Log-Message "Searching for .hap files in extracted directory..." "INFO"
    $hap_files = @(Get-ChildItem -Path $extract_dir -Filter "*.hap" -Recurse)
    Log-Message "Found $($hap_files.Count) .hap file(s)" "INFO"
    
    if ($hap_files.Count -eq 0) {
        Log-Message "No .hap files found in archive" "ERROR"
        Log-Message "Cleaning up extraction directory..." "INFO"
        Remove-Item -Path $extract_dir -Recurse -Force
        Log-Message "Cleanup completed" "SUCCESS"
        return
    }
    elseif ($hap_files.Count -gt 1) {
        Log-Message "Multiple .hap files found, installing first one: $($hap_files[0].Name)" "WARNING"
    }
    
    $hap_path = $hap_files[0].FullName
    $install_file = $hap_files[0].Name
    Log-Message "Selected file for installation: $install_file" "INFO"
}
else {
    Log-Message "Direct HAP file detected" "INFO"
    $hap_path = $Path
    $install_file = $file_name
    $extract_dir = $null
}

Load-Env
Log-Message "Environment loaded" "INFO"

try {
    # Send file to device
    Log-Message "Sending $install_file to device (size: $('{0:F2}' -f ((Get-Item $hap_path).Length / 1MB)) MB)..." "INFO"
    hdc file send $hap_path $temp_dir
    Log-Message "File transfer completed" "SUCCESS"
    
    # Install app
    Log-Message "Installing app on device..." "INFO"
    hdc shell bm install -p $temp_dir
    Log-Message "Installation command completed" "SUCCESS"
}
catch {
    Log-Message "Installation process failed: $_" "ERROR"
    Unload-Env
    return
}

# Cleanup
Log-Message "Cleaning up device temporary files..." "INFO"
hdc shell rm -rf $temp_dir
Log-Message "Device cleanup completed" "SUCCESS"

if ($extract_dir) {
    Log-Message "Cleaning up local extraction directory..." "INFO"
    Remove-Item -Path $extract_dir -Recurse -Force
    Log-Message "Local cleanup completed" "SUCCESS"
}

Log-Message "Starting installed app..." "INFO"
OH-Start-App

Unload-Env
Log-Message "Environment restored" "INFO"

$end_time = Get-Date
$elapsed = ($end_time - $start_time).TotalSeconds
Log-Message "Installation completed successfully in ${elapsed} seconds" "SUCCESS"
