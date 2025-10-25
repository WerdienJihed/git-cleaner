# Git Cleaner

A PowerShell CLI tool to clean up common build artifacts and cache directories from Git repositories.

## Installation

Run the following command in PowerShell to install:

```powershell
iex (irm 'https://raw.githubusercontent.com/WerdienJihed/git-cleaner/main/install.ps1')
```

This will prompt you for an installation directory (default: `~\bin\`), then:

- Download the `gitcleaner.ps1` script to the chosen directory
- Add the directory to your user PATH
- Restart your PowerShell session to use the new PATH

## Usage

After installation, use the tool with subcommands:

```powershell
gitcleaner <command> [options]
```

### Commands

- `af` (Add-Folder) - Add a folder to the cleaning configuration
- `cf` (Clear-Folder) - Clean all configured folders
- `gf` (Get-Folders) - List configured folders
- `rf` (Remove-Folder) - Remove a folder from the configuration

### Examples

```powershell
# Add a folder to clean
gitcleaner af -Path "C:\Projects"

# Clean all configured folders (with confirmation)
gitcleaner cf

# Clean without confirmation
gitcleaner cf -Force

# List configured folders
gitcleaner gf

# Remove a folder
gitcleaner rf -Path "C:\Projects"
```

## Configuration

The tool stores configuration in a `config` subfolder next to the script (e.g., `~\bin\config\config.json` if installed in `~\bin\`), which includes:

- `folders`: List of directories to scan for Git repos
- `targets`: List of directories/files to clean (e.g., node_modules, dist, etc.)

The configuration is created automatically on first use.

## How it works

The tool scans configured folders for Git repositories and removes common build/cache directories like:

- node_modules
- dist
- build
- **pycache**
- .next
- And many more (see config.json)

It only removes directories that exist and provides confirmation before deletion (unless `-Force` is used).
