# GIT CHECKPOINT COMMIT — PS5-safe, silent, single-line
$ErrorActionPreference='SilentlyContinue'
$WarningPreference='SilentlyContinue'
$InformationPreference='SilentlyContinue'
$VerbosePreference='SilentlyContinue'
$ProgressPreference='SilentlyContinue'

$root="C:\Users\DELL\Desktop\gw_stack"

# .git var mı?
if(-not (Test-Path (Join-Path $root '.git'))){ Write-Output "GIT_CP ERROR=NO_GIT"; exit 1 }

# git.exe bul
$git = "$env:ProgramFiles\Git\cmd\git.exe"
if(-not (Test-Path $git)){
  try{
    $det=& (Join-Path $root 'scripts\git\detect_git.ps1') 2>$null
    if($det -match '^GIT=(.+)$'){ $git=$Matches[1] }
  }catch{}
}
if(-not (Test-Path $git)){
  $gc=(Get-Command git -ErrorAction SilentlyContinue)
  if($gc){ $git=$gc.Source }
}
if(-not (Test-Path $git)){ Write-Output "GIT_CP ERROR=GIT_NOT_FOUND"; exit 1 }

# yardımcılar
function RunQuiet([string]$p){ try{ (($(& $p 2>$null) -join ' ') -replace '\s+',' ').Trim() }catch{ '' } }
function GOut([string[]]$args){ try{ ($(& $git -C $root @args 2>$null) -join "`n") }catch{ "" } }
function GDo([string[]]$args){ try{ & $git -C $root @args 2>$null | Out-Null }catch{} }

# son checkpoint
$chkDir=Join-Path $root 'docs\faz-21'
$chk = Get-ChildItem -LiteralPath $chkDir -Filter 'checkpoint-*.md' -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime | Select-Object -Last 1
if(-not $chk){ Write-Output "GIT_CP ERROR=NO_CHECKPOINT"; exit 1 }
$rel = $chk.FullName.Substring($root.Length+1)

# commit mesajı bileşenleri (tamamen sessiz)
$smCore = RunQuiet (Join-Path $root 'scripts\ci_smoke_local.ps1')
if([string]::IsNullOrWhiteSpace($smCore)){ $smCore='N/A' }
$smGW   = RunQuiet (Join-Path $root 'scripts\docker\ci_smoke_gateway.ps1')
if([string]::IsNullOrWhiteSpace($smGW)){ $smGW='N/A' }
$hashO  = RunQuiet (Join-Path $root 'scripts\pack\hash_artifact.ps1')
$sha256 = 'N/A'; if($hashO -match 'ART_HASH=([a-f0-9]+)'){ $sha256=$Matches[1] }
$asize  = '0';   if($hashO -match 'SIZE=([0-9]+)'){ $asize=$Matches[1] }

# git config (gerekirse; sessiz)
if(-not (GOut @('config','user.name'))){ GDo @('config','user.name','gw-bot') }
if(-not (GOut @('config','user.email'))){ GDo @('config','user.email','gw-bot@example.local') }

# add/commit/push (tümü sessiz)
GDo @('add', $rel)
$staged = GOut @('diff','--cached','--name-only')
$committed='SKIP'
if($staged){
  $msg=("docs(checkpoint): {0} | {1} | {2} | SHA256={3} SIZE={4}" -f $rel,$smCore,$smGW,$sha256,$asize)
  if($msg.Length -gt 180){ $msg=$msg.Substring(0,180) }
  GDo @('commit','-m',$msg)
  $committed='OK'
}

$sha = (GOut @('rev-parse','--short=7','HEAD')).Trim()
if([string]::IsNullOrWhiteSpace($sha)){ $sha='UNKNOWN' }
$push='FAIL'
try{ GDo @('push','origin','HEAD'); $push='OK' }catch{}

Write-Output ("GIT_CP COMMIT={0} SHA={1} PUSH={2} CHK={3}" -f $committed,$sha,$push,$rel)
exit 0
