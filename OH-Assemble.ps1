param(
    [string]$Type = 'debug' # debug or release
)

switch (${Type}) {
    "debug" {
        hvigorw assembleApp --mode project -p product=default -p buildMode=debug --no-daemon
    }
   "release" {
        hvigorw assembleApp --mode project -p product=default -p buildMode=release --no-daemon
   }
   default {
        Write-Output "${Type} is error."
   }
}
