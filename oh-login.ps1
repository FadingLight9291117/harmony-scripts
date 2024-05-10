param(
    [string]$type = 'company' # compant or personal
)

$pref_personal_dir = "${PSScriptRoot}\preferences_personal"
$pref_company_dir = "${PSScriptRoot}\preferences_company"

if ($type -eq 'personal') {
    $dir = $pref_personal_dir
}
# default is company
else {
    $dir = $pref_company_dir
}

Write-Output "hdc file send ${dir}\account data/app/el2/100/base/cn.wps.mobileoffice.hap/preferences/"
Write-Output "hdc file send ${dir}\auth data/app/el2/100/base/cn.wps.mobileoffice.hap/preferences/"

hdc file send $dir'\account' "data/app/el2/100/base/cn.wps.mobileoffice.hap/preferences/"
hdc file send $dir'\auth' "data/app/el2/100/base/cn.wps.mobileoffice.hap/preferences/"

Oh-Restart

Write-Host -ForegroundColor GREEN "[√] " -NoNewline;
Write-Output "${type} account login successful."
