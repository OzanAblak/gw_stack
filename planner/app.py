from flask import Flask, jsonify, request
from datetime import datetime, timedelta, timezone
import uuid, os

app = Flask(__name__)

TTL_SECONDS = int(os.getenv("GW_TTL_SECONDS", "70"))  # GW TTL
plans = {}  # id -> {"created_at": datetime, "tombstone": bool}


@app.get("/health")
def health():
    return ("ok", 200, {"Content-Type": "text/plain"})

@app.post("/v1/plan/compile")
def compile_plan():
    plan_id = str(uuid.uuid4())  # 36 hane
    plans[plan_id] = {"created_at": datetime.now(timezone.utc), "tombstone": False}
    return jsonify({"planId": plan_id})

@app.get("/v1/plan/<plan_id>")
def get_plan(plan_id):
    meta = plans.get(plan_id)
    if not meta:
        return jsonify({"error": "not_found"}), 404

    age = (datetime.now(timezone.utc) - meta["created_at"]).total_seconds()
    if age <= TTL_SECONDS and not meta["tombstone"]:
        remaining = max(0, int(TTL_SECONDS - age))
        return jsonify({"planId": plan_id, "status": "active", "ttlRemaining": remaining}), 200

    # TTL geçti -> tombstone
    meta["tombstone"] = True
    return jsonify({"planId": plan_id, "status": "tombstone"}), 410

if __name__ == "__main__":
    # Waitress prod’da Dockerfile ile çağrılacak; dev için Flask built-in yeterli
    app.run(host="0.0.0.0", port=9090)
