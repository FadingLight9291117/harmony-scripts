Load-Env

hdc shell rm -rf "data/app/el2/100/base/cn.wps.mobileoffice.hap/preferences/*"

OH-Stop-App
OH-Start-App

Unload-Env

Write-Host -ForegroundColor GREEN "[√] " -NoNewline;
Write-Output "restart successful."
