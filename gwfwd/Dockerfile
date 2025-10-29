FROM alpine:3.20
RUN apk add --no-cache socat curl
EXPOSE 38888
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD curl -fsS http://planner:9090/health >/dev/null || exit 1
CMD ["socat","tcp-listen:38888,fork,reuseaddr","tcp:planner:9090"]
