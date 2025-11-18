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

# 1) Placeholder -> ENV değişkeni eşleşmeleri
$mapping = @{
    "{TAG}"                  = "REL_TAG"
    "{RELEASE_TYPE}"         = "REL_TYPE"
    "{BRANCH}"               = "REL_BRANCH"
    "{COMMIT}"               = "REL_COMMIT"
    "{RELEASE_URL}"          = "REL_URL"

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

# Env dolu olanları placeholder ile değiştir
foreach ($placeholder in $mapping.Keys) {
    $envName = $mapping[$placeholder]
    $value   = [Environment]::GetEnvironmentVariable($envName)

    if (![string]::IsNullOrEmpty($value)) {
        $content = $content.Replace($placeholder, $value)
    }
}

# 2) DoD artefaktlarından metin doldurma (GATE-2)
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

    # last_smoke.txt -> {LAST_SMOKE_DESC}
    $lastSmokeFile = Join-Path $ciDir "last_smoke.txt"
    if (Test-Path $lastSmokeFile) {
        $lastSmokeText = (Get-Content $lastSmokeFile -Raw).Trim()
        if (-not [string]::IsNullOrWhiteSpace($lastSmokeText)) {
            $content = $content.Replace("{LAST_SMOKE_DESC}", $lastSmokeText)
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

# Output klasörü yoksa oluştur
New-Item -ItemType Directory -Path (Split-Path -Parent $outputPath) -Force | Out-Null

# Çıktıyı yaz
Set-Content -Path $outputPath -Value $content

Write-Output "REL_BODY_OK path=$outputPath"
