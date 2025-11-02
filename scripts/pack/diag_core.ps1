$ErrorActionPreference='SilentlyContinue'
$root="C:\Users\DELL\Desktop\gw_stack"
$includes=@("docker-compose.yml","docker-compose.gateway.yml","infra","scripts","docs","docs\publish_checklist.md")
$files=0;$long=0;$maxlen=0;$locked=0;$miss=0
foreach($inc in $includes){
  $p=Join-Path $root $inc
  if(Test-Path $p -PathType Leaf){
    $len=$p.Length; if($len -gt $maxlen){$maxlen=$len}
    $files++; try{$s=[System.IO.File]::Open($p,[System.IO.FileMode]::Open,[System.IO.FileAccess]::Read,[System.IO.FileShare]::Read);$s.Dispose()}catch{$locked++}
    if($len -gt 240){$long++}
  } elseif(Test-Path $p -PathType Container){
    Get-ChildItem -LiteralPath $p -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object{
      $q=$_.FullName; $len=$q.Length; if($len -gt $maxlen){$maxlen=$len}
      $files++; if($len -gt 240){$long++}
      try{$s=[System.IO.File]::Open($q,[System.IO.FileMode]::Open,[System.IO.FileAccess]::Read,[System.IO.FileShare]::Read);$s.Dispose()}catch{$locked++}
    }
  } else { $miss++ }
}
Write-Output ("PACKDIAG FILES={0} LONG={1} MAXLEN={2} LOCKED={3} MISS={4}" -f $files,$long,$maxlen,$locked,$miss)
