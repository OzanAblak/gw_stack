param([string]$Token)

$ErrorActionPreference="Stop"; $ProgressPreference="SilentlyContinue"
[System.Net.ServicePointManager]::SecurityProtocol=[System.Net.SecurityProtocolType]::Tls12

# Token: parametre yoksa dosyadan oku
if([string]::IsNullOrWhiteSpace($Token)){
  $p='C:\Users\DELL\Desktop\gw_stack\token.txt'
  if(Test-Path $p){ $Token=[IO.File]::ReadAllText($p) } else { Write-Output "ERR_TOKEN_MISSING_SRC"; exit 1 }
}
if($null -eq $Token){ $Token="" }
$Token=$Token.Trim()
if([string]::IsNullOrWhiteSpace($Token)){ Write-Output "ERR_TOKEN_MISSING"; exit 1 }

Set-Location "C:\Users\DELL\Desktop\gw_stack"
$remote=(git remote get-url origin) 2>$null
if($remote -notmatch "github\.com[:/](.+?)/(.+?)(\.git)?$"){ Write-Output "ERR_REMOTE"; exit 1 }
$owner=$Matches[1]; $repo=$Matches[2]

$hdr=@{
  "Accept"="application/vnd.github+json"
  "Authorization"=("Bearer {0}" -f $Token)
  "X-GitHub-Api-Version"="2022-11-28"
  "User-Agent"="gw-stack-ci"
}

try{ $me=Invoke-RestMethod -Method Get -Uri "https://api.github.com/user" -Headers $hdr -TimeoutSec 20 }catch{ Write-Output ("ERR_TOKEN_HTTP stage=user err={0}" -f ($_.Exception.Message -replace '\s+',' ')); exit 1 }
if(-not $me.login){ Write-Output "ERR_TOKEN_INVALID"; exit 1 }

try{ $rp=Invoke-RestMethod -Method Get -Uri ("https://api.github.com/repos/{0}/{1}" -f $owner,$repo) -Headers $hdr -TimeoutSec 20 }catch{ Write-Output ("ERR_TOKEN_HTTP stage=repo err={0}" -f ($_.Exception.Message -replace '\s+',' ')); exit 1 }

$push= if($rp.permissions.push){"true"}else{"false"}
$admin=if($rp.permissions.admin){"true"}else{"false"}
Write-Output ("TOKEN_OK login={0} repo={1}/{2} push={3} admin={4}" -f $me.login,$owner,$repo,$push,$admin)
