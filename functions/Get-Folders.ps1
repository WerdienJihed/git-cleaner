<#
.SYNOPSIS
    Gets all folders configured in the Git Cleaner configuration.
.DESCRIPTION
    Displays all folders with detailed information including their accessibility status.
.EXAMPLE
    Get-Folders
    Displays all configured folders with accessibility status.
.EXAMPLE
    gf
    Uses the alias to display all configured folders.
.NOTES
    Alias: gf
#>
function Get-Folders {
    [CmdletBinding()]
    param()

    $config = Get-Config
    $folders = $config.folders

    if (-not $folders -or $folders.Count -eq 0) {
        Write-Host "No folders are currently configured." -ForegroundColor Yellow
        return
    }

    Write-Host "`nConfigured Folders:" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan

    for ($i = 0; $i -lt $folders.Count; $i++) {
        $folder = $folders[$i]
        $index = $i + 1
        
        if ([string]::IsNullOrWhiteSpace($folder)) {
            continue
        }
        
        $exists = Test-Path -Path $folder -PathType Container
        $status = if ($exists) { "✓ Accessible" } else { "✗ Not Found" }
        $statusColor = if ($exists) { "Green" } else { "Red" }
        
        Write-Host "$index. " -NoNewline -ForegroundColor White
        Write-Host "$folder " -NoNewline -ForegroundColor White
        Write-Host "[$status]" -ForegroundColor $statusColor
    }
    
    Write-Host "`nTotal folders: $($folders.Count)" -ForegroundColor Green
}