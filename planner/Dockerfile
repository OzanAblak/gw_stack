FROM python:3.11-slim

ARG GW_VERSION=v0.1.0
ARG GW_COMMIT=local

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    GW_VERSION=${GW_VERSION} \
    GW_COMMIT=${GW_COMMIT}

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 9090

# Prod: waitress; dev için app.py __main__ zaten var
CMD ["python","-m","waitress","--listen=0.0.0.0:9090","app:app"]
