param(
  [string]$Base = "http://localhost:18088",
  [int]$PollSeconds = 5,
  [int]$DeadlineSeconds = 180
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

Write-Host "E2E start: $Base"

# Health
Invoke-WebRequest "$Base/health" | Out-Null

# Compile
$plan = Invoke-RestMethod -Method POST -Uri "$Base/v1/plan/compile"
$PLANID = $plan.planId
if(-not $PLANID -or $PLANID.Length -ne 36){ throw "planId invalid" }
Write-Host "PLANID=$PLANID"

# Expect 200 active
$resp = Invoke-RestMethod -Method GET -Uri "$Base/v1/plan/$PLANID"
if($resp.status -ne 'active'){ Write-Error "Expected active, got $($resp.status)"; exit 2 }
Write-Host "GET 200 active ttlRemaining=$($resp.ttlRemaining)"

# Wait for 410
$deadline = (Get-Date).AddSeconds($DeadlineSeconds)
$code = 0
while((Get-Date) -lt $deadline){
  try{
    $c = (Invoke-WebRequest -Uri "$Base/v1/plan/$PLANID").StatusCode
    if($c -eq 410){ $code = 410; break }
  } catch {
    $c = $_.Exception.Response.StatusCode.value__
    if($c -eq 410){ $code = 410; break }
  }
  Start-Sleep -Seconds $PollSeconds
}
if($code -ne 410){ Write-Error "Timeout waiting for 410"; exit 3 }

$port = ([uri]$Base).Port
if($port -eq 0){ $port = 80 }
Write-Host ("SUMMARY PORT={0} PLANID={1} RESULT=PASS" -f $port, $PLANID)
exit 0

