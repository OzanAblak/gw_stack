$ErrorActionPreference='SilentlyContinue'
$pl = (& docker ps --format "{{.Names}}" 2>$null | Where-Object {$_ -match "planner"} | Select-Object -First 1)
if(-not $pl){ Write-Output "ROUTES=NO_CONTAINER"; exit 1 }

$py = @"
import importlib
mods=['app','src.app','planner.app','server','main','wsgi','application','app.main','app.app']
out=''
for m in mods:
  try:
    mod=importlib.import_module(m)
    a=getattr(mod,'app',None) or getattr(mod,'application',None)
    if a and hasattr(a,'url_map'):
      out=','.join(sorted([r.rule for r in a.url_map.iter_rules()]))
      break
  except Exception:
    pass
print(out or 'NONE')
"@
$enc = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($py))
$out = & docker exec $pl python -c "import base64,sys;exec(compile(base64.b64decode('$enc').decode(),'introspect','exec'))" 2>$null
if(-not $out){ $out = & docker exec $pl python3 -c "import base64,sys;exec(compile(base64.b64decode('$enc').decode(),'introspect','exec'))" 2>$null }
$flat = ($out -replace '\s+',' ')
Write-Output ("ROUTES=" + ($flat -ne "" ? $flat : "NONE"))
