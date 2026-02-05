param(
    [string]$Path  # path to directory containing .hap/.hsp/.har files or compressed archive (.zip, .rar, .7z, .tar, .gz)
)

if (!$Path) {
    Write-Output "Error: Path parameter required"
    Write-Output "Usage: .\OH-Install-App.ps1 -Path 'path/to/directory' or 'path/to/archive.zip'"
    return
}

# Validate path exists
if (!(Test-Path $Path)) {
    Write-Output "Error: Path does not exist - $Path"
    return
}

Load-Env

# Generate random temp directory name
$random_id = [guid]::NewGuid().ToString("N").Substring(0, 16)
$temp_dir = "data/local/tmp/oh_install_$random_id"
$local_temp = $env:TEMP + "\oh_install_temp"
$source_dir = ""

# Check if path is a directory or archive
$path_item = Get-Item -Path $Path
$is_directory = $path_item -is [System.IO.DirectoryInfo]

if ($is_directory) {
    Write-Output "Directory detected: $Path"
    $source_dir = $Path
    
} else {
    # Check if input is a compressed archive
    $file_ext = [System.IO.Path]::GetExtension($Path).ToLower()
    $is_archive = @('.zip', '.rar', '.7z', '.tar', '.gz') -contains $file_ext
    
    if (!$is_archive) {
        Write-Output "Error: Expected directory or supported archive (.zip, .rar, .7z, .tar, .gz). Got: $file_ext"
        return
    }
    
    Write-Output "Archive detected: $Path"
    
    # Create temporary directory for extraction
    if (Test-Path $local_temp) {
        Remove-Item -Path $local_temp -Recurse -Force | Out-Null
    }
    New-Item -Path $local_temp -ItemType Directory | Out-Null
    
    # Extract archive based on file type
    try {
        switch ($file_ext) {
            '.zip' {
                Write-Output "Extracting ZIP archive..."
                Expand-Archive -Path $Path -DestinationPath $local_temp -Force
            }
            '.7z' {
                Write-Output "Extracting 7Z archive..."
                # Requires 7-Zip to be installed
                if (!(Get-Command 7z -ErrorAction SilentlyContinue)) {
                    Write-Output "Error: 7-Zip not found. Please install 7-Zip or use .zip format"
                    return
                }
                & 7z x $Path -o"$local_temp" -y | Out-Null
            }
            '.rar' {
                Write-Output "Extracting RAR archive..."
                # Requires WinRAR to be installed
                if (!(Get-Command UnRAR -ErrorAction SilentlyContinue)) {
                    Write-Output "Error: WinRAR not found. Please install WinRAR or use .zip format"
                    return
                }
                & UnRAR x $Path "$local_temp\" -y | Out-Null
            }
            default {
                Write-Output "Error: Unsupported archive format - $file_ext"
                return
            }
        }
        
        Write-Output "Archive extracted successfully"
        $source_dir = $local_temp
        
    } catch {
        Write-Output "Error during extraction: $_"
        if (Test-Path $local_temp) {
            Remove-Item -Path $local_temp -Recurse -Force | Out-Null
        }
        Unload-Env
        return
    }
}

# Check if any installable files were found
$hap_files = @(Get-ChildItem -Path $source_dir -Filter "*.hap" -Recurse)
$hsp_files = @(Get-ChildItem -Path $source_dir -Filter "*.hsp" -Recurse)
$har_files = @(Get-ChildItem -Path $source_dir -Filter "*.har" -Recurse)

$total_files = $hap_files.Count + $hsp_files.Count + $har_files.Count

if ($total_files -eq 0) {
    Write-Output "Error: No installable files found (.hap, .hsp, .har)"
    if (Test-Path $local_temp) {
        Remove-Item -Path $local_temp -Recurse -Force | Out-Null
    }
    Unload-Env
    return
}

Write-Output "Found $($hap_files.Count) .hap file(s), $($hsp_files.Count) .hsp file(s), $($har_files.Count) .har file(s)"

# Copy all files to device and install from directory
try {
    # Create device temp directory
    Write-Output "Creating device directory: $temp_dir"
    hdc shell mkdir -p $temp_dir
    
    # Copy all files to device temp directory in parallel
    $all_files = $hap_files + $hsp_files + $har_files
    $total = $all_files.Count
    
    Write-Host "Copying $total files to device (parallel)..." -ForegroundColor Yellow
    Write-Host ""
    
    $jobs = @()
    
    foreach ($file in $all_files) {
        $job = Start-Job -ScriptBlock {
            param($filePath, $targetDir, $fileName)
            $result = hdc file send $filePath $targetDir 2>&1
            return @{
                FileName = $fileName
                Success = $LASTEXITCODE -eq 0
                Output = $result
            }
        } -ArgumentList $file.FullName, $temp_dir, $file.Name
        
        $jobs += $job
    }
    
    # Wait for all jobs to complete and show progress
    $completed = 0
    
    while ($jobs.Count -gt 0) {
        $finished = @()
        
        foreach ($job in $jobs) {
            if ($job.State -eq 'Completed') {
                $result = Receive-Job $job
                $completed++
                
                $percent = [math]::Round(($completed / $total) * 100, 1)
                Write-Host "[$completed/$total" -NoNewline -ForegroundColor Cyan
                Write-Host " $percent%" -NoNewline -ForegroundColor Green
                Write-Host "] " -NoNewline -ForegroundColor Cyan
                Write-Host "Sent: $($result.FileName)"
                
                Remove-Job $job
                $finished += $job
            }
        }
        
        # Remove finished jobs from array
        $jobs = $jobs | Where-Object { $_ -notin $finished }
        
        if ($jobs.Count -gt 0) {
            Start-Sleep -Milliseconds 100
        }
    }
    
    Write-Host ""
    Write-Host "Installing from device directory..." -ForegroundColor Yellow
    hdc shell bm install -p $temp_dir
    
    Write-Host -ForegroundColor GREEN "[√] " -NoNewline
    Write-Output "all files installed successfully"
    
    # Cleanup
    if (Test-Path $local_temp) {
        Remove-Item -Path $local_temp -Recurse -Force | Out-Null
    }
    hdc shell rm -rf $temp_dir
    
} catch {
    Write-Output "Error during installation: $_"
    if (Test-Path $local_temp) {
        Remove-Item -Path $local_temp -Recurse -Force | Out-Null
    }
    Unload-Env
    return
}

OH-Start-App

Unload-Env

Write-Host -ForegroundColor GREEN "[√] " -NoNewline;
Write-Output "install app successfully."
