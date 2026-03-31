$in  = "D:\RabbitMQ\log\rabbit@m-cactrns04100.log"
$outDir = "D:\RabbitMQ\log\log_chunks"
$chunkSize = 50MB

New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$enc = [System.Text.Encoding]::UTF8
$part = 1
$bytes = 0
$writer = $null

function New-Writer($part) {
  $path = Join-Path $outDir ("big.log.part{0:D4}.log" -f $part)
  return New-Object System.IO.StreamWriter($path, $false, $enc)
}

$writer = New-Writer $part

Get-Content -LiteralPath $in -ReadCount 1000 | ForEach-Object {
  foreach ($line in $_) {
    $lineBytes = $enc.GetByteCount($line + "`r`n")
    if ($bytes -gt 0 -and ($bytes + $lineBytes) -gt $chunkSize) {
      $writer.Dispose()
      $part++
      $writer = New-Writer $part
      $bytes = 0
    }
    $writer.WriteLine($line)
    $bytes += $lineBytes
  }
}

$writer.Dispose()
