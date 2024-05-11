login_type=$1

file_dir="preferences_personal"
if [ $login_type == 'personal' ];
then
    file_dir="preferences_personal"
elif [ $login_type == 'company' ];
then
    file_dir="preferences_company"
fi


hdc file send ${file_dir}'\account' "data/app/el2/100/base/cn.wps.mobileoffice.hap/preferences/"
hdc file send ${file_dir}'\auth' "data/app/el2/100/base/cn.wps.mobileoffice.hap/preferences/"

echo 'hdc file send '${file_dir}'/account data/app/el2/100/base/cn.wps.mobileoffice.hap/preferences/'
echo 'hdc file send '${file_dir}'/auth data/app/el2/100/base/cn.wps.mobileoffice.hap/preferences/'

hdc shell aa force-stop cn.wps.mobileoffice.hap
hdc shell aa start -a EntryAbility -b cn.wps.mobileoffice.hap

echo $login_type login successful
