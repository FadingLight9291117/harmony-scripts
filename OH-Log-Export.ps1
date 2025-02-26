
param (
    [string]$path='./hilog'
)


hdc file recv /data/log/hilog/ $path
