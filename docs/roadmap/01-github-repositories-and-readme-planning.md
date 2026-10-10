# প্ল্যান ১: গিটহাব রিপোজিটরি তালিকা, ডেসক্রিপশন এবং সম্পূর্ণ README.md ফাইল আর্কিটেকচার

এই ডকুমেন্টে `Dapplesoft Nexus Organization`-এর অধীনে তৈরি হতে যাওয়া ৯টি রিপোজিটরির বিস্তারিত তালিকা, বিবরণ, ভাষা, ফ্রেমওয়ার্ক এবং প্রতিটি রিপোজিটরির জন্য প্রোডাকশন-রেডি **README.md** টেমপ্লেট ও আর্কিটেকচারাল গাইডলাইন প্রস্তুত করা হলো।

---

## ১. রিপোজিটরিসমূহ ও টেকনোলজি স্পেকট্রাম সামারি

| # | রিপোজিটরির নাম | প্রধান ভাষা / প্রযুক্তি | রোল ও উদ্দেশ্য | শুরু করার পর্যায় |
|---|---|---|---|---|
| ১ | **`nexus-contracts`** | Protobuf, OpenAPI v3, JSON Schema, Buf | **একক সত্য-উৎস (Single Source of Truth):** সব API, gRPC, ইভেন্ট, Plan স্কিমা। CI-এর মাধ্যমে .NET, TS, Python প্যাকেজ জেনারেশন। | Phase 0 (তাৎক্ষণিক) |
| ২ | **`nexus-core`** | C# / .NET 10 LTS, EF Core, Dapper, Temporal SDK | **কোর প্ল্যাটফর্ম ইঞ্জিন:** Clean Architecture + Modular Monolith, NEP S0–S10 State Machine, Action Pipeline, Device Control। | Phase 0–1 (তাৎক্ষণিক) |
| ৩ | **`nexus-web`** | TypeScript, Next.js, React, Tailwind, shadcn/ui | **অ্যাডমিন ও কন্ট্রোল প্যানেল (PWA):** রিয়েল-টাইম টাস্ক মনিটর, প্ল্যান গ্রাফ (React Flow), লাইভ টার্মিনাল (xterm.js), রিমোট GUI ভিউয়ার (noVNC)। | Phase 1–2 |
| ৪ | **`nexus-governance`** | YAML, Markdown, JSON Schema | **পলিসি, টেমপ্লেট ও নীতি গভর্ন্যান্স:** Task-type ওয়ার্কফ্লো টেমপ্লেট, হার্ড-পলিসি রুলস, প্রম্পট ভার্সনিং, ADRs, থ্রেট মডেলিং। | Phase 0–1 |
| ৫ | **`nexus-ai-orchestrator`** | Python 3.12+, FastAPI, LangGraph, Pydantic v2 | **এআই অর্কেস্ট্রেশন ইঞ্জিন:** Hexagonal আর্কিটেকচার, ডেটারমিনিস্টিক প্ল্যানার ও QA গ্রাফ, রেজোলিউশন ল্যাডার (L0–L7), এভাল স্যুট। | Phase 3 |
| ৬ | **`nexus-device-agent`** | C# / .NET 10 Worker Service, FlaUI, ConPTY | **উইন্ডোজ ও লিনাক্স ডিভাইস এজেন্ট:** Background Service, Session-0 বাইপাস GUI Helper IPC, Terminal Executor, Outbound mTLS gRPC। | Phase 4–5 |
| ৭ | **`nexus-computer-use`** | Docker, KVM/QEMU, Playwright, Python/.NET | **কম্পিউটার ইউজ ও স্যান্ডবক্সিং:** E0 আইসোলেটেড কন্টেইনার, E1 ল্যাব ভার্চুয়াল মেশিন, ব্রাউজার রানার, সুরক্ষিত নেটওয়ার্ক গেটওয়ে। | Phase 4 |
| ৮ | **`nexus-learning`** | Python, PyTorch / HuggingFace, pgvector | **কন্টিনিউয়াস লার্নিং ও মডেল রেজিস্ট্রি:** ডেটাসেট কিউরেশন পাইপলাইন, গোল্ডেন টেস্ট হারনেস, ফাইন-টিউনিং রান ও রেজোলিউশন ইভ্যালুয়েশন। | Phase 8 |
| ৯ | **`nexus-infra`** | Docker Compose, Caddy, Temporal, Postgres, OpenTelemetry | **ইনফ্রাস্ট্রাকচার ও ডেভঅপস:** ওয়ান-ক্লিক লোকাল ও প্রোডাকশন অর্কেস্ট্রেশন, রিইউজেবল CI/CD পাইপলাইন, ব্যাকআপ, লগিং ও মনিটরিং স্ট্যাক। | Phase 0 (তাৎক্ষণিক) |

