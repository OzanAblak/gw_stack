# scripts\ci_dispatch_smoke.ps1
param([string]$Branch="main",[string]$Token)
$ErrorActionPreference="Stop"; $ProgressPreference="SilentlyContinue"
if([string]::IsNullOrWhiteSpace($Token)){ Write-Output "ERR_TOKEN"; exit 1 }
Set-Location "C:\Users\DELL\Desktop\gw_stack"
$remote=(git remote get-url origin) 2>$null
if($remote -notmatch "github\.com[:/](.+?)/(.+?)(\.git)?$"){ Write-Output "ERR_REMOTE"; exit 1 }
$owner=$Matches[1]; $repo=$Matches[2]
$uri="https://api.github.com/repos/$owner/$repo/actions/workflows/smoke.yml/dispatches"
$body=@{ ref=$Branch; inputs=@{ branch=$Branch } } | ConvertTo-Json -Depth 4
$hdr=@{ "Accept"="application/vnd.github+json"; "Authorization"="Bearer $Token"; "X-GitHub-Api-Version"="2022-11-28" }
Invoke-RestMethod -Method Post -Uri $uri -Headers $hdr -Body $body 1>$null 2>$null
Write-Output ("CI_DISPATCH_OK repo={0}/{1} branch={2}" -f $owner,$repo,$Branch)
