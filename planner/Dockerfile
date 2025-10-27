FROM python:3.11-slim

ARG GW_VERSION=v0.1.0
ARG GW_COMMIT=local

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    GW_VERSION=${GW_VERSION} \
    GW_COMMIT=${GW_COMMIT}

WORKDIR /app
COPY requirements.txt .
# requirements'ta olmasa bile waitress'ı garanti kur
RUN pip install --no-cache-dir -r requirements.txt && pip install --no-cache-dir waitress

COPY . .
EXPOSE 9090

# Doğru giriş: waitress-serve
CMD ["waitress-serve","--listen=0.0.0.0:9090","app:app"]