---

## ২. প্রতিটি রিপোজিটরির বিস্তারিত স্পেসিফিকেশন ও README.md

---

### ২.১ `nexus-contracts`
- **GitHub Repository Name:** `nexus-contracts`
- **Description:** Single Source of Truth for Dapplesoft Nexus: Protocol Buffers, OpenAPI specs, domain schemas, and automated multi-language SDK code generation (.NET, TypeScript, Python).
- **Directory Structure:**
  ```text
  nexus-contracts/
  ├── proto/
  │   ├── nexus/core/v1/
  │   ├── nexus/orchestrator/v1/
  │   └── nexus/device/v1/
  ├── openapi/
  │   └── v1/nexus-api.yaml
  ├── schemas/
  │   ├── plans/
  │   └── policies/
  ├── buf.yaml
  ├── buf.gen.yaml
  └── scripts/generate-sdks.sh
  ```
- **README.md Content:**
  ```markdown
  # Nexus Contracts

  The canonical Single Source of Truth (SSOT) defining all interfaces, models, events, and protocols across the Dapplesoft Nexus ecosystem.

  ## Overview
  - **gRPC / Protocol Buffers:** High-performance, strictly-typed bidirectional streaming between Core, AI Orchestrator, and Device Agents.
  - **OpenAPI 3.1:** RESTful schemas for Core Web API powering typed TypeScript client generation.
  - **JSON Schemas:** Strict structural validation for deterministic task planning and policy rule-sets.

  ## Code Generation Workflow
  Breaking changes are strictly blocked by CI using `buf breaking` and `oasdiff`.
  Upon merge to `main`, auto-generated packages are published:
  - C# NuGet Package: `Dapplesoft.Nexus.Contracts`
  - TypeScript NPM Package: `@dapplesoft/nexus-contracts`
  - Python Package: `dapplesoft-nexus-contracts`

  ## Development Setup
  ```bash
  buf lint
  buf generate
  ```
  ```

---

### ২.২ `nexus-core`
- **GitHub Repository Name:** `nexus-core`
- **Description:** Enterprise Core Platform Engine for Dapplesoft Nexus (.NET 10 Modular Monolith, DDD, Clean Architecture, Temporal Workflows, and Device Control).
- **Directory Structure:**
  ```text
  nexus-core/
  ├── src/
  │   ├── BuildingBlocks/
  │   │   ├── Nexus.SharedKernel/
  │   │   ├── Nexus.Application.Abstractions/
  │   │   └── Nexus.Infrastructure.Core/
  │   ├── Modules/
  │   │   ├── Tasking/
  │   │   ├── PolicyApproval/
  │   │   ├── Execution/
  │   │   ├── Devices/
  │   │   └── Resolution/
  │   └── Hosts/
  │       ├── Nexus.Api.Host/
  │       ├── Nexus.Workflows.Host/
  │       └── Nexus.DeviceControl.Host/
  └── tests/
      ├── Nexus.ArchitectureTests/
      └── Nexus.IntegrationTests/
  ```
- **README.md Content:**
  ```markdown
  # Nexus Core

  The central business orchestration engine of Dapplesoft Nexus built with C# and .NET 10 LTS.

  ## Architectural Guarantees
  1. **Modular Monolith & DDD:** Bounded contexts maintain strict isolation. No cross-schema database writes or joins.
  2. **Clean Architecture:** Domain contains pure business rules with 0 external I/O dependencies.
  3. **Nexus Execution Protocol (NEP):** Hardcoded deterministic 11-step execution workflow running on Temporal.io.
  4. **Strict Action Pipeline:** Mediator pipeline enforcing Validate → Authenticate → Classify Risk → Authorize → Quota → Approval → Execute → Sanitize → Audit.

  ## Prerequisites
  - .NET 10 SDK
  - PostgreSQL 16+ (with pgvector)
  - Temporal Server

  ## Running Locally
  ```bash
  dotnet restore
  dotnet test
  dotnet run --project src/Hosts/Nexus.Api.Host
  ```
  ```

