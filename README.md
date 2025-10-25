# GW Stack Handover (L2)

## Çalıştırma
1. \docker compose up -d\  (klasör: gw_stack)
2. \.\smoke.cmd\

## URL'ler
- Gateway: http://127.0.0.1:8088/health
- Planner: http://127.0.0.1:9090/health

## Bugünkü Durum
- E2E: PASS (compile + GET)
- TTL cleaner: 30 dk

## Açık İşler (T0)
- Gerçek Planner imajına geçiş
- Native \GET /v1/plan/:id\ doğrulaması
- Gateway rewrite opsiyonel
- CI/CD ve alarmlar

