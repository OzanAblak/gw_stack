$ErrorActionPreference='SilentlyContinue'
$root="C:\Users\DELL\Desktop\gw_stack"
$files = Get-ChildItem -Path $root -Filter *.py -Recurse -File -ErrorAction SilentlyContinue
foreach($f in $files){
  $t = Get-Content -Raw -ErrorAction SilentlyContinue $f.FullName
  if(-not $t){ continue }
  $m=[regex]::Match($t, '@app\.route\(["''](/v1/plan/?)["''][^)]*\)')
  if($m.Success){
    $start=$m.Index
    $chunk=$t.Substring($start, [Math]::Min(1000, $t.Length-$start))
    $mm=[regex]::Match($chunk,'methods\s*=\s*\[([^\]]+)\]')
    $methods= if($mm.Success){ ($mm.Groups[1].Value -replace '[\s"'' ]','') } else { 'GET' }
    $keys=@()
    $keys += ([regex]::Matches($chunk,'args\.get\(["''](\w+)["'']') | ForEach-Object{$_.Groups[1].Value})
    $keys += ([regex]::Matches($chunk,'json\["''](\w+)["'']')        | ForEach-Object{$_.Groups[1].Value})
    $keys += ([regex]::Matches($chunk,'get_json\(\)\.get\(["''](\w+)["'']') | ForEach-Object{$_.Groups[1].Value})
    $keys = ($keys | Select-Object -Unique)
    $k= if($keys){ ($keys -join '|') } else { 'NONE' }
    Write-Output ("PLAN_ROUTE METHODS={0} KEYS={1}" -f $methods,$k)
    exit 0
  }
}
Write-Output 'PLAN_ROUTE=NOT_FOUND'
exit 1
