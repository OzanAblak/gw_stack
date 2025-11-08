# E2E NEGATİF TEST PLANI — GW Stack — FAZ-29 — 2025-11-08 (TRT/UTC+3)

## KAPSAM ve KURALLAR
- Amaç: gateway/gwfwd/planner için hata yollarını doğrulamak.
- Kabuk: **Windows CMD** (`cmd.exe`). PowerShell kullanma.
- Kural: Her senaryo TEK komut, TEK satır çıktı.
- Sonuç formatı: `HTTP=<kod>` veya tek satır JSON parçacığı.
- Uçlar:
  - planner = http://localhost:19090
  - gwfwd   = http://localhost:38888
  - gateway = http://localhost:8088

## SENARYOLAR
### N1 — planner: Yanlış yöntem
Komut:
`cmd /d /c %SystemRoot%\System32\curl.exe -s -o NUL -w "HTTP=%{http_code}" -X GET http://localhost:19090/v1/plan/compile`
Beklenen: `HTTP=405` (405 yoksa 404 kabul).

### N2 — planner: Bozuk JSON
Komut:
`cmd /d /c %SystemRoot%\System32\curl.exe -s -o NUL -w "HTTP=%{http_code}" -H "Content-Type: application/json" -d "{^"bad^":}" http://localhost:19090/v1/plan/compile`
Beklenen: `HTTP=400`.

### N3 — planner: Boş gövde
Komut:
`cmd /d /c %SystemRoot%\System32\curl.exe -s -o NUL -w "HTTP=%{http_code}" -H "Content-Type: application/json" -d "" http://localhost:19090/v1/plan/compile`
Beklenen: `HTTP=400`.

### N4 — planner: Yanlış Content-Type
Komut:
`cmd /d /c %SystemRoot%\System32\curl.exe -s -o NUL -w "HTTP=%{http_code}" -H "Content-Type: text/plain" --data-binary "{}", http://localhost:19090/v1/plan/compile`
Beklenen: `HTTP=400` (415 yoksa 400).

### N5 — gateway: Geçersiz yol
Komut:
`cmd /d /c %SystemRoot%\System32\curl.exe -s -o NUL -w "HTTP=%{http_code}" http://localhost:8088/nope`
Beklenen: `HTTP=404`.

### N6 — gateway: /v1/ eksik Content-Type
Komut:
`cmd /d /c %SystemRoot%\System32\curl.exe -s -o NUL -w "HTTP=%{http_code}" -d "{}" http://localhost:8088/v1/`
Beklenen: `HTTP=400`.

### N7 — gateway: Yanlış yöntem (DELETE)
Komut:
`cmd /d /c %SystemRoot%\System32\curl.exe -s -o NUL -w "HTTP=%{http_code}" -X DELETE http://localhost:8088/v1/`
Beklenen: `HTTP=405` (405 yoksa 404).

### N8 — gateway: HEAD isteği
Komut:
`cmd /d /c %SystemRoot%\System32\curl.exe -I -s -o NUL -w "HTTP=%{http_code}" http://localhost:8088/v1/`
Beklenen: `HTTP=405` (405 yoksa 404).

### N9 — gwfwd: Geçersiz yol
Komut:
`cmd /d /c %SystemRoot%\System32\curl.exe -s -o NUL -w "HTTP=%{http_code}" http://localhost:38888/nope`
Beklenen: `HTTP=404`.

### N10 — gwfwd→planner: Bozuk JSON geçişi
Komut:
`cmd /d /c %SystemRoot%\System32\curl.exe -s -o NUL -w "HTTP=%{http_code}" -H "Content-Type: application/json" -d "{^"bad^":}" http://localhost:38888/v1/plan/compile`
Beklenen: `HTTP=400`.

### N11 — planner: Aşırı küçük gövde (`{}`)
Komut:
`cmd /d /c %SystemRoot%\System32\curl.exe -s -o NUL -w "HTTP=%{http_code}" -H "Content-Type: application/json" -d "{}" http://localhost:19090/v1/plan/compile`
Beklenen: `HTTP=400`.

### N12 — gateway: Sağlık dışı yöntem
Komut:
`cmd /d /c %SystemRoot%\System32\curl.exe -s -o NUL -w "HTTP=%{http_code}" -X POST http://localhost:8088/health`
Beklenen: `HTTP=405` (405 yoksa 404).

## KAYIT ve GEÇİŞ KRİTERİ
- Her komut sonrası tek satır çıktıyı bu dosyanın altına ekle:
  - `N<id> => HTTP=<kod>`
- Geçiş: Tüm beklenen kodlar karşılandıysa “Negatif E2E PASS (tarih)” notu.
## SONUÇ KAYDI — 2025-11-08 (TRT/UTC+3)
N1  => HTTP=404
N2  => HTTP=400
N3  => HTTP=400
N4  => HTTP=400
N5  => HTTP=404
N6  => HTTP=404
N7  => HTTP=404
N8  => HTTP=404
N9  => HTTP=404
N10 => HTTP=400
N11 => HTTP=400
N12 => HTTP=405

Negatif E2E PASS — 2025-11-08
