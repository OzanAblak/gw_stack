# planner/app.py — minimal, sağlam Flask app (Waitress ile 9090)
import uuid
from flask import Flask, request, jsonify, abort

app = Flask(__name__)

# Health: 200 döner (HEAD de destekli)
@app.route("/health", methods=["GET", "HEAD"])
def health():
    return ("ok", 200, {"Content-Type": "text/plain"})

# E2E ölçütü: compile -> planId + 200
@app.route("/v1/plan/compile", methods=["POST"])
def compile_plan():
    # Gövdeyi önemsemiyoruz; sadece planId üretiyoruz
    pid = str(uuid.uuid4())
    return jsonify({"planId": pid}), 200

# Opsiyonel gösterim: geçerli UUID ise 200 döner
@app.route("/v1/plan/<plan_id>", methods=["GET"])
def get_plan(plan_id: str):
    try:
        uuid.UUID(plan_id)
    except Exception:
        abort(404)
    return jsonify({"planId": plan_id}), 200

# Not: Waitress, Dockerfile'daki CMD ile çalıştırılıyor (app:app @ 0.0.0.0:9090)
