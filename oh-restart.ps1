hdc shell aa force-stop cn.wps.mobileoffice.hap
hdc shell aa start -a EntryAbility -b cn.wps.mobileoffice.hap

Write-Host -ForegroundColor GREEN "[√] " -NoNewline;
Write-Output "restart successful."
