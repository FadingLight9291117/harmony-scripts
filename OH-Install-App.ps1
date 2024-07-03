param(
    [string]$Path
)

if (!$Path) {
    return
}

hdc uninstall cn.wps.mobileoffice.hap

hdc file send $Path data/local/tmp/aa1dbdb65a2c4d9b80567965e3c422f6

hdc shell bm install -p data/local/tmp/aa1dbdb65a2c4d9b80567965e3c422f6

hdc shell rm -rf data/local/tmp/aa1dbdb65a2c4d9b80567965e3c422f6

hdc shell aa start -a EntryAbility -b cn.wps.mobileoffice.hap
