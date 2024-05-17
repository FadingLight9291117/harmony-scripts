param(
    [string]$Path = "$env:USERPROFILE\oh-photo" # save path
)

if (!(Test-Path $Path -PathType Container)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
}

$currentTime = Get-Date
$timestamp = [Math]::Round((New-TimeSpan -Start "01/01/1970" -End $currentTime).TotalSeconds)

$file_name = "IMG_${timestamp}.jpeg"
$out_file_name = "IMG_${timestamp}.jpg"

$oh_path = "/data/local/tmp/$file_name"
$local_path = "${Path}\$out_file_name"

hdc shell snapshot_display -f $oh_path
hdc hdc file recv $oh_path $local_path

$full_local_path = (Get-Item -Path $local_path).FullName

Write-Output ""
Write-Host -ForegroundColor GREEN "[√] " -NoNewline;
Write-Output "export in $full_local_path"

Invoke-Item -Path $full_local_path
