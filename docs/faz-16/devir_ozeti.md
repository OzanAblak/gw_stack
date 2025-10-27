# DEVİR ÖZETİ — GW Stack — FAZ-16 — 2025-10-27 (TRT/UTC+3)

## DURUM
# ör: Branch=main | Tag=v0.1.0 | CI=green | Ports: gateway=18088→80, planner=19090→9090

## DİZİN/YAPILAR
# ./gateway/, ./planner/, ./ui/, ./scripts/, .github/workflows/, docker-compose.yml, README.md, .dockerignore

## BİLEŞENLER
# ör: gateway=Nginx proxy | planner=Flask/Waitress API | ui=SPA

## ÖNEMLİ KONFİGLER
# Nginx, TTL, healthcheck, env, CI adımları

## DOĞRULANANLAR (PASS)
# /health 200, UI GET / 200, compile→200, TTL→410, debug görünür

## HIZLI KOMUTLAR
# docker compose up -d
# iwr http://localhost:18088/health
# \6d9c7607-e267-420e-99e1-49000ed50408=(irm http://localhost:18088/v1/plan/compile -Method POST).planId

## AÇIK KONULAR / RİSK
# log formatı, security headers, gzip, rate-limit, version/sha, publish, UI iyileştirme

## YARIN PLAN (NET)
# 1) logging 2) security+gzip+rate-limit 3) /health version/sha 4) publish 5) UI auto-poll

## KURALLAR (SABİT)
- Tek kapı: Her promptta **tek kod bloğu** veya **tek dosya değişikliği**.
- Çalıştır-doğrula: Önce verilen kod çalıştırılır. Hata varsa sadece düzeltme verilir, aynı kapıda kalınır.
- Hatasızsa geç: Hata yoksa bir sonraki kapıya geçilir.
- Kayıt: Her kapı sonunda 1–3 maddelik **Kritik Notlar** yazılır.
- Kapsam disiplini: Minimal diff, gereksiz refaktör yok.
- Devir özeti paylaşımı: Devir özeti **daima bu şablonla ve tek bir kod bloğu içinde** paylaşılır; tek tıkla kopyalanabilir olmalıdır.
- Varsayılan kabuk: PowerShell. Farklı kabuk istenecekse açıkça belirtilir.

## KRİTİK NOTLAR
- <kapı-1 sonrası not>
- <kapı-2 sonrası not>

## BEŞ SATIR RAPOR
PORT=... | HEALTH=... | CI=... | E2E=... | NEXT=...

- Kapı-4: gateway reload + rate-limit test; 429 sayısı=0

- Kapı-5: .gitattributes ile satır sonları standardize edildi (LF; ps1=CRLF)

- Kapı-6: /health → version/commit eklendi (GW_VERSION/GW_COMMIT varsayılanlarla)

- Kapı-6 teşhis: ps/logs/port/inspect çalıştırıldı

- Kapı-7: flask.g .get() → getattr() fix; health ve akış geçti

- Teşhis paketi çalıştırıldı: ps/nginx-test/log/health/flow

- Kapı-8: global error handler eklendi; bağlantı kapanmaları 500 JSON'a dönüştürüldü

- Kapı-8: after_request try/except ve 3930f087-0484-4ad0-a66b-c05bc724cfe5 kullanımı; bağlantı kapanması giderildi

- Kapı-9: compose ile GW_VERSION/GW_COMMIT aktarıldı; health ve akış doğrulandı
