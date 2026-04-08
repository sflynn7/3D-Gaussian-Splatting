# Function to measure and log execution time
function Measure-CommandRunTime {
    param (
        [scriptblock]$ScriptBlock,
        [string]$Description
    )
    $startTime = Get-Date
    try {
	& $ScriptBlock | Out-Null
    } catch {
	Write-Host "Error executing $Description : $_"
    }
    $endTime = Get-Date
    $duration = $endTime - $startTime
    $logEntry = [PSCustomObject]@{
	Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
	Description = $Description
	Duration = "$($duration.Minutes)m $($duration.Seconds)s $($duration.Milliseconds)ms"
	DurationSeconds = [math]::Round($duration.TotalSeconds, 3)
    }
    $logEntry | Export-Csv -Path "times.csv" -Append -NoTypeInformation
    return $duration
}


# Navigate to scene folder and run FFmpeg
Set-Location -Path "C:\Users\Vive2\Desktop\gaussian-splatting\myscene\tea_bottle\input"
Measure-CommandRunTime -Description "FFmpeg Conversion" -ScriptBlock {
    ffmpeg -i C:\Users\Vive2\Desktop\gaussian-splatting\myscene\tea_bottle\tea_bottle.mp4 -qscale:v 1 -qmin 1 -vf fps=2 %04d.jpg
}

# Return to main directory and run convert.py
Set-Location -Path "C:\Users\Vive2\Desktop\gaussian-splatting"
Measure-CommandRunTime -Description "convert.py Execution" -ScriptBlock {
    python convert.py -s "C:\Users\Vive2\Desktop\gaussian-splatting\myscene\tea_bottle"
}

# Run train.py
Set-Location -Path "C:\Users\Vive2\Desktop\gaussian-splatting"
Measure-CommandRunTime -Description "train.py Execution" -ScriptBlock {
    & "C:\Users\Vive2\Miniconda3\python.exe" train.py -s "C:\Users\Vive2\Desktop\gaussian-splatting\myscene\tea_bottle"
}

# Navigate to viewer bin folder and run viewer.exe with the latest model
Set-Location -Path "C:\Users\Vive2\Desktop\gaussian-splatting\viewers\bin"
$latestModel = (Get-ChildItem -Path "C:\Users\Vive2\Desktop\gaussian-splatting\output" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
Measure-CommandRunTime -Description "Viewer Execution" -ScriptBlock {
    SIBR_gaussianViewer_app.exe -m $latestModel
}