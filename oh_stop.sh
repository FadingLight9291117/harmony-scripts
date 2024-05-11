# !/bin/bash
hdc shell rm -rf "data/app/el2/100/base/cn.wps.mobileoffice.hap/preferences/*"

hdc shell aa force-stop cn.wps.mobileoffice.hap
