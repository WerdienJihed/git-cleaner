<#
.SYNOPSIS
    Loads the configuration.
.DESCRIPTION
    Loads settings from config.json. If the file doesn't exist, calls Initialize-Config to create it.
.OUTPUTS
    PSCustomObject containing the configuration.
#>
function Get-Config {
    $configPath = "$PSScriptRoot/../config/config.json"
    
    # Check if config file exists, if not initialize it
    if (-not (Test-Path -Path $configPath)) {
        Write-Host "Configuration file not found. Generating default configuration..." -ForegroundColor Yellow
        Initialize-Config
        Write-Host "Configuration generated successfully!" -ForegroundColor Green
    }
    
    $jsonConfig = Get-Content -Path $configPath | ConvertFrom-Json
    return $jsonConfig
}

