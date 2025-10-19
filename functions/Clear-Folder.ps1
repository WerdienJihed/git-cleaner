<#
.SYNOPSIS
    Cleans Git repositories by removing specified target folders.
.DESCRIPTION
    This script scans configured folders for git repositories, identifies target directories to clean,
    prompts for user confirmation, and removes them recursively.
.EXAMPLE
    Clear-Folder
    Scans repositories and prompts for confirmation before deleting target folders.
.EXAMPLE
    Clear-Folder -Force
    Scans repositories and deletes target folders without prompting for confirmation.
.EXAMPLE
    cf
    Uses the alias to scan repositories and clean folders.
.EXAMPLE
    cf -Force
    Uses the alias to clean folders without confirmation.
.EXAMPLE
    Clear-Folder -f
    Uses the parameter alias 'f' for Force to clean folders without confirmation.
.EXAMPLE
    cf -f
    Uses both function and parameter aliases to clean folders without confirmation.
.NOTES
    Alias: cf
    Parameter aliases: f (for Force)
#>
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
        Write-Host "No paths found to delete."
        return
    }

    Write-Host "The following paths will be deleted:"
    foreach ($targetPath in $targetPaths) {
        Write-Host $targetPath
    }

    if (-not $Force) {
        $confirmation = Read-Host "Are you sure you want to delete these paths? (y/n)"
        if ($confirmation -ne "y") {
            Write-Host "Operation cancelled."
            return
        }
    }

    foreach ($targetPath in $targetPaths) {
        Remove-Item -Path $targetPath -Recurse -Force
    }
}