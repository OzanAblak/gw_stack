$ErrorActionPreference='SilentlyContinue'
$pl = (& docker ps --format "{{.Names}}" 2>$null | Where-Object {$_ -match "planner"} | Select-Object -First 1)
if(-not $pl){ Write-Output "INFSRC=NO_CONTAINER"; exit 1 }
$py = @"
import os,re
hits=[]
for root,dirs,files in os.walk('/', topdown=True):
    if any(x in root for x in ('/proc','/sys','/dev','/var','/usr','/lib')): 
        continue
    for fn in files:
        if not fn.endswith('.py'): 
            continue
        p=os.path.join(root,fn)
        try:
            t=open(p,'r',encoding='utf-8',errors='ignore').read()
        except Exception:
            continue
        for m in re.finditer(r'@(?:app|bp|router)\.(?:route|get|post)\(\s*[\"\\\'](/v1[^\"\\\']+)[\"\\\']\s*(?:,.*?methods\s*=\s*\[([^\]]+)\])?', t, re.S):
            route=m.group(1)
            methods=(re.sub(r'[\\s\\\"\\\']','',m.group(2)) if m.group(2) else 'GET')
            chunk=t[m.start():m.start()+600]
            keys=set(re.findall(r'args\\.get\\([\"\\\'](\\w+)[\"\\\']',chunk))
            keys.update(re.findall(r'json\\s*\\[\\s*[\"\\\'](\\w+)[\"\\\']\\s*\\]',chunk))
            keys.update(re.findall(r'get_json\\(\\)\\.get\\([\"\\\'](\\w+)[\"\\\']',chunk))
            if 'plan' in route:
                hits.append((route,methods,'|'.join(sorted(keys)) or 'NONE'))
print('INFSRC ' + (';'.join(f'{r} [{m}] keys={k}' for r,m,k in hits) if hits else 'NONE'))
"@
$enc=[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($py))
$out = & docker exec $pl python -c "import base64;exec(compile(base64.b64decode('$enc').decode(),'scan','exec'))" 2>$null
if(-not $out){ $out = & docker exec $pl python3 -c "import base64;exec(compile(base64.b64decode('$enc').decode(),'scan','exec'))" 2>$null }
$flat = ($out -replace '\s+',' ')
if($flat.Length -gt 400){ $flat=$flat.Substring(0,400) }
Write-Output ($flat?$flat:"INFSRC NONE")
