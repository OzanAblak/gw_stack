$ErrorActionPreference = "Stop"

# Script klasörü ve repo kökünü bul
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Split-Path -Parent $scriptDir

# Template ve output yollarını repo köküne göre ayarla
$templatePath = Join-Path $repoRoot "docs/faz-43/release_body_template.md"
$outputPath   = Join-Path $repoRoot "docs/faz-43/release_body_generated.md"

if (!(Test-Path $templatePath)) {
    throw "Template not found: $templatePath"
}

# Template içeriğini tek seferde oku
$content = Get-Content $templatePath -Raw

# 1) Placeholder -> ENV değişkeni eşleşmeleri (GATE-1 + RELEASE_DATE)
$mapping = @{
    "{TAG}"                  = "REL_TAG"
    "{RELEASE_TYPE}"         = "REL_TYPE"
    "{BRANCH}"               = "REL_BRANCH"
    "{COMMIT}"               = "REL_COMMIT"
    "{RELEASE_URL}"          = "REL_URL"
    "{RELEASE_DATE}"         = "REL_DATE"

    "{SMOKE_RUN_ID}"         = "SMOKE_RUN_ID"
    "{SMOKE_STATUS}"         = "SMOKE_STATUS"
    "{POST_SMOKE_RUN_ID}"    = "POST_SMOKE_RUN_ID"
    "{POST_SMOKE_STATUS}"    = "POST_SMOKE_STATUS"
    "{RELEASE_DRAFT_RUN_ID}" = "RELEASE_DRAFT_RUN_ID"
    "{RELEASE_DRAFT_STATUS}" = "RELEASE_DRAFT_STATUS"
    "{SITE_CHECK_RUN_ID}"    = "SITE_CHECK_RUN_ID"
    "{SITE_CHECK_STATUS}"    = "SITE_CHECK_STATUS"
    "{CI_PIPELINE_STATUS}"   = "CI_PIPELINE_STATUS"

    "{DOD_STATUS}"           = "DOD_STATUS"
}

foreach ($placeholder in $mapping.Keys) {
    $envName = $mapping[$placeholder]
    $value   = [Environment]::GetEnvironmentVariable($envName)

    if (![string]::IsNullOrEmpty($value)) {
        $content = $content.Replace($placeholder, $value)
    }
}

# RELEASE_DATE fallback (env yoksa UTC şimdi)
if ($content.Contains("{RELEASE_DATE}")) {
    $relDateEnv = [Environment]::GetEnvironmentVariable("REL_DATE")
    if ([string]::IsNullOrEmpty($relDateEnv)) {
        $nowUtc = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
        $content = $content.Replace("{RELEASE_DATE}", $nowUtc)
    }
}

# 2) DoD artefaktlarından metin doldurma (GATE-2 + GATE-5)
$ciDir = Join-Path $repoRoot "ci_artifacts"

if (Test-Path $ciDir) {
    # DoD.txt -> {DOD_TXT_DESC}
    $dodFile = Join-Path $ciDir "DoD.txt"
    if (Test-Path $dodFile) {
        $dodText = (Get-Content $dodFile -Raw).Trim()
        if (-not [string]::IsNullOrWhiteSpace($dodText)) {
            $content = $content.Replace("{DOD_TXT_DESC}", $dodText)

            # Eğer env'den DOD_STATUS gelmediyse, basit bir türetme yap
            $dodStatusEnv = [Environment]::GetEnvironmentVariable("DOD_STATUS")
            if ([string]::IsNullOrEmpty($dodStatusEnv) -and $content.Contains("{DOD_STATUS}")) {
                $status = "UNKNOWN"
                if ($dodText -match "PASS") { $status = "PASS" }
                elseif ($dodText -match "FAIL") { $status = "FAIL" }
                $content = $content.Replace("{DOD_STATUS}", $status)
            }
        }
    }

    # last_smoke.txt -> {LAST_SMOKE_DESC} + SMOKE_RUN_ID/STATUS (GATE-5)
    $lastSmokeFile = Join-Path $ciDir "last_smoke.txt"
    if (Test-Path $lastSmokeFile) {
        $lastSmokeText = (Get-Content $lastSmokeFile -Raw).Trim()
        if (-not [string]::IsNullOrWhiteSpace($lastSmokeText)) {
            # Açıklama alanını doldur
            $content = $content.Replace("{LAST_SMOKE_DESC}", $lastSmokeText)

            # SMOKE_RUN_ID / SMOKE_STATUS türet (placeholder hâlâ varsa)
            if ($content.Contains("{SMOKE_RUN_ID}") -or $content.Contains("{SMOKE_STATUS}")) {
                $smokeRunId   = $null
                $smokeStatus  = $null

                # Örnek format: RUN=19265082131 completed success
                if ($lastSmokeText -match "RUN=(\d+)") {
                    $smokeRunId = $matches[1]
                }

                # Örnek: CONCLUSION=success veya metin içinde "success"/"failure"
                if ($lastSmokeText -match "CONCLUSION=([A-Za-z]+)") {
                    $smokeStatus = $matches[1]
                }
                elseif ($lastSmokeText -match "success") {
                    $smokeStatus = "success"
                }
                elseif ($lastSmokeText -match "failure") {
                    $smokeStatus = "failure"
                }

                if ($smokeRunId -and $content.Contains("{SMOKE_RUN_ID}")) {
                    $content = $content.Replace("{SMOKE_RUN_ID}", $smokeRunId)
                }

                if ($smokeStatus -and $content.Contains("{SMOKE_STATUS}")) {
                    $content = $content.Replace("{SMOKE_STATUS}", $smokeStatus.ToUpper())
                }
            }
        }
    }

    # last_sha256.txt -> {LAST_SHA256_DESC}
    $lastShaFile = Join-Path $ciDir "last_sha256.txt"
    if (Test-Path $lastShaFile) {
        $lastShaText = (Get-Content $lastShaFile -Raw).Trim()
        if (-not [string]::IsNullOrWhiteSpace($lastShaText)) {
            $content = $content.Replace("{LAST_SHA256_DESC}", $lastShaText)
        }
    }
}

# 3) Dostça fallback'ler (GATE-3)
if ($content.Contains("{DOD_TXT_DESC}")) {
    $content = $content.Replace(
        "{DOD_TXT_DESC}",
        "Bu release için DoD.txt artefaktı bulunamadı veya CI tarafından üretilmedi."
    )
}

if ($content.Contains("{LAST_SMOKE_DESC}")) {
    $content = $content.Replace(
        "{LAST_SMOKE_DESC}",
        "Bu release için son smoke koşusuna ait detaylı özet bilgisi bulunamadı."
    )
}

if ($content.Contains("{LAST_SHA256_DESC}")) {
    $content = $content.Replace(
        "{LAST_SHA256_DESC}",
        "Bu release için SHA256 özet bilgisi (last_sha256.txt) bulunamadı."
    )
}

if ($content.Contains("{DOD_STATUS}")) {
    $content = $content.Replace("{DOD_STATUS}", "UNKNOWN")
}

# Output klasörü yoksa oluştur
New-Item -ItemType Directory -Path (Split-Path -Parent $outputPath) -Force | Out-Null

# Çıktıyı yaz
Set-Content -Path $outputPath -Value $content

Write-Output "REL_BODY_OK path=$outputPath"
