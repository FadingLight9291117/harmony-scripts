# AGENTS.md - HarmonyOS Development Scripts

Utility scripts for HarmonyOS development: device interaction, app management, and workflows.
Written in PowerShell (Windows) and Bash (Linux/macOS).

## Build/Execution Commands

### Main Scripts

```powershell
# App Installation & Management
./OH-Install-App.ps1 -Path [dir|archive]       # Install from directory or .zip/.rar/.7z
./OH-Assemble.ps1 -Type [debug|release]        # Build app
./OH-Start.ps1                                 # Start app
./OH-Stop.ps1                                  # Stop app
./OH-Restart.ps1                               # Restart app
./OH-Uninstall.ps1                             # Uninstall app

# Account Management
./OH-Login.ps1 -Type [company|personal]        # Login with preferences
./OH-Logout.ps1                                # Logout

# Device Utilities
./OH-Snapshot.ps1 -Path [path]                 # Screenshot to clipboard
./OH-Export-Photos.ps1 -Path [path]            # Export device photos
./OH-Log-Clear.ps1                             # Clear logs
./OH-Log-Export.ps1                            # Export logs

# Environment (for atomic scripts)
./Load-Env.ps1                                 # Add atom/ to PATH
./Unload-Env.ps1                               # Restore PATH
```

### Atomic Scripts (atom/)

```powershell
OH-Start-App.ps1      # Start app only
OH-Stop-App.ps1       # Stop app only
OH-Uninstall-App.ps1  # Uninstall only
```

### Validation

```bash
# No formal tests - validate by:
# 1. Manual testing with hdc connected device
# 2. PowerShell syntax: Test in VS Code / ISE
# 3. Bash syntax: shellcheck *.sh
```

## Code Style Guidelines

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Scripts | OH-Action-Name.ps1 | `OH-Install-App.ps1` |
| Variables | snake_case | `$temp_dir`, `$file_name` |
| Functions | PascalCase Verb-Noun | `Send-Preferences` |
| Constants | UPPER_CASE | `$env:USERPROFILE` |

### PowerShell Structure

```powershell
# 1. Parameters at top with comments
param(
    [string]$Path  # description of parameter
)

# 2. Validation
if (!$Path) {
    Write-Output "Error: Path required"
    return
}

# 3. Environment setup
Load-Env

# 4. Main logic with try-catch
try {
    # operations
} catch {
    Write-Output "Error: $_"
    Unload-Env
    return
}

# 5. Cleanup and success message
Unload-Env
Write-Host -ForegroundColor GREEN "[√] " -NoNewline
Write-Output "operation successful."
```

### Formatting Rules

- 4-space indentation (no tabs)
- Blank lines between logical sections
- Double quotes for interpolation: `"Value: ${var}"`
- Single quotes for static text: `'hello'`
- Pipe to `Out-Null` for suppressed output

### Error Handling

```powershell
# Path validation
if (!(Test-Path $Path)) {
    Write-Output "Error: Path not found - $Path"
    return
}

# Directory creation
if (!(Test-Path $Path -PathType Container)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
}

# Try-catch for operations
try {
    hdc shell bm install -p $temp_dir
} catch {
    Write-Output "Error: $_"
    return
}
```

### Output Messages

```powershell
# Success (green checkmark)
Write-Host -ForegroundColor GREEN "[√] " -NoNewline
Write-Output "message"

# Progress (colored)
Write-Host "[$count/$total" -NoNewline -ForegroundColor Cyan
Write-Host " $percent%" -NoNewline -ForegroundColor Green
Write-Host "] " -NoNewline -ForegroundColor Cyan

# Info (yellow)
Write-Host "Processing..." -ForegroundColor Yellow

# Error
Write-Output "Error: description"
```

## HarmonyOS Device Commands (hdc)

```powershell
# File operations
hdc file send $local $device_path
hdc file recv $device_path $local

# Shell commands
hdc shell mkdir -p $dir
hdc shell rm -rf $path
hdc shell snapshot_display -f $path

# App management
hdc shell bm install -p $dir           # Install from directory
hdc shell aa start -a Ability -b pkg   # Start ability
hdc shell aa force-stop pkg            # Stop app
```

## Git Conventions

```bash
# Commit format: type: description
feat: add new feature
fix: correct bug in script
refactor: restructure code
docs: update documentation

# Examples from this repo:
feat: 优化OH-Install-App支持目录/压缩包批量安装并发拷贝
refactor: 原子化
fix: correct hdc path
```

## File Organization

```
harmony-scripts/
├── OH-*.ps1           # Main scripts
├── Load-Env.ps1       # Environment helper
├── Unload-Env.ps1     # Environment cleanup
├── *.sh               # Bash equivalents
├── atom/              # Atomic operations
│   └── OH-*-App.ps1
├── files/             # Static files
└── preferences_*/     # Account data
```

## Key Patterns

### Parallel File Transfer (Jobs)

```powershell
$jobs = @()
foreach ($file in $files) {
    $job = Start-Job -ScriptBlock {
        param($path, $target)
        hdc file send $path $target
    } -ArgumentList $file.FullName, $target_dir
    $jobs += $job
}
# Wait and show progress
while ($jobs.Count -gt 0) { ... }
```

### Random Temp Directory

```powershell
$random_id = [guid]::NewGuid().ToString("N").Substring(0, 16)
$temp_dir = "data/local/tmp/oh_install_$random_id"
```

### Archive Extraction

```powershell
switch ($file_ext) {
    '.zip' { Expand-Archive -Path $Path -DestinationPath $temp -Force }
    '.7z'  { & 7z x $Path -o"$temp" -y | Out-Null }
    '.rar' { & UnRAR x $Path "$temp\" -y | Out-Null }
}
```
