@echo off
setlocal enabledelayedexpansion

echo ==============================================================================
echo   Dapplesoft Nexus - User Manual Commit ^& Push Helper
echo   (Strictly reserved for human developer execution)
echo ==============================================================================
echo.
echo This script will stage all local files, commit them as:
echo   "feat: initial repository setup with eShop ^& srv master guidelines"
echo and push them to origin/main for all 9 Nexus repositories.
echo.
echo Target Organization: https://github.com/Dapplesoft-Nexus-Organization
echo.
set /p CONFIRM="Are you sure you want to commit and push all 9 repositories? (y/N): "
if /i not "!CONFIRM!"=="y" (
    echo [Cancelled] No changes were committed or pushed.
    pause
    exit /b 0
)

echo.
:: Resolve parent directory (Dapplesoft-Nexus-Organization)
for %%i in ("%~dp0..\..") do set "ROOT_DIR=%%~fi"

set "REPOS=nexus-contracts nexus-core nexus-web nexus-governance nexus-ai-orchestrator nexus-device-agent nexus-computer-use nexus-learning nexus-infra"

for %%R in (%REPOS%) do (
    echo ==============================================================================
    echo [%%R] Staging, committing and pushing...
    echo ==============================================================================
    if exist "%ROOT_DIR%\%%R" (
        pushd "%ROOT_DIR%\%%R"
        git add .
        git commit -m "feat: initial repository setup with eShop & srv master guidelines"
        git push -u origin main
        popd
    ) else (
        echo [ERROR] Directory %%R not found at %ROOT_DIR%.
    )
    echo.
)

echo ==============================================================================
echo   Done! All repositories have been pushed to GitHub.
echo   Check your organization at:
echo   https://github.com/orgs/Dapplesoft-Nexus-Organization/repositories
echo ==============================================================================
echo.
pause
