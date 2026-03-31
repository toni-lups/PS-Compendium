# generate a dummy log file in the current dir (for testing log chunker)

param(
    [int] $SizeMB = 10
)

$targetBytes =  $SizeMB * 1MB
$chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
$random = [System.Random]::new()
$out = "dummy.log"

$sw = [System.IO.StreamWriter] $out
$writtenBytes = 0

try {
    $lineCount = 0

    while ($writtenBytes -lt $targetBytes) {
        ++$lineCount

        # generate random line of text (120 chars long)
        $line = -join (1..120 | ForEach-Object { 
            $chars[$random.Next(0, $chars.Length)] 
        })
        $line = $line.Insert(0, "[Itr $lineCount] ")

        $sw.WriteLine($line)
        $writtenBytes += [System.Text.Encoding]::UTF8.GetByteCount($line + "`r`n")

        # update progress bar
        if ($lineCount % 100 -eq 0) {
            $percentProgress = [math]::Min(100, ($writtenBytes / $targetBytes) * 100)

            Write-Progress `
                -Activity "Generating dummy log file" `
                -Status ("{0:N2} MB / {1} MB" -f ($writtenBytes / 1MB), ($SizeMB)) `
                -PercentComplete $percentProgress
        }
    }
}
finally {
    $sw.Close()

    Write-Progress -Activity "Generating dummy log file" -Completed
    Write-Host "File saved: $out"
}
