param(
  [Parameter(Mandatory, HelpMessage = 'Supply a log file')]
  [ValidateScript({(Test-Path $_ -PathType Leaf) -and ('.log', '.txt', '.json') -icontains [System.IO.Path]::GetExtension($_)})]
  [string] $LogPath,

  [ValidateRange(1, 500)]
  [int] $ChunkSizeMB = 50
)

if ((Get-Item $LogPath).length / 1MB -le $ChunkSizeMB) {
  Write-Host "Supplied file is smaller than configured chunk size ($ChunkSizeMB MB), exiting ..."; exit 0
}

$outDir = "$(Split-Path $LogPath -Parent)\LogChunks"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$enc = [System.Text.Encoding]::UTF8
$currChunkBytes = 0
$script:chunkNum = 1

function Get-ChunkWriter {
  $path = Join-Path $outDir ("big.log.part{0:D4}.log" -f $script:chunkNum)
  $script:chunkNum++

  return [System.IO.StreamWriter]::new($path, $false, $enc)
}

$writer = Get-ChunkWriter
Get-Content -LiteralPath $LogPath -ReadCount 1000 | ForEach-Object {
  foreach ($line in $_) {
    $lineBytes = $enc.GetByteCount($line + "`r`n")

    if (($currChunkBytes -gt 0) -and ($currChunkBytes + $lineBytes) -gt $ChunkSizeMB * 1MB) {
      $writer.Dispose()
      
      $writer = Get-ChunkWriter
      $currChunkBytes = 0
    }

    $writer.WriteLine($line)
    $currChunkBytes += $lineBytes
  }
}

$writer.Dispose()
