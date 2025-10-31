$ErrorActionPreference='SilentlyContinue'
$curl="$env:SystemRoot\System32\curl.exe"
function Allow($u){ & $curl -s -I -X OPTIONS $u | findstr /irc:"^Allow:" | ForEach-Object{$_ -replace '\s+',' '} }
$A1=(Allow "http://localhost:19090/v1/plan") ; if(-not $A1){$A1="Allow: ?"}
$A2=(Allow "http://localhost:19090/v1/plan/"); if(-not $A2){$A2="Allow: ?"}
$B1=(Allow "http://localhost:38888/v1/plan")  ; if(-not $B1){$B1="Allow: ?"}
$B2=(Allow "http://localhost:38888/v1/plan/") ; if(-not $B2){$B2="Allow: ?"}
Write-Output ("ALLOW 19090:/v1/plan -> {0} | /v1/plan/ -> {1} || 38888:/v1/plan -> {2} | /v1/plan/ -> {3}" -f $A1,$A2,$B1,$B2)
