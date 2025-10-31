$ErrorActionPreference='SilentlyContinue'
$pl = (& docker ps --format "{{.Names}}" 2>$null | Where-Object {$_ -match "planner"} | Select-Object -First 1)
if(-not $pl){ Write-Output "INPROBE=NO_CONTAINER"; exit 1 }

$py = @"
import os,re,json,urllib.request,urllib.error
def http_code(url,method='GET',data=None,headers=None):
    if headers is None: headers={}
    try:
        req=urllib.request.Request(url,data=data,headers=headers,method=method)
        with urllib.request.urlopen(req,timeout=3) as r:
            return r.getcode(), r.read(128)
    except urllib.error.HTTPError as e:
        try: b=e.read(128)
        except: b=b''
        return e.code,b
    except Exception:
        return 0,b''
# 1) compile
c,body=http_code('http://localhost:9090/v1/plan/compile',method='POST',data=b'{}',headers={'Content-Type':'application/json'})
pid=None
try: pid=json.loads(body.decode('utf-8','ignore')).get('planId')
except: pass
if not pid:
    m=re.search(r'[0-9a-fA-F-]{8,}', body.decode('utf-8','ignore'))
    pid=m.group(0) if m else None
tests=[]
if pid:
    urls=[f'http://localhost:9090/v1/plan/{pid}',f'http://localhost:9090/v1/plan/{pid}?format=json',f'http://localhost:9090/v1/plan?id={pid}',f'http://localhost:9090/v1/plan?planId={pid}']
    for u in urls:
        code,_=http_code(u)
        tests.append((u,code))
    pj=json.dumps({'planId':pid}).encode('utf-8')
    code,_=http_code('http://localhost:9090/v1/plan/',method='POST',data=pj,headers={'Content-Type':'application/json'})
    tests.append(('POST /v1/plan/',code))
# 2) FS rota taraması
routes=set()
for root,dirs,files in os.walk('/', topdown=True):
    if len(routes)>50: break
    if any(seg in root for seg in ('/proc','/sys','/dev','/var')): continue
    for fn in files:
        if not fn.endswith(('.py','.txt','.conf','.json')): continue
        p=os.path.join(root,fn)
        try:
            with open(p,'r',encoding='utf-8',errors='ignore') as f: txt=f.read()
            for m in re.findall(r'"/v1/[^"]+"',txt): routes.add(m.strip('"'))
        except Exception: pass
out={'pid':pid or 'NULL','compile_code':c,'tests':tests,'routes':sorted(list(routes))[:10]}
print(json.dumps(out,separators=(',',':')))
"@
$enc=[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($py))
$out = & docker exec $pl python -c "import base64;exec(compile(base64.b64decode('$enc').decode(),'inprobe','exec'))" 2>$null
if(-not $out){ $out = & docker exec $pl python3 -c "import base64;exec(compile(base64.b64decode('$enc').decode(),'inprobe','exec'))" 2>$null }
$flat = ($out -replace '\s+',' ')
if($flat.Length -gt 400){ $flat=$flat.Substring(0,400) }
Write-Output ("INPROBE " + ($flat? $flat : "NONE"))
