param(
    [string]$Branch = "main",
    [string]$OutputPath = "ci_meta.env"
)

$ErrorActionPreference = "Stop"

$workflows = @(
    @{ Name = "smoke";      RunIdVar = "SMOKE_RUN_ID";      StatusVar = "SMOKE_STATUS" },
    @{ Name = "post_smoke"; RunIdVar = "POST_SMOKE_RUN_ID"; StatusVar = "POST_SMOKE_STATUS" }
)

$lines = @()

# gh CLI yoksa hepsini N/A / UNKNOWN yap
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
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
            $json = gh run list `
                --workflow $name `
                --branch $Branch `
                --status success `
                --limit 1 `
                --json databaseId,status,conclusion 2>$null

            if (-not $json -or $json.Trim() -eq "" -or $json.Trim() -eq "[]") {
                $lines += "$runIdVar=N/A"
                $lines += "$statusVar=UNKNOWN"
                continue
            }

            $obj = $json | ConvertFrom-Json
            if ($obj -is [array]) {
                if ($obj.Count -eq 0) {
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

            $lines += "$runIdVar=$runId"
            $lines += "$statusVar=$status"
        }
        catch {
            $lines += "$runIdVar=N/A"
            $lines += "$statusVar=UNKNOWN"
        }
    }
}

if ($lines.Count -eq 0) {
    $lines += "SMOKE_RUN_ID=N/A"
    $lines += "SMOKE_STATUS=UNKNOWN"
    $lines += "POST_SMOKE_RUN_ID=N/A"
    $lines += "POST_SMOKE_STATUS=UNKNOWN"
}

$joined = $lines -join "`n"
Set-Content -Path $OutputPath -Value $joined -Encoding utf8
Write-Host $joined
