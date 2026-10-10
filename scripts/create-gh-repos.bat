@echo off
setlocal enabledelayedexpansion

echo ==============================================================================
echo   Dapplesoft Nexus - Remote Repositories Creation on GitHub
echo   Target Organization: Dapplesoft-Nexus-Organization
echo ==============================================================================
echo.

:: Check GitHub CLI authentication
echo [1/2] Checking GitHub CLI (gh) authentication status...
gh auth status >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [!] You are not currently logged into GitHub CLI.
    echo [*] Launching web browser login for GitHub CLI...
    echo [*] Please press Enter, then follow the browser prompt to authorize.
    echo.
    gh auth login -h github.com -w -p https
    if %errorlevel% neq 0 (
        echo.
        echo [ERROR] Authentication failed or cancelled.
        echo Please run 'gh auth login' manually or use GitHub Desktop.
        pause
        exit /b 1
    )
)

echo [✓] GitHub CLI is authenticated!
echo.
echo [2/2] Creating 9 Public Repositories in Dapplesoft-Nexus-Organization...
echo.

gh repo create Dapplesoft-Nexus-Organization/nexus-contracts --public --description "Single Source of Truth: Protocol Buffers, OpenAPI specs, domain schemas, and SDK generation"
gh repo create Dapplesoft-Nexus-Organization/nexus-core --public --description "Enterprise Core Platform Engine for Dapplesoft Nexus (.NET 10 Modular Monolith, Temporal, Device Control)"
gh repo create Dapplesoft-Nexus-Organization/nexus-web --public --description "Real-time Web Control & Admin Dashboard for Dapplesoft Nexus (Next.js 15, React Flow, xterm.js, noVNC)"
gh repo create Dapplesoft-Nexus-Organization/nexus-governance --public --description "Machine-executable policies, deterministic task-type templates, prompt versions, and ADRs"
gh repo create Dapplesoft-Nexus-Organization/nexus-ai-orchestrator --public --description "Hexagonal AI Orchestration Engine (Python 3.12+, LangGraph) for planning, QA, and resolution ladder"
gh repo create Dapplesoft-Nexus-Organization/nexus-device-agent --public --description "Cross-Platform Execution Agent for Windows and Linux (.NET 10 Worker, GUI Helper, ConPTY)"
gh repo create Dapplesoft-Nexus-Organization/nexus-computer-use --public --description "Sandbox environments (E0 Docker / E1 QEMU VM) and browser execution runners"
gh repo create Dapplesoft-Nexus-Organization/nexus-learning --public --description "Machine learning, knowledge extraction, and offline fine-tuning pipelines"
gh repo create Dapplesoft-Nexus-Organization/nexus-infra --public --description "Infrastructure as Code, Docker Compose stacks, Caddy Gateway, Temporal, and OpenTelemetry"

echo.
echo ==============================================================================
echo   [SUCCESS] All 9 repositories have been created in Dapplesoft-Nexus-Organization!
echo   View online at: https://github.com/orgs/Dapplesoft-Nexus-Organization/repositories
echo ==============================================================================
echo.
pause
