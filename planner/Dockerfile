# planner/Dockerfile — sağlam taban
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
COPY . /app

# Gereksinimler: requirements.txt varsa onu kur; yoksa Flask + Waitress kur
RUN pip install --no-cache-dir --upgrade pip && \
    if [ -f requirements.txt ]; then \
        pip install --no-cache-dir -r requirements.txt ; \
    else \
        pip install --no-cache-dir "flask==2.3.*" "waitress==2.1.*" ; \
    fi

EXPOSE 9090

# Healthcheck: /health 200 dönmeli
HEALTHCHECK --interval=5s --timeout=3s --retries=20 CMD python -c "import urllib.request,sys,socket; socket.setdefaulttimeout(3); u='http://127.0.0.1:9090/health'; sys.exit(0) if urllib.request.urlopen(u).status==200 else sys.exit(1)"

# Uygulamayı Waitress ile 9090’da çalıştır
CMD ["waitress-serve","--listen=0.0.0.0:9090","app:app"]


