# -- N13 inline guard start --
d = request.get_json(silent=True)
if not isinstance(d, dict) or not isinstance(d.get("goal"), str):
    return {"error":"goal must be string"}, 400
# -- N13 inline guard end --
