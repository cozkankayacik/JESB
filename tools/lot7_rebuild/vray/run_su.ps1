# Run a Ruby script inside SketchUp on a copy of a model, wait for its done-file, then close SketchUp.
# The script reads vray_config.json (written here) next to itself.
# Usage: powershell -File run_su.ps1 -Script <rb> -Model <skp> -Work <dir> [-Extra <json string>] [-TimeoutSec 1800]
param([string]$Script, [string]$Model, [string]$Work, [string]$Extra = '{}', [int]$TimeoutSec = 1800)
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$exe = 'C:\Program Files\SketchUp\SketchUp 2026\SketchUp\SketchUp.exe'
if (Get-Process SketchUp -ErrorAction SilentlyContinue) { throw 'SketchUp is open - close it first (the run would force-close it).' }
New-Item -ItemType Directory -Force $Work | Out-Null
$copy = Join-Path $Work 'su_run_copy.skp'
Copy-Item $Model $copy -Force
$done = Join-Path $Work 'su_done.txt'
Remove-Item $done -ErrorAction SilentlyContinue
$cfg = $Extra | ConvertFrom-Json
$cfg | Add-Member -Force NoteProperty work $Work
$cfg | Add-Member -Force NoteProperty done $done
$cfg | Add-Member -Force NoteProperty log (Join-Path $Work 'su_log.txt')
[IO.File]::WriteAllText((Join-Path $here 'vray_config.json'), ($cfg | ConvertTo-Json -Depth 6))
$p = Start-Process $exe -ArgumentList "-RubyStartup `"$Script`" `"$copy`"" -PassThru
$t0 = Get-Date
while (-not (Test-Path $done)) {
  Start-Sleep -Seconds 5
  if (((Get-Date) - $t0).TotalSeconds -gt $TimeoutSec) { break }
}
Start-Sleep -Seconds 3
Get-Process SketchUp -ErrorAction SilentlyContinue | Stop-Process -Force
if (Test-Path $done) { 'done: ' + (Get-Content $done) } else { 'TIMEOUT' }
Get-Content (Join-Path $Work 'su_log.txt') -ErrorAction SilentlyContinue | Select-Object -Last 60
