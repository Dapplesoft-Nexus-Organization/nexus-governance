@echo off
setlocal enabledelayedexpansion

echo ==============================================================================
echo   Dapplesoft Nexus Organization - Local Repository Initializer
echo ==============================================================================
echo.

:: Resolve parent directory (Dapplesoft-Nexus-Organization)
for %%i in ("%~dp0..\..") do set "ROOT_DIR=%%~fi"

set "REPOS=nexus-contracts nexus-core nexus-web nexus-governance nexus-ai-orchestrator nexus-device-agent nexus-computer-use nexus-learning nexus-infra"

for %%R in (%REPOS%) do (
    echo [%%R] Checking Git repository...
    if exist "%ROOT_DIR%\%%R" (
        pushd "%ROOT_DIR%\%%R"
        if not exist ".git" (
            git init -b main
            git remote add origin https://github.com/Dapplesoft-Nexus-Organization/%%R.git
            echo   ^> Git initialized and remote origin linked: https://github.com/Dapplesoft-Nexus-Organization/%%R.git
        ) else (
            echo   ^> Already a git repository. Ensuring remote is set...
            git remote set-url origin https://github.com/Dapplesoft-Nexus-Organization/%%R.git 2>nul || git remote add origin https://github.com/Dapplesoft-Nexus-Organization/%%R.git
        )
        popd
    ) else (
        echo   ^> Directory %%R not found at %ROOT_DIR%!
    )
    echo.
)

echo ==============================================================================
echo   All 9 repositories initialized locally!
echo   You can now open GitHub Desktop, click 'File' -> 'Add local repository',
echo   and publish them directly to https://github.com/Dapplesoft-Nexus-Organization
echo ==============================================================================
echo.
pause
