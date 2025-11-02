$root="C:\Users\DELL\Desktop\gw_stack"
$want=@("docker-compose.yml","docker-compose.gateway.yml","infra","scripts","docs\publish_checklist.md","docs")
$have=@(); $miss=@()
foreach($p in $want){ if(Test-Path (Join-Path $root $p)){ $have+=$p } else { $miss+=$p } }
$tar=(Get-Command "$env:SystemRoot\System32\tar.exe" -ErrorAction SilentlyContinue)
Write-Output ("ARTCHK HAVE={0} MISS={1} MISS_LIST={2} TAR={3}" -f $have.Count,$miss.Count,($miss -join "|"),($(if($tar){"OK"}else{"MISSING"})))
