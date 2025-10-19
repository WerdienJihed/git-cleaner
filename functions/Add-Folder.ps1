<#
.SYNOPSIS
    Adds a new folder to the Git Cleaner configuration.
.DESCRIPTION
    Prompts user for a folder path and adds it to the folders list in the configuration.
.EXAMPLE
    Add-Folder
    Prompts for folder path and adds it to configuration.
.EXAMPLE
    Add-Folder -Path "C:\Projects"
    Adds the specified folder path directly without prompting.
.EXAMPLE
    af -Path "C:\Projects"
    Uses the alias to add the specified folder path.
.EXAMPLE
    Add-Folder -p "C:\Projects"
    Uses the parameter alias 'p' for Path to add the specified folder path.
.NOTES
    Alias: af
    Parameter aliases: p (for Path)
#>
function Add-Folder {
    [CmdletBinding()]
    param(
        [Alias('p')]
        [string]$Path
    )
    # ...existing code...
    if (-not $Path) {
        $Path = Read-Host "Enter the folder path to add"
    }

    if (-not (Test-Path -Path $Path -PathType Container)) {
        Write-Host "Error: Folder '$Path' does not exist or is not accessible." -ForegroundColor Red
        return
    }

    $config = Get-Config
    $folders = @($config.folders | Where-Object { $_ })

    if ($folders -contains $Path) {
        Write-Host "This folder is already in the configuration." -ForegroundColor Yellow
        return
    }

    $folders += $Path
    $config.folders = @($folders)
    
    Save-Config -ConfigData $config
    Write-Host "Folder '$Path' added successfully!" -ForegroundColor Green
}