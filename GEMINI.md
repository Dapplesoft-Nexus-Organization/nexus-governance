# Nexus Governance: Master Knowledge Base & Agent Guidelines (`GEMINI.md`)

This document serves as the master reference, binding policy specification, and mandatory instruction set for any AI assistant (Antigravity, Gemini, Cursor, Copilot) and developer working on `nexus-governance`.

---

## 1. Ecosystem Context & Multi-Repository Boundary

This repository is an **independent, declarative policy-as-code component** of the **Dapplesoft Nexus Ecosystem** (`Dapplesoft-Nexus-Organization`).

### Repository Responsibility & Scope

| What Belongs Here (`nexus-governance`) | What Belongs in Other Repositories |
|---|---|
| • Declarative risk policies (R0–R3 risk thresholds, hard-deny rules)<br>• Role and capability authorization matrices (`auth-matrix.yaml`)<br>• Tool allow-lists & compute quotas (`rate-limits.yaml`)<br>• Immutable, Git-versioned system & agent prompts<br>• Task-type deterministic YAML templates (`task-templates/`)<br>• Architecture Decision Records (ADRs) & STRIDE threat models | • **Executable Web Console & Core API**: Belongs in `dapplesoft-nexus`<br>• **Device Agents (Windows/Linux)**: Belongs in `nexus-device-agent`<br>• **Browser Sandboxes / Containers**: Belongs in `nexus-computer-use`<br>• **Model Evaluation & Trajectory Curation**: Belongs in `nexus-learning`<br>• **Production Compose & Runbooks**: Belongs in `nexus-deployment` |

---

## 2. Universal AI Git & Commit Policy (STRICT - MUST FOLLOW)

### A. Never Commit (`git commit` is FORBIDDEN for AI)
- The AI assistant **MUST NEVER** execute `git commit`.
- All policy rules, templates, prompts, and newly created files must remain **locally uncommitted** in the git working tree.
- The user will personally inspect the diffs, verify all changes in GitHub Desktop / Git CLI, and execute `git commit` manually.

### B. Never Push (`git push` is FORBIDDEN for AI)
- The AI assistant **MUST NEVER** execute `git push` to `origin` or any remote repository.
- Never publish branches or code online to GitHub. All modifications must stay strictly in the local workspace.

### C. Git Branching & Naming Standards
- **Feature Branch Prefix**: MUST use the full prefix **`feature/`** (lowercase), followed by kebab-case (e.g., `feature/risk-matrix-rules`, `feature/prompt-versioning-v1`). Never use shorthand `feat/`.
- **Bugfix Branch Prefix**: Use `fix/<issue-name>` or `feature/<issue-name>`.
- **Base Branch**: Every feature or fix branch MUST branch directly off **`dev`** (never from `main`).
- **Workflow**: Branch off `dev` -> Perform work -> Leave changes uncommitted for user review -> User manually commits -> User pushes to `origin/feature/<branch-name>` -> PR targets `dev`.

### D. Mandatory Self-Updating Documentation Policy (Zero-Forgotten Rule)
- Whenever policy rules, prompt templates, or ADRs are added or modified, immediately update `AGENTS.md` and `GEMINI.md`.

### E. Mandatory Prohibition on Automated Browser Testing (STRICT ZERO BROWSER TEST RULE)
- **Automated Browser Testing Strictly Forbidden**: The AI assistant **MUST NEVER** launch automated browser subagents or headless test sessions.
- **Code-Level Verification Only**: All verification must be performed strictly at the **code level** (YAML syntax linting, JSON schema validation).

---

## 3. Directory Structure

```text
nexus-governance/
├── policies/
│   ├── risk-rules.yaml         # Hard risk thresholds (Low, Medium, High, Critical)
│   ├── auth-matrix.yaml        # Role & Capability permissions
│   └── rate-limits.yaml        # Token and compute quotas
├── task-templates/
│   ├── deployment.yaml         # Deterministic workflow for deployment
│   ├── data-migration.yaml     # Deterministic workflow for migrations
│   └── code-audit.yaml         # Deterministic workflow for audits
├── prompts/
│   ├── system/                 # Versioned system prompts for orchestrator
│   └── task-specific/          # Task-tailored prompt templates
├── adrs/                       # Architectural Decision Records (Markdown)
├── threat-models/              # System STRIDE threat models
├── schemas/                    # JSON Schemas validating YAML definitions
└── docs/                       # Architecture & planning documentation
```
