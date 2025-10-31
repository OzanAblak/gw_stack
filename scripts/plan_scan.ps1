$ErrorActionPreference='SilentlyContinue'
$root="C:\Users\DELL\Desktop\gw_stack"
$files = Get-ChildItem -Path $root -Recurse -Include *.py -ErrorAction SilentlyContinue
$hits=@()
foreach($f in $files){
  try{
    $t = Get-Content -Raw -ErrorAction SilentlyContinue $f.FullName
    if($t){
      $ms=[regex]::Matches($t,"['""](/v1/[^'""]+)['""]")
      foreach($m in $ms){ $hits += $m.Groups[1].Value }
    }
  }catch{}
}
$u=($hits | Select-Object -Unique)
if(-not $u -or $u.Count -eq 0){ Write-Output "SRC_ROUTES=NONE"; exit 1 }
Write-Output ("SRC_ROUTES=" + ($u -join ","))
