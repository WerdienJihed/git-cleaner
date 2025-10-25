# Install script for Git Cleaner CLI Tool

# Prompt for installation path with default
$defaultPath = Join-Path $env:USERPROFILE "bin"
$installPath = Read-Host "Enter the installation directory (press Enter for default: $defaultPath)"
if ([string]::IsNullOrWhiteSpace($installPath)) {
    $installPath = $defaultPath
}

# Ensure the directory exists
if (!(Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    Write-Host "Created directory: $installPath" -ForegroundColor Green
}

# Download the script
Write-Host "Downloading gitcleaner.ps1..." -ForegroundColor Cyan
try {
    $scriptUrl = "https://raw.githubusercontent.com/WerdienJihed/git-cleaner/main/gitcleaner.ps1"
    $scriptPath = Join-Path $installPath "gitcleaner.ps1"
    Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath -ErrorAction Stop
    Write-Host "Downloaded to: $scriptPath" -ForegroundColor Green
} catch {
    Write-Host "Error downloading script: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Add to PATH if not already
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath -notlike "*$installPath*") {
    $newPath = "$userPath;$installPath"
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "Added $installPath to user PATH." -ForegroundColor Green
    Write-Host "Please restart your PowerShell session for PATH changes to take effect." -ForegroundColor Yellow
} else {
    Write-Host "$installPath is already in PATH." -ForegroundColor Green
}

Write-Host ""
Write-Host "Installation completed!" -ForegroundColor Green
Write-Host "You can now use: gitcleaner <command>" -ForegroundColor Cyan
Write-Host "Run 'gitcleaner' for help." -ForegroundColor Cyan