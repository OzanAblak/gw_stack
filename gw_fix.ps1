$ErrorActionPreference='Stop'
Set-Location 'C:\Users\DELL\Desktop\gw_stack'

# --- Planner app (host dosyasÄ±) ---
$pl = @'
from flask import Flask, jsonify, Response
from pathlib import Path
import uuid, json, os, time
app=Flask(__name__)
STORE=Path('/plans'); STORE.mkdir(parents=True, exist_ok=True)
TTLMIN=int(os.getenv('PLAN_TTL_MIN','5'))
def gc():
    ttl=TTLMIN*60; now=time.time()
    for p in STORE.glob('*.json'):
        try:
            if now-p.stat().st_mtime>ttl: p.unlink()
        except: pass
@app.get('/health')
def h(): return Response('ok',200,{'Content-Type':'text/plain'})
@app.post('/v1/plan/compile')
def c():
    gc(); pid=str(uuid.uuid4())
    (STORE/f'{pid}.json').write_text(json.dumps({'ok':True}))
    return jsonify(planId=pid)
@app.get('/v1/plan/<pid>')
def g(pid):
    gc(); p=STORE/f'{pid}.json'
    if not p.exists(): return ('',404)
    return Response(p.read_text(),200,{'Content-Type':'application/json'})
if __name__=='__main__':
    app.run(host='0.0.0.0', port=9090)
'@
Set-Content -Path .\pl_app.py -Value $pl -Encoding UTF8

# --- Gateway conf (host dosyasÄ±) ---
$gwconf = @'
server {
  listen 80;
  location = /health { return 200 "ok"; add_header Content-Type text/plain; }
  location /v1/ {
    proxy_pass http://plfix:9090/v1/;
    proxy_http_version 1.1;
    proxy_connect_timeout 5s;
    proxy_send_timeout 30s;
    proxy_read_timeout 30s;
  }
}
'@
Set-Content -Path .\gw.conf -Value $gwconf -Encoding UTF8

# --- Temiz baÅŸlat ---
docker rm -f gwfix plfix *> $null 2>&1
docker network rm gwfix *> $null 2>&1
docker network create gwfix | Out-Null

# --- Planner container ---
docker run -d --name plfix --network gwfix -p 19090:9090 -v ${PWD}\pl_app.py:/pl_app.py -e PLAN_TTL_MIN=5 python:3.12-alpine sh -lc "pip install -q flask && python /pl_app.py" | Out-Null

function Http([string]$u){ try{ (Invoke-WebRequest -UseBasicParsing -TimeoutSec 6 -Uri $u -Method GET).StatusCode.value__ } catch{ $r=$_.Exception.Response; if($r){[int]$r.StatusCode}else{-1} } }
$plh=-1; foreach($i in 1..40){ $plh=Http "http://127.0.0.1:19090/health"; if($plh -eq 200){ break }; Start-Sleep -Milliseconds 250 }

# --- Gateway container ---
docker run -d --name gwfix --network gwfix -p 18088:80 -v ${PWD}\gw.conf:/etc/nginx/conf.d/zz_gw.conf:ro nginx:alpine | Out-Null
docker exec gwfix sh -lc "nginx -t &&
