from flask import Flask, request, jsonify, Response

app = Flask(__name__)

@app.get("/health")
def health():
    return Response("ok", status=200, mimetype="text/plain")

@app.post("/v1/plan/compile")
def compile_plan():
    # Content-Type kontrolü
    if not request.is_json:
        return jsonify(error="content_type_must_be_application_json"), 400

    # Boş gövde veya geçersiz JSON kontrolü
    try:
        data = request.get_json(silent=False)
    except Exception:
        return jsonify(error="invalid_json"), 400
    if not isinstance(data, dict) or len(data) == 0:
        return jsonify(error="empty_or_invalid_body"), 400

    # Burada mevcut iş mantığını çalıştırın.
    # Şimdilik örnek 200 yanıtı:
    return jsonify(ok=True), 200

if __name__ == "__main__":
    # Lokal çalıştırma için; konteynerde serve eden (waitress/gunicorn) bu bloğu kullanmaz.
    app.run(host="0.0.0.0", port=9090)
