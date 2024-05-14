param(
    [string]$Type = 'company' # company or personal
)

function Send-Perferences([string]$dir) {
    Write-Output "hdc file send ${dir}\account data/app/el2/100/base/cn.wps.mobileoffice.hap/preferences/"
    Write-Output "hdc file send ${dir}\auth data/app/el2/100/base/cn.wps.mobileoffice.hap/preferences/"

    hdc file send $dir'\account' "data/app/el2/100/base/cn.wps.mobileoffice.hap/preferences/"
    hdc file send $dir'\auth' "data/app/el2/100/base/cn.wps.mobileoffice.hap/preferences/"
}

$pref_personal_dir = "${PSScriptRoot}\preferences_personal"
$pref_company_dir = "${PSScriptRoot}\preferences_company"

if ($Type -eq 'personal') {
    Send-Perferences($pref_personal_dir)
}
# default is company
else {
    Send-Perferences($pref_company_dir)
}

Oh-Restart

Write-Host -ForegroundColor GREEN "[√] " -NoNewline;
Write-Output "${Type} account login successful."