---

### ২.৩ `nexus-web`
- **GitHub Repository Name:** `nexus-web`
- **Description:** Real-time Web Control & Admin Dashboard for Dapplesoft Nexus (Next.js 15, TypeScript, Tailwind CSS, shadcn/ui, React Flow, xterm.js, noVNC).
- **Directory Structure:**
  ```text
  nexus-web/
  ├── src/
  │   ├── app/
  │   ├── features/
  │   │   ├── tasks/
  │   │   ├── approvals/
  │   │   ├── devices/
  │   │   └── terminal/
  │   ├── components/ui/
  │   └── lib/api-client/
  ├── public/
  └── tests/
  ```
- **README.md Content:**
  ```markdown
  # Nexus Web

  Next-generation real-time management console for human administrators to inspect, govern, approve, and observe autonomous operations.

  ## Key Capabilities
  - **Interactive Plan Visualizer:** Visual execution DAG using React Flow.
  - **Live Terminal & Session Replay:** Low-latency xterm.js shell streaming via Server-Sent Events (SSE).
  - **Remote GUI Takeover:** Embedded noVNC sandbox desktop viewer.
  - **Feature-Sliced Design:** Strict architectural separation between UI presentation and auto-generated contract clients.

  ## Getting Started
  ```bash
  pnpm install
  pnpm dev
  ```
  ```

---

### ২.৪ `nexus-governance`
- **GitHub Repository Name:** `nexus-governance`
- **Description:** Machine-executable policies, deterministic task-type templates, prompt versions, architectural decision records (ADRs), and security threat models.
- **Directory Structure:**
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
- **README.md Content:**
  ```markdown
  # Nexus Governance

  Declarative policy-as-code repository storing all operational guidelines, deterministic workflow blueprints, and governance rules.

  ## Core Contents
  - **Workflow Templates:** Schema-validated task structures turning ambiguous requests into deterministic execution steps.
  - **Policy Sets:** Multi-tier authorization rules (Hard-deny, Data-class restriction, Environment gating).
  - **Prompt Registry:** Immutable, git-versioned system prompts with pinned model configurations.
  - **Architecture Decision Records (ADRs):** Formal records documenting every engineering decision.
  ```

---

### ২.৫ `nexus-ai-orchestrator`
- **GitHub Repository Name:** `nexus-ai-orchestrator`
- **Description:** Hexagonal AI Orchestration Engine (Python 3.12+, LangGraph, Pydantic v2) executing deterministic planning, QA checks, schema repairs, and resolution ladder.
- **Directory Structure:**
  ```text
  nexus-ai-orchestrator/
  ├── src/orchestrator/
  │   ├── domain/
  │   ├── ports/
  │   ├── adapters/
  │   ├── graphs/
  │   └── safety/
  ├── evals/
  │   ├── golden-datasets/
  │   └── harness.py
  └── tests/
  ```
- **README.md Content:**
  ```markdown
  # Nexus AI Orchestrator

  Constrained AI reasoning service powering structured planning and deterministic step execution.

  ## Core Principles
  - **AI-in-the-Loop, Not in Control:** The orchestrator never decides workflow flow directly; it generates schema-bound outputs consumed by Core.
  - **LangGraph Pipelines:** Deterministic graphs with strict node/edge transition conditions.
  - **Bounded Schema Repair:** Maximum of 2 repair attempts on schema mismatches before escalation.
  - **Golden Evals:** Comprehensive regression testing on prompt modifications.

  ## Setup
  ```bash
  uv sync
  pytest evals/
  ```
  ```

---

