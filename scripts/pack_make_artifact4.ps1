$ErrorActionPreference='SilentlyContinue'
$root="C:\Users\DELL\Desktop\gw_stack"
$tag="v0.1.2-core"
$outDir=Join-Path $root "artifacts"
$out=Join-Path $outDir ("gw_stack_{0}.zip" -f $tag)
$list=Join-Path $outDir "artlist.txt"
$want=@("docker-compose.yml","docker-compose.gateway.yml","infra","scripts","docs\publish_checklist.md","docs")
if(!(Test-Path $outDir)){ New-Item -ItemType Directory -Path $outDir | Out-Null }
if(Test-Path $out){ Remove-Item $out -Force 2>$null }
$have=@(); $skip=0
foreach($p in $want){ $f=Join-Path $root $p; if(Test-Path $f){ $have+=$p } else { $skip++ } }
Set-Content -Path $list -NoNewline -Value ($have -join "`r`n")
$tar="$env:SystemRoot\System32\tar.exe"
$ok=$false
if(Test-Path $tar){
  & $tar -a -c -f $out -C $root -T $list 2>$null
  if(Test-Path $out){ $ok=$true }
}
if(-not $ok){
  try{
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    if(Test-Path $out){ Remove-Item $out -Force 2>$null }
    [System.IO.Compression.ZipFile]::CreateFromDirectory($root,$out)  # geniş ama hızlı çıkmak için
    $ok=$true
  }catch{}
}
$size=(Get-Item $out -ErrorAction SilentlyContinue).Length
Write-Output ("ART={0} OK={1} SIZE={2} ITEMS={3} SKIP={4}" -f $out,($(if($ok){"YES"}else{"NO"})),($size?$size:0),$have.Count,$skip)
