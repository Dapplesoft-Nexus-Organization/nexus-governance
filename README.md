# Nexus Governance

Declarative policy-as-code repository storing all operational guidelines, deterministic workflow blueprints, and governance rules.

## Core Contents
- **Workflow Templates:** Schema-validated task structures turning ambiguous requests into deterministic execution steps.
- **Policy Sets:** Multi-tier authorization rules (Hard-deny, Data-class restriction, Environment gating).
- **Prompt Registry:** Immutable, git-versioned system prompts with pinned model configurations.
- **Architecture Decision Records (ADRs):** Formal records documenting every engineering decision.

## Directory Structure
```text
nexus-governance/
├── policies/
│   ├── data-classification.yaml
│   └── tool-allowlists.yaml
├── workflows/
│   └── templates/
├── prompts/
│   ├── system/
│   └── agents/
├── adrs/
└── threat-models/
```
