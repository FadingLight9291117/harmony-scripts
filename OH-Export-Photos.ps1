param(
    [string]$Path = "$env:USERPROFILE\oh-photo" # save path
)

if (!(Test-Path $Path -PathType Container)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
}

$oh_path = '/storage/media/100/local/files/Photo'
$local_path = $Path

Remove-Item $local_path -Recurse -Force

hdc shell snapshot_display
hdc file recv $oh_path $local_path

Write-Output ""
Write-Host -ForegroundColor GREEN "[√] " -NoNewline;
Write-Output "export in $local_path"

explorer.exe $local_path
