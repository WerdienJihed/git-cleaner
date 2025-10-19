<#
.SYNOPSIS
    Initializes the configuration file.
.DESCRIPTION
    Creates config.json with default git_cleaner settings including folders and targets.
    If the file already exists, it will be overwritten.
.EXAMPLE
    Initialize-Config
    Creates or reinitializes the configuration file with default settings.
#>
function Initialize-Config {
    $configPath = "$PSScriptRoot/../config/config.json"
    
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
    
    $configDirectory = Split-Path -Path $configPath -Parent
    if (-not (Test-Path -Path $configDirectory)) {
        New-Item -ItemType Directory -Path $configDirectory -Force | Out-Null
    }
    
    $defaultConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $configPath -Encoding UTF8
    $normalizedPath = (Resolve-Path $configPath).Path
    Write-Host "Configuration file initialized at $normalizedPath" -ForegroundColor Green
}
