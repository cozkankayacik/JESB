param([string]$Pdf, [string]$Out)
New-Item -ItemType Directory -Force $Out | Out-Null
$bytes = [System.IO.File]::ReadAllBytes($Pdf)
$latin = [System.Text.Encoding]::GetEncoding(28591)
$text = $latin.GetString($bytes)
"Size: $($bytes.Length)  Header: $($text.Substring(0,8))"
"Pages (/Type /Page): " + ([regex]::Matches($text, '/Type\s*/Page[^s]')).Count
foreach ($m in [regex]::Matches($text, '/(Producer|Creator|Title|Author|CreationDate|ModDate)\s*\(([^)]*)\)')) { $m.Value }
foreach ($m in [regex]::Matches($text, '/MediaBox\s*\[[^\]]*\]') | Select-Object -First 10) { $m.Value }

$rx = [regex]'stream\r?\n'
$i = 0; $imgN = 0; $txtN = 0
$all = New-Object System.Text.StringBuilder
foreach ($m in $rx.Matches($text)) {
    $start = $m.Index + $m.Length
    $end = $text.IndexOf('endstream', $start)
    if ($end -lt 0) { continue }
    $dictStart = $text.LastIndexOf('<<', $m.Index)
    $objStart = $text.LastIndexOf(' obj', $m.Index)
    $dict = $text.Substring([Math]::Max(0,$objStart), $m.Index - [Math]::Max(0,$objStart))
    $len = $end - $start
    $i++
    if ($dict -match '/DCTDecode') {
        $imgN++
        [System.IO.File]::WriteAllBytes((Join-Path $Out "img$imgN.jpg"), $bytes[$start..($end-1)])
        "IMG $imgN jpg len=$len dict=" + ($dict -replace '\s+',' ').Substring(0, [Math]::Min(200, $dict.Length))
        continue
    }
    if ($dict -match '/FlateDecode') {
        try {
            $ms = [System.IO.MemoryStream]::new($bytes, $start+2, $len-2)
            $ds = New-Object System.IO.Compression.DeflateStream($ms, [System.IO.Compression.CompressionMode]::Decompress)
            $o = New-Object System.IO.MemoryStream
            $ds.CopyTo($o)
            $raw = $o.ToArray()
            $isImg = $dict -match '/Subtype\s*/Image'
            "STREAM $i flate in=$len out=$($raw.Length) img=$isImg dict=" + (($dict -replace '\s+',' ').Substring(0, [Math]::Min(160, $dict.Length)))
            if (-not $isImg) {
                $txtN++
                [System.IO.File]::WriteAllBytes((Join-Path $Out "s$i.bin"), $raw)
            }
        } catch { "STREAM $i flate FAILED len=$len" }
    } else {
        "STREAM $i other len=$len dict=" + (($dict -replace '\s+',' ').Substring(0, [Math]::Min(160, $dict.Length)))
    }
}

