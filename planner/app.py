import os, time, uuid, json, logging
from datetime import datetime, timezone
from flask import Flask, request, g, jsonify

TTL_SECONDS = int(os.getenv("GW_TTL_SECONDS", "70"))
VERSION = os.getenv("GW_VERSION", "v0.1.0")
COMMIT  = os.getenv("GW_COMMIT",  "local")

# ---- JSON logger (stdlib) ----
logger = logging.getLogger("planner")
logger.setLevel(logging.INFO)
_handler = logging.StreamHandler()
_handler.setFormatter(logging.Formatter("%(message)s"))
logger.handlers = [_handler]
logger.propagate = False

def _now_ts() -> int:
    return int(time.time())

def _iso_utc() -> str:
    return datetime.now(timezone.utc).isoformat()

def jlog(event: str, **fields):
    base = {
        "ts": _iso_utc(),
        "level": "INFO",
        "event": event,
        "request_id": getattr(g, "request_id", None),
    }
    base.update(fields)
    logger.info(json.dumps(base, ensure_ascii=False))

app = Flask(__name__)
_store = {}  # id -> {"ts": epoch}

@app.before_request
def _before():
    rid = request.headers.get("X-Request-ID") or str(uuid.uuid4())
    g.request_id = rid
    g.start = time.time()

@app.after_request
def _after(resp):
    rid = getattr(g, "request_id", "")
    resp.headers["X-Request-ID"] = rid
    latency_ms = int((time.time() - g.get("start", time.time())) * 1000)
    jlog(
        "http",
        method=request.method,
        path=request.path,
        status=resp.status_code,
        latency_ms=latency_ms,
        remote_addr=request.headers.get("X-Forwarded-For", request.remote_addr),
        ua=request.headers.get("User-Agent", "-"),
    )
    return resp

@app.get("/health")
def health():
    return jsonify({"ok": "ok", "version": VERSION, "commit": COMMIT})

@app.post("/v1/plan/compile")
def compile_plan():
    pid = str(uuid.uuid4())  # 36 hane
    _store[pid] = {"ts": _now_ts()}
    jlog("compile", plan_id=pid)
    return jsonify({"planId": pid})

def _ttl(pid: str):
    age = _now_ts() - _store[pid]["ts"]
    return max(0, TTL_SECONDS - age), age

@app.get("/v1/plan/<pid>")
def get_plan(pid):
    if pid not in _store:
        jlog("get_plan_not_found", plan_id=pid)
        return jsonify({"error": "not_found"}), 404
    ttl, age = _ttl(pid)
    if ttl <= 0:
        jlog("get_plan_gone", plan_id=pid, age=age)
        return jsonify({"error": "gone", "age": age}), 410
    jlog("get_plan_ok", plan_id=pid, age=age, ttl=ttl)
    return jsonify({"id": pid, "age": age, "ttl": ttl})

@app.get("/v1/plan/<pid>/debug")
def dbg(pid):
    if pid not in _store:
        jlog("debug_not_found", plan_id=pid)
        return jsonify({"error": "not_found"}), 404
    ttl, age = _ttl(pid)
    jlog("debug", plan_id=pid, age=age, ttl=ttl, tombstone=(ttl == 0))
    return jsonify({"id": pid, "age": age, "ttl": ttl, "tombstone": ttl == 0})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9090)
