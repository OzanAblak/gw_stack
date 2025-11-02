# CHECKPOINT PS5 SAFE - silent single line
$ErrorActionPreference='SilentlyContinue'
$WarningPreference='SilentlyContinue'
$InformationPreference='SilentlyContinue'
$VerbosePreference='SilentlyContinue'
$ProgressPreference='SilentlyContinue'

$root="C:\Users\DELL\Desktop\gw_stack"

# HTTP helpers via .NET (no curl)
Add-Type -AssemblyName System.Net.Http -ErrorAction SilentlyContinue | Out-Null
function HttpCode([string]$url){
  try{
    $c = New-Object System.Net.Http.HttpClient
    $c.Timeout = [TimeSpan]::FromSeconds(5)
    $r = $c.GetAsync($url).Result
    $code = [int]$r.StatusCode
    $c.Dispose()
    return $code
  }catch{ return 0 }
}
function PostJson([string]$url){
  try{
    $c = New-Object System.Net.Http.HttpClient
    $c.Timeout = [TimeSpan]::FromSeconds(8)
    $content = New-Object System.Net.Http.StringContent("{}",[Text.Encoding]::UTF8,"application/json")
    $r = $c.PostAsync($url,$content).Result
    $code = [int]$r.StatusCode
    $body = $r.Content.ReadAsStringAsync().Result
    $c.Dispose()
    ,@($code,$body)
  }catch{ ,@(0,"") }
}
function ExtractPid([string]$body){
  $m=[regex]::Match($body,'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}|^\d{2,}$')
  if($m.Success){ $m.Value } else { $null }
}

# Local DoD
$h1 = HttpCode "http://localhost:19090/health"
$h2 = HttpCode "http://localhost:38888/health"
$cb = PostJson "http://localhost:19090/v1/plan/compile"
$e2e = [int]$cb[0]
$pid = ExtractPid ([string]$cb[1])
if(-not $pid){ $e2e = 0 }
$DoD = if($h1 -eq 200 -and $h2 -eq 200 -and $e2e -eq 200){ "PASS 19090=200 38888=200 E2E=200" } else { "FAIL H19090=$h1 H38888=$h2 E2E=$e2e" }

# Gateway DoD
$gh  = HttpCode "http://localhost:8088/health"
$gcb = PostJson "http://localhost:8088/v1/plan/compile"
$ge2e = [int]$gcb[0]
$gpid = ExtractPid ([string]$gcb[1])
if(-not $gpid){ $ge2e = 0 }
$GW = if($gh -eq 200 -and $ge2e -eq 200){ "GW_PASS 8088=200 E2E=200" } else { "GW_FAIL 8088=$gh E2E=$ge2e" }

# Git meta from .git (no git.exe)
$branch="UNKNOWN"; $commit="UNKNOWN"; $tag="NONE"
try{
  $gitDir = Join-Path $root ".git"
  if(Test-Path $gitDir){
    $headPath = Join-Path $gitDir "HEAD"
    $head = (Get-Content -Raw -ErrorAction SilentlyContinue $headPath)
    if($head){
      $head = $head.Trim()
      if($head -like "ref:*"){
        $ref = $head.Substring($head.IndexOf(":")+1).Trim()
        $branch = Split-Path $ref -Leaf
        $shaPath = Join-Path $gitDir $ref
        $sha = (Get-Content -Raw -ErrorAction SilentlyContinue $shaPath)
      } else {
        $sha = $head
        $branch = "DETACHED"
      }
      if($sha){ 
        $sha = $sha.Trim()
        if($sha.Length -ge 7){ $commit = $sha.Substring(0,7) } else { $commit = $sha }
      }
    }
  }
}catch{}

# Artifact summary
$artRel = 'artifacts\gw_stack_v0.1.2-core.zip'
$art    = Join-Path $root $artRel
$sha256='N/A'; $asize=0
try{
  if(Test-Path $art){
    $sha256=(Get-FileHash -Algorithm SHA256 -Path $art -ErrorAction SilentlyContinue).Hash.ToLower()
    $asize =(Get-Item $art -ErrorAction SilentlyContinue).Length
  }
}catch{}

# Write checkpoint (ASCII-safe)
$dir = Join-Path $root 'docs\faz-21'
if(!(Test-Path $dir)){ New-Item -ItemType Directory -Path $dir -ErrorAction SilentlyContinue | Out-Null }
$file = Join-Path $dir ("checkpoint-{0}.md" -f (Get-Date -Format 'yyyyMMdd'))
$lines = @(
  "# FAZ-21 - Checkpoint $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')",
  "- BRANCH=$branch COMMIT=$commit TAG=$tag",
  "- DoD: $DoD",
  "- GW: $GW",
  "- ART: $artRel",
  "- SHA256: $sha256 SIZE=$asize"
)
[IO.File]::WriteAllLines($file,$lines,(New-Object Text.UTF8Encoding($false)))

Write-Output ("CHK="+$file.Substring($root.Length+1))
