Load-Env
OH-Stop-App
Unload-Env

$file_name = 'doc_empty.docx'
$file_path = "${PSScriptRoot}\files\${file_name}"

# hdc shell rm "/storage/media/100/local/files/Docs/Documents/${file_name}"
# hdc file send $file_path "/storage/media/100/local/files/Docs/Documents/${file_name}" # 上传文档

# hdc shell aa start  -a DocumentAbility -b cn.wps.mobileoffice.hap  -U "file://docs/storage/Users/currentUser/Documents/${file_name}"  # wps直接拉起文档 打不开没权限
hdc shell aa start  -a DocumentAbility -b cn.wps.mobileoffice.hap  -U "/data/storage/el2/base/files/document/-1/${file_name}"  # wps直接拉起文档
