from flask import Flask, jsonify, abort
import os, uuid, json, time
PLAN_DIR=os.environ.get("PLAN_DIR","/plans"); os.makedirs(PLAN_DIR, exist_ok=True)
TTL_MIN=int(os.environ.get("PLAN_TTL_MIN","30"))
app=Flask(__name__)
@app.get("/health")
def health(): return ("ok",200,{"Content-Type":"text/plain"})
@app.post("/v1/plan/compile")
def compile():
    pid=str(uuid.uuid4()); data={"planId":pid,"createdAt":int(time.time())}
    with open(os.path.join(PLAN_DIR,f"{pid}.json"),"w") as f: json.dump(data,f)
    return jsonify(planId=pid)
def _load(pid):
    p=os.path.join(PLAN_DIR,f"{pid}.json");
    return json.load(open(p)) if os.path.exists(p) else None
@app.get("/v1/plan/<pid>")
def get_plan(pid):
    p=_load(pid)
    if not p: abort(404)
    age=int(time.time())-p.get("createdAt",0)
    if TTL_MIN>=0 and age>=TTL_MIN*60:
        try: os.remove(os.path.join(PLAN_DIR,f"{pid}.json"))
        except FileNotFoundError: pass
        abort(410)
    return jsonify(p)
if __name__=="__main__": app.run(host="0.0.0.0",port=9090)
