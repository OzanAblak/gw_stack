import json, time, urllib.request, urllib.error
base="http://127.0.0.1:9090"
def code(u, t=5):
    try:
        r=urllib.request.urlopen(urllib.request.Request(u, method="GET"), timeout=t)
        print("", end=""); return r.getcode()
    except urllib.error.HTTPError as e: return e.code
    except: return -1
def post_json(u, data=b"{}"):
    try:
        r=urllib.request.urlopen(urllib.request.Request(u, data=data, headers={"Content-Type":"application/json"}), timeout=10)
        return r.read().decode("utf-8","ignore")
    except: return ""
h = code(base+"/health", 5)
pid = ""
if h==200:
    txt = post_json(base+"/v1/plan/compile", b"{}")
    try:
        pid = json.loads(txt).get("planId","")
    except: pid = ""
g = -1
if pid:
    deadline = time.time()+10
    while time.time()<deadline:
        g = code(f"{base}/v1/plan/{pid}", 5)
        if g==200: break
        time.sleep(0.3)
summary = "PASS" if (h==200 and pid and g==200) else ("FAIL health=%s"%h if h!=200 else ("FAIL compile" if not pid else f"FAIL get={g}"))
print("PORT=9090")
print(f"HEALTH={h}")
print(f"PLANID={pid}")
print(f"GET={g}")
print(f"SUMMARY={summary}")
