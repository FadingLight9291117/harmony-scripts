param(
    [string]$Path
)

if (!$Path) {
    return
}

Load-Env

hdc file send $Path data/local/tmp/aa1dbdb65a2c4d9b80567965e3c422f6

hdc shell bm install -p data/local/tmp/aa1dbdb65a2c4d9b80567965e3c422f6

hdc shell rm -rf data/local/tmp/aa1dbdb65a2c4d9b80567965e3c422f6

OH-Start-App

Unload-Env

Write-Host -ForegroundColor GREEN "[√] " -NoNewline;
Write-Output "install app successfully."
