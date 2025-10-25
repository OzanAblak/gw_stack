from flask import Flask, jsonify, Response
import os, time, uuid, json, pathlib
app = Flask(__name__)
STORE = pathlib.Path("/plans"); STORE.mkdir(parents=True, exist_ok=True)
TTLMIN = int(os.getenv("PLAN_TTL_MIN","5"))

def gc():
    ttl = TTLMIN * 60
    now = time.time()
    for p in STORE.glob("*.json"):
        try:
            if now - p.stat().st_mtime > ttl:
                p.unlink(missing_ok=True)
        except Exception:
            pass

@app.get("/health")
def health():
    return Response("ok", 200, {"Content-Type":"text/plain"})

@app.post("/v1/plan/compile")
def compile_plan():
    gc()
    pid = str(uuid.uuid4())
    (STORE / f"{pid}.json").write_text(json.dumps({"ok": True}))
    return jsonify(planId=pid)

@app.get("/v1/plan/<pid>")
def get_plan(pid):
    gc()
    p = STORE / f"{pid}.json"
    if not p.exists():
        return ("", 404)
    return Response(p.read_text(), 200, {"Content-Type":"application/json"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9090)

# --- GW_TOMBSTONE_START ---
import os, json
from datetime import datetime, timedelta, timezone
from flask import request, jsonify

PLAN_DIR = os.environ.get("PLAN_DIR", "/plans")
TOMBSTONE_DIR = os.environ.get("PLAN_TOMBSTONE_DIR", os.path.join(PLAN_DIR, "tombstones"))
TOMBSTONE_MIN = int(os.environ.get("PLAN_TOMBSTONE_MIN", "10"))
TTL_MIN = int(os.environ.get("PLAN_TTL_MIN", "5"))
SEEN_DIR = os.path.join(TOMBSTONE_DIR, "seen")
os.makedirs(SEEN_DIR, exist_ok=True); os.makedirs(TOMBSTONE_DIR, exist_ok=True)

def _now(): return datetime.now(timezone.utc)

def mark_seen(pid):
    try:
        meta = {"id": pid, "created_at": _now().isoformat(), "ttl_min": TTL_MIN}
        with open(os.path.join(SEEN_DIR, f"{pid}.json"), "w", encoding="utf-8") as f:
            json.dump(meta, f)
    except Exception: pass

def is_gone(pid):
    try:
        tp = os.path.join(TOMBSTONE_DIR, f"{pid}.json")
        if os.path.exists(tp):
            with open(tp, "r", encoding="utf-8") as f: m = json.load(f)
            expired_at = datetime.fromisoformat(m["expired_at"])
            return _now() <= expired_at + timedelta(minutes=TOMBSTONE_MIN)
        sp = os.path.join(SEEN_DIR, f"{pid}.json")
        if os.path.exists(sp):
            with open(sp, "r", encoding="utf-8") as f: m = json.load(f)
            created = datetime.fromisoformat(m["created_at"])
            ttl = int(m.get("ttl_min", TTL_MIN))
            return created + timedelta(minutes=ttl) <= _now() <= created + timedelta(minutes=ttl+TOMBSTONE_MIN)
    except Exception: pass
    return False

@app.after_request
def _gw_capture_planid(resp):
    try:
        if request.path == "/v1/plan/compile" and request.method in ("POST","GET"):
            data = resp.get_json(silent=True) or {}
            pid = data.get("planId")
            if pid: mark_seen(pid)
    except Exception: pass
    return resp

@app.errorhandler(404)
def _gw_tombstone_404(e):
    try:
        p = request.path
        if p.startswith("/v1/plan/"):
            pid = p.rsplit("/",1)[-1]
            if is_gone(pid):
                return jsonify({"error":"gone","status":410,"id":pid}), 410
    except Exception: pass
    return e
# --- GW_TOMBSTONE_END ---

# --- GW_TOMBSTONE_404_TO_410 ---
@app.after_request
def _gw_404_to_410(resp):
    try:
        if resp.status_code == 404 and request.path.startswith("/v1/plan/"):
            pid = request.path.rsplit("/", 1)[-1]
            if is_gone(pid):
                r = jsonify({"error":"gone","status":410,"id":pid})
                r.status_code = 410
                return r
    except Exception:
        pass
    return resp
# --- GW_TOMBSTONE_404_TO_410_END ---
