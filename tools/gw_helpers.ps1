function gwerr([string]$Path="__out.txt",[int]$Tail=200){
  if(!(Test-Path $Path)){ Write-Host "no file: $Path"; return }
  Select-String -Path $Path -Pattern '(?i)error|fail|emerg|crit|traceback|exception|bind|listen|permission|410|404' | Select-Object -Last $Tail
}
function gwctx([string]$Path,[string]$Pattern,[int]$Before=8,[int]$After=24){
  if(!(Test-Path $Path)){ Write-Host "no file: $Path"; return }
  Select-String -Path $Path -Pattern $Pattern -Context $Before,$After | ForEach-Object {
    ">>> {0}:{1}" -f $_.Filename,$_.LineNumber
    $_.Context.PreContext; $_.Line; $_.Context.PostContext; "<<<"
  }
}