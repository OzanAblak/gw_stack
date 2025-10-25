$ErrorActionPreference='Stop'
$base=$env:BASE_URL; if(-not $base){$base='http://127.0.0.1:8088'}
function Code($u){ try{ (Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 10).StatusCode }catch{ if($_.Exception.Response){ $_.Exception.Response.StatusCode.Value__ } else { 'ERR' } } }
function BodyText($resp){
  if($resp.Content -is [string]){ return $resp.Content }
  if($resp.RawContent -is [string]){ return $resp.RawContent }
  if($resp.RawContentStream){ try{$resp.RawContentStream.Position=0}catch{}; $sr=New-Object IO.StreamReader($resp.RawContentStream,[Text.Encoding]::UTF8,$true); return $sr.ReadToEnd() }
  try{ return [Text.Encoding]::UTF8.GetString($resp.Content) }catch{ return "" }
}
function Pick($obj,$names){ foreach($n in $names){ if($obj.PSObject.Properties.Name -contains $n){ return $obj.$n } }; return $null }
$ct='application/json'
# health
$h=Code "$base/health"; if($h -ne 200){ [pscustomobject]@{pass=$false;step='health';health=$h}|ConvertTo-Json -Compress|Write-Host; exit 1 }
# compile
$r=Invoke-RestMethod -Method Post -Uri "$base/v1/plan/compile" -ContentType $ct -Body '{}' -TimeoutSec 15
$id=Pick $r @('planId','id','plan_id','planID'); if(-not $id){ [pscustomobject]@{pass=$false;step='compile_schema';raw=$r}|ConvertTo-Json -Compress|Write-Host; exit 2 }
# get
$w=Invoke-WebRequest -Uri "$base/v1/plan/$id" -UseBasicParsing -TimeoutSec 15
$txt=BodyText $w; $j=$null; try{ $j=$txt|ConvertFrom-Json }catch{}
if(-not $j){ [pscustomobject]@{pass=$false;step='json_parse';id=$id;preview=$txt.Substring(0,[Math]::Min(200,[Math]::Max(0,$txt.Length)))}|ConvertTo-Json -Compress|Write-Host; exit 3 }
# normalize
$norm=[pscustomobject]@{
  planId   =(Pick $j @('planId','id','plan_id','planID'))
  status   =(Pick $j @('status','state','phase'))
  createdAt=(Pick $j @('createdAt','created_at','created','createdAtUtc'))
  payload  =(Pick $j @('payload','data','body','result'))
}
$miss=@(); foreach($k in 'planId','status','createdAt','payload'){ if(-not $norm.$k){ $miss+=$k } }
if($miss.Count -gt 0){ [pscustomobject]@{pass=$false;step='schema_tolerant_fail';id=$id;missing=$miss;keys=$j.PSObject.Properties.Name}|ConvertTo-Json -Compress|Write-Host; exit 4 }
[pscustomobject]@{pass=$true;id=$norm.planId;status=$norm.status}|ConvertTo-Json -Compress|Write-Host
