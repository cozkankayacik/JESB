param([string]$Dxf, [string]$Out)
$lines = [IO.File]::ReadAllLines($Dxf)
"lines: $($lines.Count)"
$section = ''; $etype = ''; $ent = $null
$ents = New-Object System.Collections.Generic.List[object]
$counts = @{}
$layers = New-Object System.Collections.Generic.HashSet[string]
$layouts = New-Object System.Collections.Generic.List[string]
for ($i = 0; $i + 1 -lt $lines.Count; $i += 2) {
    $code = $lines[$i].Trim(); $val = $lines[$i+1]
    if ($code -eq '0') {
        if ($ent) { $ents.Add($ent) }
        $ent = $null
        $etype = $val.Trim()
        if ($etype -eq 'SECTION') { $section = $lines[$i+3].Trim() }
        if ($section -eq 'ENTITIES' -or $section -eq 'BLOCKS') {
            $counts[$etype] = 1 + [int]$counts[$etype]
            if ($etype -in 'TEXT','MTEXT','ATTRIB','ATTDEF','DIMENSION','INSERT') { $ent = @{ t = $etype; s = $section; txt = ''; layer = ''; x = 0.0; y = 0.0; space = '0'; name = '' } }
        }
        continue
    }
    if ($section -eq 'OBJECTS' -and $etype -eq 'LAYOUT' -and $code -eq '1') { $layouts.Add($val) }
    if ($section -eq 'TABLES' -and $etype -eq 'LAYER' -and $code -eq '2') { [void]$layers.Add($val) }
    if ($ent) {
        switch ($code) {
            '1'  { $ent.txt += $val }
            '3'  { if ($ent.t -eq 'MTEXT') { $ent.txt = $val + $ent.txt } }
            '2'  { $ent.name = $val }
            '8'  { $ent.layer = $val }
            '10' { $ent.x = [double]$val }
            '20' { $ent.y = [double]$val }
            '67' { $ent.space = $val.Trim() }
            '410' { $ent.space = $val }
        }
    }
}
"--- entity counts:"; $counts.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object { "{0,-14} {1}" -f $_.Key, $_.Value }
"--- layouts: " + ($layouts -join ' | ')
"--- layers ($($layers.Count)): " + (($layers | Sort-Object) -join ', ')
"--- block inserts (top 60):"; $ents | Where-Object { $_.t -eq 'INSERT' } | Group-Object { $_.name } | Sort-Object Count -Descending | Select-Object -First 60 | ForEach-Object { "{0,5}  {1}" -f $_.Count, $_.Name }
$clean = { param($s) (($s -replace '\\P',' / ') -replace '\\[A-Za-z][^;\\]*;','' -replace '[{}]','' -replace '%%[cdpCDP]','' -replace '\s+',' ').Trim() }
$txt = $ents | Where-Object { $_.t -ne 'INSERT' -and $_.txt.Trim() -ne '' -and $_.txt.Trim() -ne '<>' } | ForEach-Object { [pscustomobject]@{ sp = $_.s + ':' + $_.space; layer = $_.layer; t = $_.t; x = [int]$_.x; y = [int]$_.y; txt = (& $clean $_.txt) } }
$txt | Sort-Object sp, layer, @{e='y';Descending=$true}, x | ForEach-Object { "{0}`t{1}`t{2}`t{3},{4}`t{5}" -f $_.sp, $_.layer, $_.t, $_.x, $_.y, $_.txt } | Out-File $Out -Encoding utf8
"text entities written: $(@($txt).Count)"
