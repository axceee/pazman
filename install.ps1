# pazman PowerShell Installer
# Usage: iwr -useb https://raw.githubusercontent.com/axceee/pazman/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

# Configuration
$RepoUrl = "https://raw.githubusercontent.com/axceee/pazman/main/install.ps1"
$InstallDir = "$env:USERPROFILE\.local\bin"
$ScriptName = "pazman"

# Colors
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Print header
function Show-Header {
    Write-Host ""
    Write-ColorOutput "================================" "Cyan"
    Write-ColorOutput "   pazman Password Manager" "Cyan"
    Write-ColorOutput "   Secure CLI Installation" "Cyan"
    Write-ColorOutput "================================" "Cyan"
    Write-Host ""
}

# Check if command exists
function Test-CommandExists {
    param($Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Check prerequisites
function Test-Prerequisites {
    Write-ColorOutput "Checking prerequisites..." "Yellow"
    
    $missingDeps = @()
    
    # Check for Git Bash or WSL (for running bash script)
    $hasGitBash = Test-Path "C:\Program Files\Git\bin\bash.exe"
    $hasWSL = Test-CommandExists "wsl"
    
    if (-not $hasGitBash -and -not $hasWSL) {
        Write-ColorOutput "Warning: Git Bash or WSL not found" "Yellow"
        Write-ColorOutput "pazman requires bash to run. Please install Git for Windows or WSL." "Yellow"
        Write-Host ""
        Write-Host "Install Git for Windows: https://git-scm.com/download/win"
        $missingDeps += "Git Bash or WSL"
    }
    
    # Check for OpenSSL (usually comes with Git Bash)
    if ($hasGitBash) {
        $opensslPath = "C:\Program Files\Git\usr\bin\openssl.exe"
        if (-not (Test-Path $opensslPath)) {
            Write-ColorOutput "Warning: OpenSSL not found in Git Bash" "Yellow"
        }
    }
    
    if ($missingDeps.Count -gt 0) {
        Write-ColorOutput "`nError: Missing required dependencies:" "Red"
        foreach ($dep in $missingDeps) {
            Write-Host "  - $dep"
        }
        Write-ColorOutput "`nPlease install missing dependencies and try again." "Red"
        exit 1
    }
    
    Write-ColorOutput "[OK] Prerequisites met" "Green"
}

# Create installation directory
function New-InstallDir {
    if (-not (Test-Path $InstallDir)) {
        Write-ColorOutput "Creating installation directory: $InstallDir" "Yellow"
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }
}

# Download pazman script
function Get-PazmanScript {
    Write-ColorOutput "Downloading pazman..." "Yellow"
    
    $targetPath = Join-Path $InstallDir $ScriptName
    
    try {
        Invoke-WebRequest -Uri "$RepoUrl/$ScriptName" -OutFile $targetPath -UseBasicParsing
        Write-ColorOutput "[OK] pazman downloaded successfully" "Green"
    } catch {
        Write-ColorOutput "Error: Failed to download pazman" "Red"
        Write-ColorOutput $_.Exception.Message "Red"
        exit 1
    }
}

# Create wrapper batch file for Windows
function New-WrapperScript {
    Write-ColorOutput "Creating Windows wrapper script..." "Yellow"
    
    $batchPath = Join-Path $InstallDir "$ScriptName.bat"
    
    # Determine which bash to use
    $gitBashPath = "C:\Program Files\Git\bin\bash.exe"
    
    $batchContent = @"
@echo off
REM pazman wrapper for Windows
setlocal

set SCRIPT_PATH=%~dp0$ScriptName

if exist "$gitBashPath" (
    "$gitBashPath" "%SCRIPT_PATH%" %*
) else if where wsl >nul 2>&1 (
    wsl bash "%SCRIPT_PATH%" %*
) else (
    echo Error: Git Bash or WSL not found
    echo Please install Git for Windows: https://git-scm.com/download/win
    exit /b 1
)
"@
    
    Set-Content -Path $batchPath -Value $batchContent -Encoding ASCII
    Write-ColorOutput "[OK] Wrapper script created" "Green"
}

# Check if directory is in PATH
function Test-InPath {
    param($Directory)
    $pathParts = $env:PATH -split ';'
    return $pathParts -contains $Directory
}

# Add to PATH
function Add-ToPath {
    if (-not (Test-InPath $InstallDir)) {
        Write-ColorOutput "`nInstallation directory is not in your PATH" "Yellow"
        Write-Host ""
        Write-ColorOutput "Would you like to add it to your PATH? (Y/N)" "Yellow"
        $response = Read-Host
        
        if ($response -match '^[Yy]') {
            try {
                # Add to user PATH
                $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
                $newPath = "$currentPath;$InstallDir"
                [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
                
                # Update current session PATH
                $env:PATH = "$env:PATH;$InstallDir"
                
                Write-ColorOutput "[OK] Added to PATH successfully" "Green"
                Write-ColorOutput "Please restart your PowerShell session for changes to take effect" "Yellow"
            } catch {
                Write-ColorOutput "Failed to add to PATH automatically" "Red"
                Write-ColorOutput "Please add manually: $InstallDir" "Yellow"
            }
        } else {
            Write-Host ""
            Write-ColorOutput "To use pazman, add this directory to your PATH:" "Yellow"
            Write-ColorOutput "  $InstallDir" "Cyan"
            Write-Host ""
            Write-ColorOutput "Or run pazman using the full path:" "Yellow"
            Write-ColorOutput "  $InstallDir\$ScriptName.bat" "Cyan"
        }
    } else {
        Write-ColorOutput "[OK] Installation directory is already in PATH" "Green"
    }
}

# Test installation
function Test-Installation {
    Write-ColorOutput "`nTesting installation..." "Yellow"
    
    $batchPath = Join-Path $InstallDir "$ScriptName.bat"
    
    if (Test-Path $batchPath) {
        if (Test-InPath $InstallDir) {
            Write-ColorOutput "[OK] pazman is ready to use!" "Green"
            Write-Host ""
            Write-ColorOutput "Run 'pazman help' to get started" "Cyan"
        } else {
            Write-ColorOutput "Installation complete, but you need to update your PATH first" "Yellow"
        }
    }
}

# Print success message
function Show-Success {
    Write-Host ""
    Write-ColorOutput "================================" "Green"
    Write-ColorOutput "   Installation Complete!" "Green"
    Write-ColorOutput "================================" "Green"
    Write-Host ""
    Write-ColorOutput "Quick start:" "Cyan"
    Write-Host "  1. Restart PowerShell (if PATH was updated)"
    Write-Host "  2. Run: pazman set github"
    Write-Host "  3. Create your master password"
    Write-Host "  4. Your password is generated and copied!"
    Write-Host ""
    Write-ColorOutput "Documentation:" "Cyan"
    Write-Host "  https://github.com/armancurr/cli-password"
    Write-Host ""
}

# Uninstall function
function Uninstall-Pazman {
    Write-ColorOutput "Uninstalling pazman..." "Yellow"
    
    # Remove scripts
    $scriptPath = Join-Path $InstallDir $ScriptName
    $batchPath = Join-Path $InstallDir "$ScriptName.bat"
    
    if (Test-Path $scriptPath) {
        Remove-Item $scriptPath -Force
        Write-ColorOutput "[OK] Removed pazman script" "Green"
    }
    
    if (Test-Path $batchPath) {
        Remove-Item $batchPath -Force
        Write-ColorOutput "[OK] Removed wrapper script" "Green"
    }
    
    # Ask about data
    Write-Host ""
    $response = Read-Host "Remove stored passwords (~/.pazman)? [y/N]"
    if ($response -match '^[Yy]') {
        $dataDir = Join-Path $env:USERPROFILE ".pazman"
        if (Test-Path $dataDir) {
            Remove-Item $dataDir -Recurse -Force
            Write-ColorOutput "[OK] Removed password data" "Green"
        }
    }
    
    Write-ColorOutput "Uninstallation complete" "Green"
}

# Main installation flow
function Main {
    param($Action)
    
    # Check if uninstall flag is passed
    if ($Action -eq "--uninstall" -or $Action -eq "uninstall") {
        Uninstall-Pazman
        return
    }
    
    Show-Header
    Test-Prerequisites
    New-InstallDir
    Get-PazmanScript
    New-WrapperScript
    Add-ToPath
    Test-Installation
    Show-Success
}

# Run main function
Main $args[0]
