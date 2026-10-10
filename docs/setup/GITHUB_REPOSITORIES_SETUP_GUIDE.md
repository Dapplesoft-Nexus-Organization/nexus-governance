# Dapplesoft Nexus — GitHub Organization Repositories Setup & Verification Guide

GitHub Organization Link: https://github.com/Dapplesoft-Nexus-Organization

---

## ১. তৈরি হওয়া ৯টি লোকাল রিপোজিটরি তালিকা

`D:\GitHub\Dapplesoft-Nexus-Organization` ডিরেক্টরিতে প্ল্যান অনুসারে নিচের ৯টি পৃথক রিপোজিটরি ফোল্ডার ও পূর্ণাঙ্গ আর্কিটেকচারাল `README.md` ফাইল তৈরি করা হয়েছে:

| # | রিপোজিটরির নাম | প্রধান প্রযুক্তি | লোকাল পাথ | বর্ণনা |
|---|---|---|---|---|
| ১ | **nexus-contracts** | Protobuf, OpenAPI v3, JSON Schema, Buf | `nexus-contracts/` | Single Source of Truth for all interfaces & multi-lang SDKs (.NET, TS, Python) |
| ২ | **nexus-core** | C# / .NET 10 LTS, Clean Arch, Temporal | `nexus-core/` | Central Business Engine, Modular Monolith, NEP Execution Machine & Device Control |
| ৩ | **nexus-web** | Next.js 15, TypeScript, Tailwind, React Flow | `nexus-web/` | Real-time Management Console, DAG visualizer, xterm.js terminal & noVNC viewer |
| ৪ | **nexus-governance** | YAML, Markdown, JSON Schema | `nexus-governance/` | Declarative Policy Engine, Task Templates, ADRs, Threat Models |
| ৫ | **nexus-ai-orchestrator** | Python 3.12+, FastAPI, LangGraph, Pydantic v2 | `nexus-ai-orchestrator/` | Constrained Hexagonal AI Orchestration, Resolution Ladder (L0–L7) & Evals |
| ৬ | **nexus-device-agent** | C# / .NET 10 Worker Service, FlaUI, ConPTY | `nexus-device-agent/` | Cross-platform Device Runner, Session 0 GUI helper, Outbound mTLS gRPC |
| ৭ | **nexus-computer-use** | Docker, KVM/QEMU, Playwright | `nexus-computer-use/` | Sandbox Environments (E0/E1), Browser Runner & Network Guard |
| ৮ | **nexus-learning** | Python, PyTorch, HuggingFace, pgvector | `nexus-learning/` | Post-execution intelligence, Candidate Skill extraction, Trajectory curation |
| ৯ | **nexus-infra** | Docker Compose, Caddy, Temporal, Postgres | `nexus-infra/` | Turnkey Local & Production deployment IaC, Observability & Telemetry stack |

---

## ২. গিটহাবে রিপোজিটরি খোলার গাইড (One-Time Setup in GitHub Org)

সংগঠনের পেজে (https://github.com/Dapplesoft-Nexus-Organization) রিপোজিটরিগুলো তৈরি করতে নিচের যেকোনো একটি পদ্ধতি অনুসরণ করুন:

### অপশন ক: GitHub CLI (`gh`) দিয়ে কমান্ড লাইন থেকে তৈরি করা
নিচের কমান্ডগুলো আপনার টার্মিনাল/পাওয়ারশেলে একে একে চালালে ৯টি রিপোজিটরি তৈরি হয়ে যাবে:

```bash
gh repo create Dapplesoft-Nexus-Organization/nexus-contracts --public --description "Single Source of Truth: Protocol Buffers, OpenAPI specs, domain schemas, and SDK generation"
gh repo create Dapplesoft-Nexus-Organization/nexus-core --public --description "Enterprise Core Platform Engine for Dapplesoft Nexus (.NET 10 Modular Monolith, Temporal, Device Control)"
gh repo create Dapplesoft-Nexus-Organization/nexus-web --public --description "Real-time Web Control & Admin Dashboard for Dapplesoft Nexus (Next.js 15, React Flow, xterm.js, noVNC)"
gh repo create Dapplesoft-Nexus-Organization/nexus-governance --public --description "Machine-executable policies, deterministic task-type templates, prompt versions, and ADRs"
gh repo create Dapplesoft-Nexus-Organization/nexus-ai-orchestrator --public --description "Hexagonal AI Orchestration Engine (Python 3.12+, LangGraph) for planning, QA, and resolution ladder"
gh repo create Dapplesoft-Nexus-Organization/nexus-device-agent --public --description "Cross-Platform Execution Agent for Windows and Linux (.NET 10 Worker, GUI Helper, ConPTY)"
gh repo create Dapplesoft-Nexus-Organization/nexus-computer-use --public --description "Sandbox environments (E0 Docker / E1 QEMU VM) and browser execution runners"
gh repo create Dapplesoft-Nexus-Organization/nexus-learning --public --description "Machine learning, knowledge extraction, and offline fine-tuning pipelines"
gh repo create Dapplesoft-Nexus-Organization/nexus-infra --public --description "Infrastructure as Code, Docker Compose stacks, Caddy Gateway, Temporal, and OpenTelemetry"
```

---

### অপশন খ: লোকাল ফোল্ডার ইনিশিয়ালাইজ ও পুশ করার নিয়মাবলী
প্রতিটি রিপোজিটরির জন্য:

```bash
cd D:\GitHub\Dapplesoft-Nexus-Organization\nexus-contracts
git init
git branch -M main
git remote add origin https://github.com/Dapplesoft-Nexus-Organization/nexus-contracts.git
git add .
git commit -m "feat: initial architecture specification and contracts structure"
git push -u origin main
```
*(একইভাবে বাকি ৮টি রিপোজিটরির ক্ষেত্রেও নির্দেশিত ফোল্ডারে গিয়ে রিমোট অ্যাড ও পুশ করতে পারবেন।)*
