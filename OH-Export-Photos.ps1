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

$full_local_path = (Get-Item -Path $local_path).FullName

Write-Output ""
Write-Host -ForegroundColor GREEN "[√] " -NoNewline;
Write-Output "export in $full_local_path"

Invoke-Item -Path $full_local_path
