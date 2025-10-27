function Write-DevirTemplate {
  param(
    [int]$FazNo,
    [string]$Stack = "GW Stack",
    [string]$Tz    = "TRT/UTC+3",
    [string]$Date  = (Get-Date -Format "yyyy-MM-dd")
  )
  $tpl = @"
# DEVİR ÖZETİ — $Stack — FAZ-$FazNo — $Date ($Tz)

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
# `\$env:PLANID=(irm http://localhost:18088/v1/plan/compile -Method POST).planId

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
"@
  return $tpl
}

function New-FazDevir {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][int]$N,
    [string]$Stack = "GW Stack",
    [string]$Tz    = "TRT/UTC+3",
    [string]$Date  = (Get-Date -Format "yyyy-MM-dd")
  )
  $dir  = "docs/faz-$N"
  $file = Join-Path $dir "devir_ozeti.md"
  if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  if (!(Test-Path $file)) {
    $body = Write-DevirTemplate -FazNo $N -Stack $Stack -Tz $Tz -Date $Date
    Set-Content -Path $file -Value $body -Encoding UTF8
    Write-Host "Oluşturuldu: $file"
  } else {
    Write-Host "Zaten var: $file"
  }
}

function Add-KritikNot {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][int]$N,
    [Parameter(Mandatory)][string[]]$Lines
  )
  $file = "docs/faz-$N/devir_ozeti.md"
  if (!(Test-Path $file)) { throw "Bulunamadı: $file" }
  Add-Content -Path $file -Value "`n- " + ($Lines -join "`n- ")
  Write-Host "Eklendi: $file"
}
