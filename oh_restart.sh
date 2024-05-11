# !/bin/bash
hdc shell aa force-stop cn.wps.mobileoffice.hap
hdc shell aa start -a EntryAbility -b cn.wps.mobileoffice.hap

echo restart successful