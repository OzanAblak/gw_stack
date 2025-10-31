$ErrorActionPreference='SilentlyContinue'
$root="C:\Users\DELL\Desktop\gw_stack"
$files = Get-ChildItem -Path $root -Recurse -Filter *.py -File -ErrorAction SilentlyContinue
$routes=@(); $prefix=@(); $keys=@(); $fw=@()
foreach($f in $files){
  $t = Get-Content -Raw -ErrorAction SilentlyContinue $f.FullName
  if(-not $t){ continue }
  if($t -match 'from\s+fastapi\s+import\s+FastAPI'){ $fw += 'FastAPI' }
  if($t -match 'from\s+flask\s+import\s+Flask'){ $fw += 'Flask' }
  $routes += ([regex]::Matches($t,'@\w+\.(?:route|get|post|put|delete)\(["'']([^"'']+)["'']') | ForEach-Object{$_.Groups[1].Value})
  $prefix += ([regex]::Matches($t,'Blueprint\([^)]*url_prefix\s*=\s*["'']([^"'']+)["'']') | ForEach-Object{$_.Groups[1].Value})
  $prefix += ([regex]::Matches($t,'APIRouter\([^)]*prefix\s*=\s*["'']([^"'']+)["'']') | ForEach-Object{$_.Groups[1].Value})
  $keys   += ([regex]::Matches($t,'planId|["'']planId["'']|["'']id["'']') | ForEach-Object{$_.Value})
}
$routes=$routes | Select-Object -Unique
$prefix=$prefix | Select-Object -Unique
$keys=$keys | Select-Object -Unique
$fw=$fw | Select-Object -Unique
if(-not $routes -and -not $prefix){ Write-Output "ROUTE_SCAN routes=NONE prefixes=NONE fw="+(($fw -join "|")?($fw -join "|"):"UNKNOWN"); exit 1 }
Write-Output ("ROUTE_SCAN routes={0} prefixes={1} fw={2} keys={3}" -f (($routes -join ","),($prefix -join ","),(($fw -join "|")?($fw -join "|"):"UNKNOWN"),(($keys -join "|")?($keys -join "|"):"NONE")))
exit 0
