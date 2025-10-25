# Git Cleaner CLI Tool
# This script provides a command-line interface for managing Git repository cleaning.

# Configuration paths
$configDir = "$env:USERPROFILE\Documents\git-cleaner"
$configPath = "$configDir\config.json"

# Function definitions

function Get-Config {
    # Check if config file exists, if not initialize it
    if (-not (Test-Path -Path $configPath)) {
        Write-Host "Configuration file not found. Generating default configuration..." -ForegroundColor Yellow
        Initialize-Config
        Write-Host "Configuration generated successfully!" -ForegroundColor Green
    }
    
    $jsonConfig = Get-Content -Path $configPath | ConvertFrom-Json
    return $jsonConfig
}

function Initialize-Config {
    $defaultConfig = @{
        folders = $null
        targets = @(
            "node_modules",
            "dist",
            "build",
            "coverage",
            "__pycache__",
            ".pytest_cache",
            ".cache",
            "tmp",
            "logs",
            ".next",
            ".nuxt",
            ".output",
            "target",
            "out",
            ".gradle",
            "bin",
            "obj",
            ".terraform",
            ".serverless",
            "vendor",
            ".bundle",
            ".meteor",
            ".turbo",
            ".nx"
        )
    }
    
    if (-not (Test-Path -Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
    
    $defaultConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $configPath -Encoding UTF8
    $normalizedPath = (Resolve-Path $configPath).Path
    Write-Host "Configuration file initialized at $normalizedPath" -ForegroundColor Green
}

function Save-Config {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$ConfigData
    )
    
    # Save to config file
    $ConfigData | ConvertTo-Json -Depth 10 | Set-Content -Path $configPath -Encoding UTF8
}

function Add-Folder {
    [CmdletBinding()]
    param(
        [Alias('p')]
        [string]$Path
    )
    
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
        $status = if (Test-Path -Path $folder -PathType Container) { "Accessible" } else { "Not Accessible" }
        $color = if ($status -eq "Accessible") { "Green" } else { "Red" }
        Write-Host "$($i + 1). $folder" -ForegroundColor White -NoNewline
        Write-Host " [$status]" -ForegroundColor $color
    }
    Write-Host ""
}

function Clear-Folder {
    [CmdletBinding()]
    param(
        [Alias('f')]
        [switch]$Force
    )

    # Load and merge configuration settings
    $config = Get-Config
    $folders = $config.folders
    $targets = $config.targets

    if (-not $folders -or $folders.Count -eq 0) {
        Write-Host "No folders are configured for cleaning." -ForegroundColor Yellow
        return
    }

    # Collect all target paths to delete from Git repositories
    $targetPaths = [System.Collections.ArrayList]::new()
    foreach ($folder in $folders) {
        # Check if the root folder itself is a git repository
        if (Test-Path (Join-Path $folder ".git")) {
            foreach ($target in $targets) {
                $targetPath = Join-Path $folder $target
                if (Test-Path $targetPath) {
                    $null = $targetPaths.Add($targetPath)
                }
            }
        }
        
        # Also check for nested git repositories
        $gitRepos = Get-ChildItem -Path $folder -Directory -Recurse | Where-Object { Test-Path (Join-Path $_.FullName ".git") }
        foreach ($repo in $gitRepos) {
            foreach ($target in $targets) {
                $targetPath = Join-Path $repo.FullName $target
                if (Test-Path $targetPath) {
                    $null = $targetPaths.Add($targetPath)
                }
            }
        }
    }

    if ($targetPaths.Count -eq 0) {
        Write-Host "No paths found to delete." -ForegroundColor Yellow
        return
    }

    Write-Host "The following paths will be deleted:" -ForegroundColor Cyan
    foreach ($targetPath in $targetPaths) {
        Write-Host "  $targetPath" -ForegroundColor White
    }

    if (-not $Force) {
        $confirmation = Read-Host "Are you sure you want to delete these paths? (y/n)"
        if ($confirmation -ne "y") {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
            return
        }
    }

    $removedCount = 0
    foreach ($targetPath in $targetPaths) {
        try {
            Remove-Item -Path $targetPath -Recurse -Force
            Write-Host "Removed: $targetPath" -ForegroundColor Green
            $removedCount++
        }
        catch {
            Write-Host "Error removing '$targetPath': $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "`nCleaning completed! Removed $removedCount items." -ForegroundColor Green
}

# CLI Logic
if ($args.Count -eq 0) {
    Write-Host "Git Cleaner CLI Tool" -ForegroundColor Cyan
    Write-Host "Usage: gitcleaner <command> [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  af  Add-Folder     - Add a folder to clean"
    Write-Host "  cf  Clear-Folder   - Clean configured folders"
    Write-Host "  gf  Get-Folders    - List configured folders"
    Write-Host "  rf  Remove-Folder  - Remove a folder from config"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  gitcleaner af -Path 'C:\Projects'"
    Write-Host "  gitcleaner cf -Force"
    Write-Host "  gitcleaner gf"
    Write-Host "  gitcleaner rf -Path 'C:\Projects'"
    exit
}

$command = $args[0]
$remainingArgs = if ($args.Count -gt 1) { $args[1..($args.Count-1)] } else { @() }

switch ($command) {
    'af' { Add-Folder @remainingArgs }
    'cf' { Clear-Folder @remainingArgs }
    'gf' { Get-Folders }
    'rf' { Remove-Folder @remainingArgs }
    default { 
        Write-Host "Unknown command: $command" -ForegroundColor Red
        Write-Host "Run 'gitcleaner' without arguments to see available commands." -ForegroundColor Yellow
    }
}