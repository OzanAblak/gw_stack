param(
    [string]$TemplatePath = "",
    [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"

function Get-EnvOrDefault([string]$name, [string]$default) {
    $v = [System.Environment]::GetEnvironmentVariable($name)
    if ($null -ne $v -and $v.Trim() -ne "") {
        return $v
    }
    return $default
}

# Script ve repo kökü
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Split-Path -Parent $scriptDir

if (-not $TemplatePath -or $TemplatePath.Trim() -eq "") {
    $TemplatePath = Join-Path $repoRoot "docs/faz-43/release_body_template.md"
}
if (-not $OutputPath -or $OutputPath.Trim() -eq "") {
    $OutputPath = Join-Path $repoRoot "docs/faz-43/release_body_generated.md"
}

if (-not (Test-Path $TemplatePath)) {
    throw "Template file not found: $TemplatePath"
}

# Template içeriğini oku
$content = Get-Content -Path $TemplatePath -Raw -Encoding UTF8

# ENV tabanlı alanlar
$tag            = Get-EnvOrDefault "REL_TAG" "v0.0.0-UNKNOWN"
$relType        = Get-EnvOrDefault "REL_TYPE" "Pre-release"
$branch         = Get-EnvOrDefault "REL_BRANCH" "unknown-branch"
$commit         = Get-EnvOrDefault "REL_COMMIT" "unknown-commit"
$relUrl         = Get-EnvOrDefault "REL_URL" "https://example.invalid"
$relDate        = Get-EnvOrDefault "REL_DATE" ([DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ"))

$smokeRunId     = Get-EnvOrDefault "SMOKE_RUN_ID" "N/A"
$smokeStatus    = Get-EnvOrDefault "SMOKE_STATUS" "UNKNOWN"
$postRunId      = Get-EnvOrDefault "POST_SMOKE_RUN_ID" "N/A"
$postStatus     = Get-EnvOrDefault "POST_SMOKE_STATUS" "UNKNOWN"
$releaseRunId   = Get-EnvOrDefault "RELEASE_DRAFT_RUN_ID" "N/A"
$releaseStatus  = Get-EnvOrDefault "RELEASE_DRAFT_STATUS" "UNKNOWN"
$siteRunId      = Get-EnvOrDefault "SITE_CHECK_RUN_ID" "N/A"
$siteStatus     = Get-EnvOrDefault "SITE_CHECK_STATUS" "UNKNOWN"
$pipelineStatus = Get-EnvOrDefault "CI_PIPELINE_STATUS" "UNKNOWN"
$dodStatusEnv   = Get-EnvOrDefault "DOD_STATUS" "UNKNOWN"

# DoD artefaktları
$ciArtifactsDir   = Join-Path $repoRoot "ci_artifacts"

$dodTxtDesc       = ""
$lastSmokeDesc    = ""
$lastSha256Desc   = ""
$dodStatusDerived = $null

if (Test-Path $ciArtifactsDir) {
    $dodPath = Join-Path $ciArtifactsDir "DoD.txt"
    if (Test-Path $dodPath) {
        $dodTxtDesc = (Get-Content -Path $dodPath -Raw -Encoding UTF8).Trim()
        if ($dodTxtDesc -match "PASS" -and -not ($dodTxtDesc -match "FAIL")) {
            $dodStatusDerived = "PASS"
        }
        elseif ($dodTxtDesc -match "FAIL") {
            $dodStatusDerived = "FAIL"
        }
    }

    $lastSmokePath = Join-Path $ciArtifactsDir "last_smoke.txt"
    if (Test-Path $lastSmokePath) {
        $lastSmokeDesc = (Get-Content -Path $lastSmokePath -Raw -Encoding UTF8).Trim()

        $runMatch = [regex]::Match($lastSmokeDesc, "RUN=(\d+)")
        if ($runMatch.Success) {
            $smokeRunId = $runMatch.Groups[1].Value
        }

        $conclusionMatch = [regex]::Match($lastSmokeDesc, "CONCLUSION=([A-Za-z]+)")
        if ($conclusionMatch.Success) {
            $smokeStatus = $conclusionMatch.Groups[1].Value
        }
        elseif ($lastSmokeDesc -match "(?i)success") {
            $smokeStatus = "success"
        }
        elseif ($lastSmokeDesc -match "(?i)fail") {
            $smokeStatus = "failure"
        }
    }

    $lastShaPath = Join-Path $ciArtifactsDir "last_sha256.txt"
    if (Test-Path $lastShaPath) {
        $lastSha256Desc = (Get-Content -Path $lastShaPath -Raw -Encoding UTF8).Trim()
    }
}

# DOD_STATUS kararı (ENV öncelikli, sonra türetilen, en son UNKNOWN)
if ($dodStatusEnv -ne "UNKNOWN") {
    $dodStatus = $dodStatusEnv
}
elseif ($dodStatusDerived) {
    $dodStatus = $dodStatusDerived
}
else {
    $dodStatus = "UNKNOWN"
}

# GATE-2: Otomatik değişiklik özeti (CHANGE_SUMMARY_SHORT)
$changeSummary = ""
try {
    Push-Location $repoRoot
    $logOutput = & git log --pretty=format:"- %h %s" -n 10 2>$null
    Pop-Location

    if ($logOutput) {
        if ($logOutput -is [System.Array]) {
            $changeSummary = ($logOutput -join "`n")
        }
        else {
            $changeSummary = [string]$logOutput
        }
    }
    else {
        $changeSummary = "Son 10 commit için otomatik özet üretilemedi veya kayıt bulunamadı."
    }
}
catch {
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $changeSummary = "Otomatik değişiklik özeti oluşturulurken bir hata oluştu: $($_.Exception.Message)"
    }
    else {
        $changeSummary = "Git komutu bulunamadığı için otomatik değişiklik özeti üretilemedi."
    }
}

if (-not $changeSummary -or $changeSummary.Trim() -eq "") {
    $changeSummary = "Bu pre-release için otomatik değişiklik özeti boş döndü."
}

# Artefakt fallback metinleri
if (-not $dodTxtDesc) {
    $dodTxtDesc = "Bu release için DoD.txt artefaktı bulunamadı veya CI tarafından üretilmedi."
}
if (-not $lastSmokeDesc) {
    $lastSmokeDesc = "Bu release için son smoke koşusuna ait detaylı özet bilgisi bulunamadı."
}
if (-not $lastSha256Desc) {
    $lastSha256Desc = "Bu release için SHA256 özet bilgisi (last_sha256.txt) bulunamadı."
}

# Placeholder → değer eşlemesi
$replacements = @{
    "{TAG}"                   = $tag
    "{RELEASE_TYPE}"          = $relType
    "{BRANCH}"                = $branch
    "{COMMIT}"                = $commit
    "{RELEASE_URL}"           = $relUrl
    "{RELEASE_DATE}"          = $relDate

    "{SMOKE_RUN_ID}"          = $smokeRunId
    "{SMOKE_STATUS}"          = $smokeStatus
    "{POST_SMOKE_RUN_ID}"     = $postRunId
    "{POST_SMOKE_STATUS}"     = $postStatus
    "{RELEASE_DRAFT_RUN_ID}"  = $releaseRunId
    "{RELEASE_DRAFT_STATUS}"  = $releaseStatus
    "{SITE_CHECK_RUN_ID}"     = $siteRunId
    "{SITE_CHECK_STATUS}"     = $siteStatus
    "{CI_PIPELINE_STATUS}"    = $pipelineStatus
    "{DOD_STATUS}"            = $dodStatus

    "{DOD_TXT_DESC}"          = $dodTxtDesc
    "{LAST_SMOKE_DESC}"       = $lastSmokeDesc
    "{LAST_SHA256_DESC}"      = $lastSha256Desc

    "{CHANGE_SUMMARY_SHORT}"  = $changeSummary
}

# Replace işlemi
foreach ($key in $replacements.Keys) {
    $value = $replacements[$key]
    if ($null -eq $value) { $value = "" }
    $content = $content.Replace($key, [string]$value)
}

# Çıktıyı yaz
$outputDir = Split-Path -Parent $OutputPath
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

Set-Content -Path $OutputPath -Value $content -Encoding UTF8

Write-Host ("REL_BODY_OK path={0}" -f $OutputPath)
