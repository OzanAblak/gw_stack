param(
    [string]$Branch = "main",
    [string]$OutputPath = "ci_meta.env"
)

$ErrorActionPreference = "Stop"

Write-Host "Resolving CI metadata for branch $Branch..."

$workflows = @(
    @{ Name = "smoke";      RunIdVar = "SMOKE_RUN_ID";      StatusVar = "SMOKE_STATUS" },
    @{ Name = "post_smoke"; RunIdVar = "POST_SMOKE_RUN_ID"; StatusVar = "POST_SMOKE_STATUS" },
    @{ Name = "site_check"; RunIdVar = "SITE_CHECK_RUN_ID"; StatusVar = "SITE_CHECK_STATUS" }
)

$lines = @()

# gh CLI yoksa hepsini N/A / UNKNOWN yap
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Warning "GitHub CLI 'gh' not found. All CI meta values will be set to N/A / UNKNOWN."
    foreach ($wf in $workflows) {
        $lines += "$($wf.RunIdVar)=N/A"
        $lines += "$($wf.StatusVar)=UNKNOWN"
    }
}
else {
    foreach ($wf in $workflows) {
        $name      = $wf.Name
        $runIdVar  = $wf.RunIdVar
        $statusVar = $wf.StatusVar

        try {
            Write-Host "Looking for last successful run of workflow $name..."

            $json = gh run list `
                --workflow $name `
                --branch $Branch `
                --status success `
                --limit 1 `
                --json databaseId,status,conclusion,headSha,updatedAt 2>$null

            if (-not $json -or $json.Trim() -eq "" -or $json.Trim() -eq "[]") {
                Write-Warning "No successful run found for workflow $name. Using N/A / UNKNOWN."
                $lines += "$runIdVar=N/A"
                $lines += "$statusVar=UNKNOWN"
                continue
            }

            $obj = $json | ConvertFrom-Json

            if ($obj -is [array]) {
                if ($obj.Count -eq 0) {
                    Write-Warning "JSON array is empty for workflow $name. Using N/A / UNKNOWN."
                    $lines += "$runIdVar=N/A"
                    $lines += "$statusVar=UNKNOWN"
                    continue
                }
                $run = $obj[0]
            }
            else {
                $run = $obj
            }

            $runId  = $run.databaseId
            $status = $run.conclusion
            if (-not $status) { $status = $run.status }

            if (-not $runId)  { $runId  = "N/A" }
            if (-not $status) { $status = "UNKNOWN" }

            Write-Host ("  OK {0}: RUN_ID={1} STATUS={2}" -f $name, $runId, $status)


            $lines += "$runIdVar=$runId"
            $lines += "$statusVar=$status"
        }
        catch {
            Write-Warning ("Error while resolving workflow {0}: {1}. Using N/A / UNKNOWN." -f $name, $_.Exception.Message)
            $lines += "$runIdVar=N/A"
            $lines += "$statusVar=UNKNOWN"
        }
    }
}

# Her ihtimale karşı, hiçbir satır üretilmediyse minimum fallback
if ($lines.Count -eq 0) {
    Write-Warning "No CI meta lines produced; writing minimal fallback."
    $lines += "SMOKE_RUN_ID=N/A"
    $lines += "SMOKE_STATUS=UNKNOWN"
    $lines += "POST_SMOKE_RUN_ID=N/A"
    $lines += "POST_SMOKE_STATUS=UNKNOWN"
    $lines += "SITE_CHECK_RUN_ID=N/A"
    $lines += "SITE_CHECK_STATUS=UNKNOWN"
}

# Dosyaya yaz
$joined = $lines -join "`n"
Set-Content -Path $OutputPath -Value $joined -Encoding utf8

Write-Host "CI meta written to $OutputPath"
Write-Host ""
Write-Host "---- $OutputPath ----"
Write-Host $joined
Write-Host "----------------------"
