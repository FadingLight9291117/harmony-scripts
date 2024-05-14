$oh_path = '/storage/media/100/local/files/Photo'
$local_path = 'C:\Users\wps\oh-photo'

Remove-Item $local_path -Recurse -Force

hdc shell snapshot_display
hdc file recv $oh_path $local_path
