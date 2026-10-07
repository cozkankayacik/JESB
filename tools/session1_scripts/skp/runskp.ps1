param([string]$Script, [string]$Model, [int]$TimeoutSec = 240)
# Launch SketchUp with a startup Ruby script, wait for done.txt next to the script, then close SketchUp.
$dir = Split-Path $Script
$done = Join-Path $dir 'done.txt'
if (Test-Path $done) { Remove-Item $done -Force }
$exe = 'C:\Program Files\SketchUp\SketchUp 2026\SketchUp\SketchUp.exe'
$p = Start-Process -FilePath $exe -ArgumentList @('-RubyStartup', "`"$Script`"", "`"$Model`"") -PassThru
$sw = [Diagnostics.Stopwatch]::StartNew()
while (-not (Test-Path $done) -and $sw.Elapsed.TotalSeconds -lt $TimeoutSec -and -not $p.HasExited) { Start-Sleep -Seconds 2 }
Start-Sleep -Seconds 1
"elapsed: $([int]$sw.Elapsed.TotalSeconds)s exited=$($p.HasExited)"
if (Test-Path $done) { "done: " + (Get-Content $done -Raw) } else { "done.txt missing; windows: " + ((Get-Process | Where-Object { $_.MainWindowTitle -and $_.Name -match 'SketchUp' } | ForEach-Object { $_.MainWindowTitle }) -join ' | ') }
if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force }
Get-Process | Where-Object { $_.Name -match '^SketchUp' } | Stop-Process -Force -ErrorAction SilentlyContinue
