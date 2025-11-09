## Quickstart - CMD

```cmd
REM Kok: C:\Users\DELL\Desktop\gw_stack
docker compose up -d
C:\WINDOWS\System32\curl.exe -s -o NUL -w HTTP=%%{http_code} http://localhost:8088/health
C:\WINDOWS\System32\curl.exe -s -o NUL -w HTTP=%%{http_code} http://localhost:38888/health
C:\WINDOWS\System32\curl.exe -s -o NUL -w HTTP=%%{http_code} http://localhost:19090/health
C:\WINDOWS\System32\curl.exe -s -H Content-Type:application/json --data "{"goal":"demo"}" -o NUL -w HTTP=%%{http_code} http://localhost:38888/v1/plan/compile
```

Beklenen: gateway/gwfwd/planner=HTTP=200, compile=HTTP=200
