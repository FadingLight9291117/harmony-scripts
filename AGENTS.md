# AGENTS.md - HarmonyOS Development Scripts Guide

This document provides coding guidelines and conventions for the HarmonyOS development utilities repository.

## Project Overview

This is a collection of utility scripts for HarmonyOS development, primarily focused on device interaction, app management, and development workflows. Scripts are written in PowerShell (Windows) and Bash (Linux/macOS).

## Build/Execution Commands

### Main Scripts

These are the primary utility scripts available:

```powershell
# Device/App Management
./OH-Login.ps1 -Type [company|personal]        # Login with account preferences
./OH-Logout.ps1                                # Logout current account
./OH-Assemble.ps1 -Type [debug|release]        # Build app (debug or release)
./OH-Snapshot.ps1 -Path [optional path]        # Take screenshot and copy to clipboard
./OH-Export-Photos.ps1 -Path [optional path]   # Export device photos
./OH-Restart.ps1                               # Restart the app
./OH-Start.ps1                                 # Start the app
./OH-Stop.ps1                                  # Stop/force-stop the app
./OH-Uninstall.ps1                             # Uninstall the app
./OH-Log-Clear.ps1                             # Clear device logs
./OH-Log-Export.ps1                            # Export device logs

# Environment setup (run before using atomic scripts)
./Load-Env.ps1                                 # Add atom/ to PATH
./Unload-Env.ps1                               # Restore original PATH
```

### Atomic Scripts

Located in `atom/` directory for atomized operations:
- `OH-Start-App.ps1` - Start the app
- `OH-Stop-App.ps1` - Stop the app
- `OH-Uninstall-App.ps1` - Uninstall the app

### Running Tests/Validation

```bash
# No formal test framework - scripts should be validated by:
# 1. Manual testing on HarmonyOS device via hdc
# 2. Shell script syntax validation: shellcheck *.sh
# 3. PowerShell script syntax validation in PowerShell ISE/VS Code
```

## Code Style Guidelines

### Naming Conventions

**Scripts:**
- Pascal case for main scripts: `OH-Export-Photos.ps1`
- Kebab case for descriptive names with hyphens
- Prefix scripts with context (OH for OpenHarmony, short action names)

**Variables:**
- camelCase for variables: `$timestamp`, `$local_path`, `$file_name`
- UPPER_CASE for constants and environment variables: `$env:USERPROFILE`
- Descriptive names that indicate purpose: `$pref_personal_dir`, `$oh_path`

**Functions:**
- PascalCase with verb-noun pattern: `Send-Perferences`, `Test-Path`
- Descriptive names that clearly indicate action

### PowerShell Formatting

**Structure:**
```powershell
# 1. Parameter declarations at top
param(
    [string]$Type = 'company'  # type and default value
)

# 2. Function definitions
function Send-Data([string]$dir) {
    # implementation
}

# 3. Main script logic
$variable = "value"
function-call $variable
```

**Style:**
- Use 4-space indentation (no tabs)
- Blank lines between logical sections
- Comments for non-obvious logic (especially in Chinese for this team)
- Wrap long lines at reasonable lengths
- Use backtick for line continuation only when necessary

**String formatting:**
```powershell
# Prefer double quotes with variable interpolation
Write-Output "Value: ${variable}"

# Use single quotes when no interpolation needed
Write-Output 'Static text'
```

### Bash Formatting

**Style:**
- Use 4-space indentation
- Meaningful variable names with underscores: `file_dir`, `login_type`
- Clear, simple conditional logic
- Comment section headers

### Imports & Dependencies

**PowerShell:**
```powershell
# Load external files at script start
Load-Env  # Custom function from Load-Env.ps1

# Add required .NET assemblies as needed
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
```

**External Tools:**
- `hdc` (HarmonyOS Device Connector) - primary tool for device interaction
- `hvigorw` - HarmonyOS build tool
- Standard shell utilities (Get-Item, Test-Path, etc.)

### Error Handling

**PowerShell:**
```powershell
# Use Test-Path for file existence checks
if (!(Test-Path $Path -PathType Container)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
}

# Redirect output to $null when not needed
hdc file send ... | Out-Null

# Provide clear success/failure messages
Write-Host -ForegroundColor GREEN "[√] " -NoNewline
Write-Output "Operation successful."
```

**Bash:**
```bash
# Simple conditional checks
if [ $condition ]; then
    # do something
fi
```

### Output & User Feedback

**Status messages:**
```powershell
# Success indication
Write-Host -ForegroundColor GREEN "[√] " -NoNewline
Write-Output "operation successful."

# Info messages
Write-Output "hdc file send ${dir}"
```

### Comments & Documentation

- Use comments to explain complex logic or non-obvious choices
- Document parameter purposes inline: `[string]$Type = 'company' # company or personal`
- Include example usage in header comments for utility scripts
- Keep comments concise and clear

### File Organization

```
harmony-scripts/
├── [Main scripts] (OH-*.ps1)    # User-facing utilities
├── [Helper scripts] (*.ps1)      # Load-Env.ps1, Unload-Env.ps1
├── [Shell scripts] (*.sh)        # Bash equivalents
├── atom/                          # Atomized script components
└── preferences_*/                 # Data files for operations
```

## Development Workflow

1. **Create new script:**
   - Use OH- prefix for main scripts
   - Follow naming convention (OH-Action-Description.ps1)
   - Include param() block with defaults and comments
   - Add error handling for file operations

2. **Test script:**
   - Manually run on device with hdc available
   - Test both success and failure paths
   - Validate output messages are clear

3. **Commit changes:**
   - Use conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`
   - Write in English in commits (team may use Chinese in comments)
   - Reference affected script names

## Git Conventions

Commit message format:
```
[type]: [description]

feat: add log export script
fix: correct hdc path in OH-Snapshot
refactor: atomize app start/stop logic
docs: update readme with examples
```

## Environment Setup

Before running scripts that depend on atomized operations:

```powershell
# Load atom/ scripts into PATH
./Load-Env.ps1

# After work, restore PATH
./Unload-Env.ps1
```

## Common Patterns

**HarmonyOS Device Interaction:**
```powershell
# Command execution
hdc shell [command]

# File operations
hdc file send $source $destination
hdc file recv $source $destination

# App management
hdc shell aa force-stop [package]
hdc shell aa start -a [ability] -b [package]
```

**Parameter Defaults:**
```powershell
# User profile path for exports
[string]$Path = "$env:USERPROFILE\oh-photo"

# Default to 'company' account type
[string]$Type = 'company'
```
