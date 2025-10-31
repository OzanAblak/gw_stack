$ErrorActionPreference='SilentlyContinue'
$root="C:\Users\DELL\Desktop\gw_stack"
$files=Get-ChildItem -Path $root -Recurse -Filter *.py -File -ErrorAction SilentlyContinue
foreach($f in $files){
  $t=Get-Content -Raw -ErrorAction SilentlyContinue $f.FullName
  if(-not $t){continue}
  $m=[regex]::Match($t,'@app\.route\(["''](/v1/plan/?)["''][^)]*\)\s*[\r\n]+def\s+([A-Za-z_]\w*)\s*\(')
  if($m.Success){
    $i=$m.Index; $len=[Math]::Min(1200,$t.Length-$i)
    $chunk=$t.Substring($i,$len) -replace '\s+',' '
    $snip=$chunk.Substring(0,[Math]::Min(300,$chunk.Length))
    Write-Output ("PLAN_SRC FILE={0} FUNC={1} SNIPPET={2}" -f $f.FullName,$m.Groups[2].Value,$snip)
    exit 0
  }
}
Write-Output "PLAN_SRC=NOT_FOUND"
exit 1
