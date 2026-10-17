# JESB Lot 7 R01 - run the SketchUp build headless-ish: copy the owner's model to the work folder, start SketchUp
# with build_r01.rb as RubyStartup, wait for the done-file, then close SketchUp.
# Usage: powershell -File run_build.ps1 -Work <work_dir> -SaveAs <skp> -ExportDir <dir>
param([string]$Work, [string]$SaveAs, [string]$ExportDir, [string]$Rev = 'R01', [int]$TimeoutSec = 900)
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$exe = 'C:\Program Files\SketchUp\SketchUp 2026\SketchUp\SketchUp.exe'
if (Get-Process SketchUp -ErrorAction SilentlyContinue) { throw 'SketchUp is open - close it first (the run would force-close it).' }
$owner = 'C:\Projects\JESB\LOT7\03_Shared_CAD_and_Models\Models\00_Owner_Original\JESB_Lot7_Owner_Model_2026-10-15.skp'
$base = Join-Path $Work 'r01_base_copy.skp'
Copy-Item $owner $base -Force
$done = Join-Path $Work 'r01_done.txt'
Remove-Item $done -ErrorAction SilentlyContinue
$cfg = @{
  spec = (Join-Path $Work 'r01_spec.json'); log = (Join-Path $Work 'r01_build_log.txt'); done = $done; tmp = $Work
  save_as = $SaveAs; export_dir = $ExportDir; rev = $Rev
  src_brick = 'Brick_05_1K'; src_shingle = 'Material5'; src_siding = 'Material1'; src_metal = 'Material metal'
} | ConvertTo-Json
[IO.File]::WriteAllText((Join-Path $here 'run_config.json'), $cfg)
$p = Start-Process $exe -ArgumentList "-RubyStartup `"$here\build_r01.rb`" `"$base`"" -PassThru
$t0 = Get-Date
while (-not (Test-Path $done)) {
  Start-Sleep -Seconds 5
  if (((Get-Date) - $t0).TotalSeconds -gt $TimeoutSec) { break }
}
Start-Sleep -Seconds 3
Get-Process SketchUp -ErrorAction SilentlyContinue | Stop-Process -Force
if (Test-Path $done) { "done: " + (Get-Content $done) } else { 'TIMEOUT' }
Get-Content (Join-Path $Work 'r01_build_log.txt') -ErrorAction SilentlyContinue | Select-Object -Last 40
