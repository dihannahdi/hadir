# generate_icon.ps1
# Generates the Hadir app icon (1024x1024) using .NET System.Drawing
# Run: powershell -ExecutionPolicy Bypass -File generate_icon.ps1

Add-Type -AssemblyName System.Drawing

$size   = 1024
$cx     = $size / 2         # 512 — center X
$cy     = $size / 2 - 30    # 482 — center Y (slightly above mid)
$outDir = "$PSScriptRoot\Hadir.swiftpm\Sources\Assets.xcassets\AppIcon.appiconset"
$outFile = "$outDir\AppIcon-1024.png"

# ── Canvas ───────────────────────────────────────────────────────────────────
$bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode         = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode     = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.TextRenderingHint     = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.CompositingQuality    = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

# ── Background: diagonal gradient  #054030 (top-left) → #0D6B4F (bottom-right) ────────────
$ptA = New-Object System.Drawing.PointF(0, 0)
$ptB = New-Object System.Drawing.PointF($size, $size)
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $ptA, $ptB,
    [System.Drawing.Color]::FromArgb(255, 5, 64, 48),
    [System.Drawing.Color]::FromArgb(255, 16, 124, 91)
)
$g.FillRectangle($bgBrush, 0, 0, $size, $size)
$bgBrush.Dispose()

# ── Subtle inner glow disc ────────────────────────────────────────────────────
$gr = 360
$glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse([float]($cx - $gr), [float]($cy - $gr), [float]($gr * 2), [float]($gr * 2))
$glowBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
$glowBrush.CenterPoint = New-Object System.Drawing.PointF([float]$cx, [float]$cy)
$glowBrush.CenterColor = [System.Drawing.Color]::FromArgb(50, 255, 255, 255)
$sc = [System.Drawing.Color[]]@([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
$glowBrush.SurroundColors = $sc
$g.FillEllipse($glowBrush, [float]($cx - $gr), [float]($cy - $gr), [float]($gr * 2), [float]($gr * 2))
$glowBrush.Dispose()
$glowPath.Dispose()

# ── Concentric breathing circles ─────────────────────────────────────────────
# Radii, line widths, opacities — outermost to innermost
$rings = @(
    @{ r=290; w=2.5; a=45 },
    @{ r=220; w=3.5; a=70 },
    @{ r=150; w=5.0; a=110 },
    @{ r=88;  w=7.0; a=160 }
)
foreach ($ring in $rings) {
    $pen = New-Object System.Drawing.Pen(
        [System.Drawing.Color]::FromArgb([int]$ring.a, 247, 243, 238), [float]$ring.w)
    $pen.Alignment = [System.Drawing.Drawing2D.PenAlignment]::Center
    $r = [int]$ring.r
    $g.DrawEllipse($pen, [float]($cx - $r), [float]($cy - $r), [float]($r * 2), [float]($r * 2))
    $pen.Dispose()
}

# ── Heartbeat / EKG waveform ─────────────────────────────────────────────────
$ekg_w   = 340   # half-width of the whole line
$spike_h = 130   # upward spike height
$dip_h   = 55    # downward dip
$pre     = 55    # x-offset of spike start from center

$ekgPoints = New-Object 'System.Drawing.PointF[]' 9
$ekgPoints[0] = [System.Drawing.PointF]::new([float]($cx - $ekg_w),    [float]$cy)
$ekgPoints[1] = [System.Drawing.PointF]::new([float]($cx - $pre - 60), [float]$cy)
$ekgPoints[2] = [System.Drawing.PointF]::new([float]($cx - $pre - 20), [float]($cy + 22))
$ekgPoints[3] = [System.Drawing.PointF]::new([float]($cx - $pre),      [float]$cy)
$ekgPoints[4] = [System.Drawing.PointF]::new([float]($cx - 12),        [float]($cy - $spike_h))
$ekgPoints[5] = [System.Drawing.PointF]::new([float]($cx + 25),        [float]($cy + $dip_h))
$ekgPoints[6] = [System.Drawing.PointF]::new([float]($cx + 90),        [float]($cy - 28))
$ekgPoints[7] = [System.Drawing.PointF]::new([float]($cx + 130),       [float]$cy)
$ekgPoints[8] = [System.Drawing.PointF]::new([float]($cx + $ekg_w),   [float]$cy)
$ekgPen = New-Object System.Drawing.Pen(
    [System.Drawing.Color]::FromArgb(230, 247, 243, 238), 11)
$ekgPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$ekgPen.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
$ekgPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$g.DrawLines($ekgPen, $ekgPoints)
$ekgPen.Dispose()

# ── Center pulse dot ──────────────────────────────────────────────────────────
$dotR = 22
$dotBrush = New-Object System.Drawing.SolidBrush(
    [System.Drawing.Color]::FromArgb(255, 247, 243, 238))
$g.FillEllipse($dotBrush, [float]($cx - $dotR), [float]($cy - $dotR), [float]($dotR * 2), [float]($dotR * 2))
$dotBrush.Dispose()

# ── "hadir" text ──────────────────────────────────────────────────────────────
$fontCandidates = @("SF Pro Rounded", "Arial Rounded MT Bold", "Trebuchet MS", "Arial")
$chosenFont = "Arial"
$availableFamilies = [System.Drawing.FontFamily]::Families | ForEach-Object { $_.Name }
foreach ($fc in $fontCandidates) {
    if ($availableFamilies -contains $fc) { $chosenFont = $fc; break }
}

$fontSize    = 96
$font        = New-Object System.Drawing.Font($chosenFont, $fontSize, [System.Drawing.FontStyle]::Bold)
$textBrush   = New-Object System.Drawing.SolidBrush(
    [System.Drawing.Color]::FromArgb(210, 247, 243, 238))

$text     = "hadir"
$textSize = $g.MeasureString($text, $font)
$textX    = ($size - $textSize.Width) / 2
$textY    = $cy + 195

$g.DrawString($text, $font, $textBrush, $textX, $textY)
$font.Dispose()
$textBrush.Dispose()

# ── Tagline ───────────────────────────────────────────────────────────────────
$tagFontSize = 30
$tagFont     = New-Object System.Drawing.Font($chosenFont, $tagFontSize, [System.Drawing.FontStyle]::Regular)
$tagBrush    = New-Object System.Drawing.SolidBrush(
    [System.Drawing.Color]::FromArgb(130, 247, 243, 238))

$tagText  = "AI Clinical Companion"
$tagSize  = $g.MeasureString($tagText, $tagFont)
$tagX     = ($size - $tagSize.Width) / 2
$tagY     = $textY + $fontSize + 8

$g.DrawString($tagText, $tagFont, $tagBrush, $tagX, $tagY)
$tagFont.Dispose()
$tagBrush.Dispose()

# ── Save ──────────────────────────────────────────────────────────────────────
$g.Flush()
$g.Dispose()

$null = New-Item -ItemType Directory -Path $outDir -Force
$bmp.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

Write-Host "OK Icon saved: $outFile" -ForegroundColor Green
$fileSizeKB = [int](([System.IO.FileInfo]$outFile).Length / 1024)
Write-Host "  Size: ${fileSizeKB} KB" -ForegroundColor Gray
