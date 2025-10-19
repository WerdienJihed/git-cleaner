<#
.SYNOPSIS
    Removes a folder from the Git Cleaner configuration.
.DESCRIPTION
    Removes the specified folder path from the configuration.
.PARAMETER Path
    The specific folder path to remove from the configuration.
.EXAMPLE
    Remove-Folder -Path "C:\Projects"
    Removes the specified folder path from the configuration.
.EXAMPLE
    Remove-Folder -p "C:\Projects"
    Uses the parameter alias 'p' for Path to remove the specified folder.
.EXAMPLE
    rf -Path "C:\Projects"
    Uses the function alias to remove the specified folder path.
.EXAMPLE
    rf -p "C:\Projects"
    Uses both function and parameter aliases to remove a specific folder.
.NOTES
    Alias: rf
    Parameter aliases: p (for Path)
#>
function Remove-Folder {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Alias('p')]
        [string]$Path
    )

    $config = Get-Config
    $folders = $config.folders

    if (-not $folders -or $folders.Count -eq 0) {
        Write-Host "No folders are currently configured." -ForegroundColor Yellow
        return
    }

    if ($folders -notcontains $Path) {
        Write-Host "Error: Folder '$Path' is not in the configuration." -ForegroundColor Red
        return
    }
    
    $folders = @($folders | Where-Object { $_ -ne $Path })
    if ($folders.Count -eq 0) {
        $config.folders = $null
    }
    else {
        $config.folders = $folders
    }
    Save-Config -ConfigData $config
    Write-Host "Folder '$Path' removed successfully!" -ForegroundColor Green
}