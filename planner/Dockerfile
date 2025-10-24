FROM python:3.12-slim
WORKDIR /app
COPY . .
ENV PYTHONUNBUFFERED=1
EXPOSE 9090
RUN python -m pip install --upgrade pip && \
    python -m pip install --no-cache-dir waitress && \
    if [ -f requirements.txt ]; then python -m pip install --no-cache-dir -r requirements.txt; fi
CMD ["python","-m","waitress","--port=9090","app:app"]