### ২.৬ `nexus-device-agent`
- **GitHub Repository Name:** `nexus-device-agent`
- **Description:** Unified Cross-Platform Execution Agent for Windows and Linux (C# .NET 10 Worker Service, Interactive GUI Helper, PTY/ConPTY Terminal, Outbound mTLS).
- **Directory Structure:**
  ```text
  nexus-device-agent/
  ├── Agent.Core/
  ├── Agent.Ports/
  ├── Agent.Host.Service/
  ├── Agent.Adapters.Windows/
  ├── Agent.Adapters.Linux/
  ├── Agent.GuiHelper.Windows/
  ├── Agent.GuiHelper.Linux/
  ├── Agent.Updater/
  └── tests/
  ```
- **README.md Content:**
  ```markdown
  # Nexus Device Agent

  Low-footprint, highly secure device runner capable of executing audited shell commands and GUI interactions across bare-metal or virtual environments.

  ## Architecture & Security
  - **Outbound-Only mTLS:** Connects outbound to Nexus Core via gRPC; no inbound firewall ports required.
  - **Windows Session 0 Isolation:** Background Service delegates desktop UI interactions to a dedicated interactive helper process via local IPC named pipes.
  - **Device-Side Policy Enforcement:** Every incoming signed command is validated locally prior to execution.
  - **A/B Slot Auto-Updater:** Zero-downtime, verified updates signed with Cosign/Authenticode.
  ```

---

### ২.৭ `nexus-computer-use`
- **GitHub Repository Name:** `nexus-computer-use`
- **Description:** Sandbox environments, isolated virtual machines (E0 container / E1 KVM), and automated browser execution runners.
- **Directory Structure:**
  ```text
  nexus-computer-use/
  ├── sandboxes/
  │   ├── e0-docker/
  │   └── e1-qemu-vm/
  ├── browser-runner/
  └── network-guard/
  ```
- **README.md Content:**
  ```markdown
  # Nexus Computer-Use & Sandbox Engine

  Isolated, snapshot-enabled environments providing safe compute sandboxes for agent actions.

  ## Sandboxing Tiers
  - **E0 (Ephemeral Sandbox):** Isolated Docker/containerd micro-environments for read-only evaluations.
  - **E1 (Lab VM):** Full Windows/Linux KVM images featuring snapshot/revert capabilities and interactive screen streaming.
  - **Network Guard:** Outbound proxy with strict domain allowlisting preventing data leakage.
  ```

---

### ২.৮ `nexus-learning`
- **GitHub Repository Name:** `nexus-learning`
- **Description:** Machine learning, knowledge extraction, and offline fine-tuning pipelines (Candidate Skill ingestion, Evaluation Harness, and Resolution Analytics).
- **Directory Structure:**
  ```text
  nexus-learning/
  ├── pipelines/
  │   ├── skill-extraction/
  │   └── trajectory-curation/
  ├── training/
  └── evals/
  ```
- **README.md Content:**
  ```markdown
  # Nexus Learning

  Post-execution intelligence pipeline extracting durable lessons and reusable skills from completed tasks.

  ## Safety & Governance
  - **Candidate Pipeline:** Extracted skills are classified as *Candidate* and NEVER published to production without human review.
  - **Trajectory Anonymization:** Automatic PII/secret scrubbing before dataset persistence.
  ```

---

### ২.৯ `nexus-infra`
- **GitHub Repository Name:** `nexus-infra`
- **Description:** Centralized Infrastructure as Code (IaC), Docker Compose stacks, Caddy Gateway, Observability (OpenTelemetry, Prometheus, Grafana, Loki), and CI/CD pipelines.
- **Directory Structure:**
  ```text
  nexus-infra/
  ├── compose/
  │   ├── docker-compose.local.yml
  │   └── docker-compose.prod.yml
  ├── caddy/
  ├── monitoring/
  │   ├── prometheus/
  │   └── grafana/
  └── scripts/
  ```
- **README.md Content:**
  ```markdown
  # Nexus Infrastructure & DevOps

  Turnkey deployment manifests and infrastructure orchestration for local development and enterprise deployment.

  ## Quickstart (Local Environment)
  ```bash
  docker compose -f compose/docker-compose.local.yml up -d
  ```
  Deploys:
  - PostgreSQL 16 + pgvector
  - Temporal Server & Web UI
  - OpenTelemetry Collector + Prometheus + Grafana + Loki
  - Caddy Reverse Proxy & TLS Gateway
  ```
