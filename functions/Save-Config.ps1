<#
.SYNOPSIS
    Saves configuration data to the configuration file.
.DESCRIPTION
    Saves the provided configuration object to config.json.
.PARAMETER ConfigData
    The configuration object to save.
#>
function Save-Config {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$ConfigData
    )
    
    $configPath = "$PSScriptRoot/../config/config.json"
    
    # Save to config file
    $ConfigData | ConvertTo-Json -Depth 10 | Set-Content -Path $configPath -Encoding UTF8
}