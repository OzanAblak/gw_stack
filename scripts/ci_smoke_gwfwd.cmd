@echo off
setlocal
set "BASE=http://localhost"
set "CURL=%SystemRoot%\System32\curl.exe"

"%CURL%" -s -o NUL -w "%%{http_code}" %BASE%:19090/health > "%TEMP%\h1.txt"
set /p H1=<"%TEMP%\h1.txt"
"%CURL%" -s -o NUL -w "%%{http_code}" %BASE%:38888/health > "%TEMP%\h2.txt"
set /p H2=<"%TEMP%\h2.txt"

powershell -NoProfile -Command "$r=Invoke-RestMethod -Uri '%BASE%:38888/v1/plan/compile' -Method POST -ContentType 'application/json' -Body '{}'; if($r){ if($r.id){ $r.id } elseif($r.planId){ $r.planId } }" > "%TEMP%\pid.txt"
set /p ID=<"%TEMP%\pid.txt"

set "G=0"
if defined ID (
  for /l %%I in (1,1,40) do (
    "%CURL%" -s -o NUL -w "%%{http_code}" %BASE%:38888/v1/plan/%ID% > "%TEMP%\g.txt"
    set /p G=<"%TEMP%\g.txt"
    if "%G%"=="200" goto donepoll
    ping -n 1 127.0.0.1 >NUL
  )
)
:donepoll
echo SMOKE=%H1%,%H2%,%G%
if "%H1%"=="200" if "%H2%"=="200" if "%G%"=="200" (exit /b 0) else (exit /b 2)
