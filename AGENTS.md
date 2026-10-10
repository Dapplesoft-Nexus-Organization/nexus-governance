# Nexus Governance: Master Knowledge Base & Agent Guidelines (`AGENTS.md`)

This document serves as the master reference, binding policy specification, and mandatory instruction set for any AI assistant (Antigravity, Gemini, Cursor, Copilot) and developer working on `nexus-governance`.

---

## 1. Universal AI Git & Commit Policy (STRICT - MUST FOLLOW)

### A. Never Commit (`git commit` is FORBIDDEN for AI)
- The AI assistant **MUST NEVER** execute `git commit`.
- All policy rules, templates, prompts, and newly created files must remain **locally uncommitted** in the git working tree.
- The user will personally inspect the diffs, verify all changes in GitHub Desktop / Git CLI, and execute `git commit` manually.

### B. Never Push (`git push` is FORBIDDEN for AI)
- The AI assistant **MUST NEVER** execute `git push` to `origin` or any remote repository.
- Never publish branches or code online to GitHub. All modifications must stay strictly in the local workspace.

### C. Git Branching & Naming Standards
- **Feature Branch Prefix**: MUST use the full prefix **`feature/`** (lowercase), followed by kebab-case (e.g., `feature/risk-matrix-rules`, `feature/prompt-versioning-v1`).
  - **STRICTLY PROHIBITED**: Never use shorthand prefixes like `feat/`. Always use `feature/`.
- **Bugfix Branch Prefix**: Use `fix/<issue-name>` or `feature/<issue-name>`.
- **Base Branch**: Every feature or fix branch MUST branch directly off **`dev`** (never from `main`).
- **Workflow**: Branch off `dev` -> Perform work -> Leave changes uncommitted for user review -> User manually commits -> User pushes to `origin/feature/<branch-name>` -> PR targets `dev`.

### D. Mandatory Self-Updating Documentation Policy (Zero-Forgotten Rule)
- Whenever policy rules, prompt templates, or ADRs are added or modified, immediately update `AGENTS.md` and `GEMINI.md`.

### E. Mandatory Prohibition on Automated Browser Testing (STRICT ZERO BROWSER TEST RULE)
- **Automated Browser Testing Strictly Forbidden**: The AI assistant **MUST NEVER** launch automated browser subagents or headless test sessions.
- **Code-Level Verification Only**: All verification must be performed strictly at the **code level** (YAML syntax linting, JSON schema validation).

---

## 2. Directory Structure

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
└── schemas/                    # JSON Schemas validating YAML definitions
```

---

## 3. Principles Transferred from eShop & SRV

1. **Mandatory Multi-Tenant Scoping**:
   - Every policy rule must account for multi-tenancy (`tenant_id`), allowing per-tenant customization while preserving platform-wide security baselines.
2. **Permanent Audit Footprint**:
   - In accordance with the SRV audit guidelines, ADRs and security policies are immutable documents. Never overwrite historical records without versioning.
3. **Zero Plaintext Secrets**:
   - Never embed actual API keys or passwords inside prompt templates or policy configurations.

---

## 4. Verification Commands

```bash
# Validate YAML syntax
yamllint policies/ task-templates/

# Validate JSON schema conformance
npx ajv-cli validate -s schemas/policy.schema.json -d "policies/*.yaml"
```

---

*Authorized by Dapplesoft Architecture & Nexus Governance Council*
