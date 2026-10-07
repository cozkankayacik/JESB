param([string]$Pdf, [string]$Dir)
# Heuristic text extraction: merge ToUnicode cmaps by family, decode hex Tj strings per stream.
$latin = [System.Text.Encoding]::GetEncoding(28591)
$bytes = [System.IO.File]::ReadAllBytes($Pdf)
$text = $latin.GetString($bytes)

function Parse-CMap([string]$c) {
    $map = @{}
    foreach ($blk in [regex]::Matches($c, 'beginbfchar(.*?)endbfchar', 'Singleline')) {
        foreach ($m in [regex]::Matches($blk.Groups[1].Value, '<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>')) {
            $map[[Convert]::ToInt32($m.Groups[1].Value,16)] = [string][char][Convert]::ToInt32($m.Groups[2].Value.Substring(0,4),16)
        }
    }
    foreach ($blk in [regex]::Matches($c, 'beginbfrange(.*?)endbfrange', 'Singleline')) {
        foreach ($m in [regex]::Matches($blk.Groups[1].Value, '<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>')) {
            $a=[Convert]::ToInt32($m.Groups[1].Value,16); $b=[Convert]::ToInt32($m.Groups[2].Value,16); $u=[Convert]::ToInt32($m.Groups[3].Value,16)
            for ($k=$a; $k -le $b; $k++) { $map[$k] = [string][char]($u + $k - $a) }
        }
    }
    return $map
}

# collect uncompressed cmaps
$cmaps = @()
foreach ($m in [regex]::Matches($text, 'begincmap.*?endcmap', 'Singleline')) { $cmaps += ,(Parse-CMap $m.Value) }
"cmaps found: $($cmaps.Count)"
# cluster into consistent families
$fams = @()
foreach ($c in $cmaps) {
    $placed = $false
    foreach ($f in $fams) {
        $ok = $true
        foreach ($k in $c.Keys) { if ($f.ContainsKey($k) -and $f[$k] -ne $c[$k]) { $ok = $false; break } }
        if ($ok) { foreach ($k in $c.Keys) { $f[$k] = $c[$k] }; $placed = $true; break }
    }
    if (-not $placed) { $fams += ,($c.Clone()) }
}
"families: $($fams.Count) sizes: " + (($fams | ForEach-Object { $_.Count }) -join ',')

function Decode([string]$hex, $map) {
    $sb = New-Object System.Text.StringBuilder; $miss = 0
    for ($i=0; $i+4 -le $hex.Length; $i+=4) {
        $g = [Convert]::ToInt32($hex.Substring($i,4),16)
        if ($map.ContainsKey($g)) { [void]$sb.Append($map[$g]) } else { [void]$sb.Append('?'); $miss++ }
    }
    return @($sb.ToString(), $miss)
}

$files = Get-ChildItem "$Dir\s*.bin" | Sort-Object { [int]($_.BaseName.Substring(1)) }
foreach ($f in $files) {
    $c = $latin.GetString([IO.File]::ReadAllBytes($f.FullName))
    if ($c -notmatch 'Tj') { continue }
    # tokens: font switches and text
    $toks = [regex]::Matches($c, '/(F\d+)\s+[\d.]+\s+Tf|<([0-9A-Fa-f]+)>\s*Tj')
    # choose family per font by voting
    $byFont = @{}
    $cur = 'F?'
    $seq = @()
    foreach ($t in $toks) {
        if ($t.Groups[1].Success) { $cur = $t.Groups[1].Value } else {
            if (-not $byFont.ContainsKey($cur)) { $byFont[$cur] = @() }
            $byFont[$cur] += $t.Groups[2].Value
            $seq += ,@($cur, $t.Groups[2].Value)
        }
    }
    $pick = @{}
    foreach ($fn in $byFont.Keys) {
        $best = $null; $bestScore = -1e9
        foreach ($fam in $fams) {
            $score = 0
            foreach ($h in $byFont[$fn]) {
                $r = Decode $h $fam
                $score -= 5 * $r[1]
                $score += ([regex]::Matches($r[0], '[A-Za-z0-9 ]')).Count
                $score -= 2 * ([regex]::Matches($r[0], '[^\x20-\x7E]')).Count
                $score += 3 * ([regex]::Matches($r[0], '(?i)\b(the|and|of|floor|wall|roof|plan|to|for|all|be|shall|with)\b')).Count
            }
            if ($score -gt $bestScore) { $bestScore = $score; $best = $fam }
        }
        $pick[$fn] = $best
    }
    "===== $($f.Name) ====="
    foreach ($s in $seq) { (Decode $s[1] $pick[$s[0]])[0] }
}
