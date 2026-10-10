# Dapplesoft Nexus — আর্কিটেকচার ও ডিজাইন প্যাটার্ন (v3)

> v2-এর ওপর ভিত্তি করে এই সংস্করণে নির্দিষ্ট করা হলো: ১) কোন আর্কিটেকচার, ২) কোন ডিজাইন প্যাটার্ন কোথায়, ৩) কাজ সবসময় একই ক্রমে চলার "Nexus Execution Protocol", ৪) ভাষা/ফ্রেমওয়ার্ক (Web, Backend, Agent), ৫) কোথায় EF/ফাংশন/API।
> যেসব অংশ বদলায়নি (UI স্ক্রিন, E0–E3 পরিবেশ, Resolution Ladder, Learning স্তর, CI/CD নীতি) সেগুলো v1/v2-ই বহাল। লাইব্রেরি/ভার্সন/লাইসেন্স লেখার সময়ের জানা তথ্য — ব্যবহারের আগে যাচাই করুন।

---

## ০. আপনার প্রশ্নের সরাসরি উত্তর ও সংশোধিত সুপারিশ

### ০.১ Backend: C#/.NET কি ব্যবহার করা উচিত?

**হ্যাঁ — আপনার প্রয়োজনে C#/.NET Core API-র জন্য ভালো এবং আমি এখন সেটিই সুপারিশ করছি।** আগে Node.js/TypeScript বলেছিলাম মূলত "Next.js-এর সঙ্গে shared types"-এর যুক্তিতে। সেই যুক্তি দুর্বল ছিল, কারণ shared types এখন OpenAPI/Protobuf থেকে কোড-জেনারেশন দিয়ে যেকোনো ভাষায় পাওয়া যায়।

| বিবেচনা | .NET | Node/TS |
|---|---|---|
| Clean/DDD, শক্ত টাইপিং, বড় কোডবেসে রক্ষণাবেক্ষণ | ✅ খুব ভালো | ভালো, তবে শৃঙ্খলা বেশি লাগে |
| EF Core (migration, concurrency, transaction, Unit of Work) | ✅ পরিপক্ক | ORM তুলনামূলক কম পরিপক্ক |
| Windows ইন্টিগ্রেশন (Service, UI Automation) | ✅ নেটিভ | দুর্বল |
| Temporal SDK | ✅ আছে (.NET SDK) | ✅ |
| পারফরম্যান্স/মেমরি | ✅ ভালো | ভালো |
| আপনার টিমের দক্ষতা (EF উল্লেখ করেছেন) | ✅ সম্ভবত | অনিশ্চিত |
| AI/ML ইকোসিস্টেম | ❌ সীমিত (তাই Python আলাদা) | সীমিত |

**চূড়ান্ত সিদ্ধান্ত (প্রস্তাবিত):**
- **Core Platform (API, Workflow Worker, Device Control): C# / .NET (সর্বশেষ LTS — লেখার সময় .NET 10; যাচাই করুন)।**
- **AI Orchestrator: Python** (LangGraph, মডেল/এমবেডিং/ট্রেনিং/eval — এখানে Python-এর বিকল্প নেই)।
- **Web UI: Next.js + TypeScript।**
- **Device Agent: C#/.NET** (v1-এ Go বলেছিলাম — নিচে কারণসহ পরিবর্তন, §৭)।

শর্ত: যদি আপনার টিম .NET-এ দক্ষ না হয়, তাহলে TypeScript/NestJS-ও গ্রহণযোগ্য; পুরো আর্কিটেকচার (Clean + DDD + প্যাটার্ন) একই থাকে, কারণ সীমানা ভাষা নয়, **Contract** (OpenAPI/Protobuf)।

### ০.২ "একেক সময় একেক রকম কাজ" — সমাধানের মূল ধারণা

AI মডেল স্বভাবতই সম্ভাব্যতা-ভিত্তিক; একই প্রম্পটে সবসময় হুবহু একই লেখা আসবে — এই নিশ্চয়তা কেউ দিতে পারে না। তাই আমরা **আউটপুটের বদলে প্রক্রিয়াকে নির্দিষ্ট করি:**

> **AI-in-the-loop, not AI-in-control।** ধাপের ক্রম, নিয়ম, অনুমতি, যাচাই ও রেকর্ড — সব নির্ধারিত কোড/ওয়ার্কফ্লো (deterministic)। AI শুধু প্রতিটি ধাপের ভেতরে "ফাঁক পূরণ" করে টাইপড (schema-বাঁধা) আউটপুটে; ভুল বা অবৈধ হলে নির্ধারিত নিয়মে প্রত্যাখ্যাত/পুনঃচেষ্টা।

এর ওপর ভিত্তি করে **Nexus Execution Protocol (NEP)** (§৪) — প্রতিটি কাজ সবসময় একই ১১ ধাপ অনুসরণ করে।

---

## ১. নির্ধারিত আর্কিটেকচার: Modular Monolith + Clean Architecture + DDD

### ১.১ কেন এই সমন্বয়
- **Domain-Driven Design (strategic):** Nexus-এর জটিলতা ব্যবসায়িক নিয়মে (Policy, Approval, Risk, Resolution) — DDD ঠিক সেখানে কাজে লাগে।
- **Clean Architecture:** নিয়ম (Domain) ফ্রেমওয়ার্ক/ডাটাবেস/AI-প্রোভাইডার থেকে স্বাধীন → প্রোভাইডার বদলালেও নিয়ম অক্ষত।
- **Modular Monolith:** একটি ডিপ্লয়মেন্ট ইউনিট, কিন্তু মডিউলগুলোর মধ্যে কঠোর সীমানা → পরে প্রয়োজনে একটি মডিউল আলাদা সার্ভিসে সরানো যায়।
- ❌ শুরুতেই Microservices নয়; ❌ "Anemic" ডোমেইন (শুধু getter/setter + সব লজিক সার্ভিসে) নয়।

### ১.২ লেয়ার ও নির্ভরতার নিয়ম (প্রতিটি মডিউলে)

```
┌─────────────────────────────────────────────────────────┐
│ Presentation / API   (Controllers/Endpoints, gRPC, SSE)  │
├─────────────────────────────────────────────────────────┤
│ Application          (Use cases: Commands/Queries,       │
│                       pipeline behaviors, ports)         │
├─────────────────────────────────────────────────────────┤
│ Domain               (Aggregates, Entities, Value Objects│
│                       Domain Events, Domain Services,    │
│                       pure functions)  ← কোনো I/O নেই    │
├─────────────────────────────────────────────────────────┤
│ Infrastructure       (EF Core, Dapper, Temporal,         │
│                       LLM adapters, Git, SMTP...)        │
└─────────────────────────────────────────────────────────┘
নির্ভরতার দিক: Presentation → Application → Domain ← Infrastructure
(Domain কারো ওপর নির্ভর করে না; Infrastructure Application-এর "port" ইমপ্লিমেন্ট করে)
```

**বাধ্যতামূলক নিয়ম (CI-তে architecture test দিয়ে ভাঙলে build fail):**
1. Domain প্রজেক্টে EF/HTTP/Temporal/LLM-এর কোনো reference নেই।
2. এক মডিউল অন্য মডিউলের Domain/Infrastructure সরাসরি ব্যবহার করবে না; কেবল ওই মডিউলের **public Contracts** (interface + DTO + integration event) ব্যবহার করবে।
3. একটি মডিউল শুধু নিজের **ডাটাবেস স্কিমা**-র মালিক (Postgres schema-per-module); অন্য মডিউলের টেবিলে JOIN/write নয়।
4. Controller-এ ব্যবসায়িক লজিক নয়; Application handler-এ নয় (পাতলা), Domain-এ।
5. সব প্রত্যাশিত ব্যর্থতা `Result<T, Error>`-এ (exception শুধু অপ্রত্যাশিত/প্রোগ্রামিং ভুলে)।

### ১.৩ Bounded Context (মডিউল) ও Context Map

| Context | মূল দায়িত্ব | Aggregate Root (উদাহরণ) |
|---|---|---|
| **IdentityAccess** | Admin, role, session, MFA | `AdminUser`, `Role` |
| **Tasking** | টাস্ক, প্ল্যান, ধাপ, state machine | `Task` (Plan, Steps ভেতরে) |
| **PolicyApproval** | নিয়ম মূল্যায়ন, অনুমোদন | `PolicySet`, `ApprovalRequest` |
| **Execution** | Environment, terminal/GUI সেশন, কমান্ড | `ExecutionSession`, `Environment` |
| **Devices** | Device enrollment, health, credential | `Device` |
| **Resolution** | Resolution Ladder, স্কোরিং, attempt ইতিহাস | `ResolutionCase` |
| **KnowledgeSkills** | Knowledge, Skill, app catalog, lifecycle | `Skill`, `KnowledgeItem` |
| **ResourcesSpend** | রিসোর্স রেজিস্ট্রি, সাবস্ক্রিপশন, বাজেট | `Resource`, `Subscription`, `Budget` |
| **Connectors** | মেইল/সোশ্যাল/সার্চ/Channel Gateway | `Connector`, `ChannelIdentity` |
| **Learning** | Dataset, training run, model registry | `Dataset`, `TrainingRun`, `ModelVersion` |
| **Releases** | বিল্ড, রোলআউট | `Release`, `Rollout` |
| **AuditObservability** | Audit, usage, alert | `AuditEvent` (append-only) |

**Context Map (নির্ভরতার ধরন):**
- `Tasking` → (সিদ্ধান্ত চায়) → `PolicyApproval` : **Customer–Supplier**; Policy-র Contract স্থির।
- `Tasking`/`Resolution` → `Execution` : **Open Host Service** (Execution Gateway API)।
- সব Context → `AuditObservability` : domain event প্রকাশ (Published Language)।
- Nexus → AI প্রোভাইডার/GitHub/Email/Social : **Anti-Corruption Layer (Adapter)**; বাইরের মডেল Domain-এ ঢুকবে না।
- Core ↔ AI Orchestrator : **Contract-First (Protobuf/JSON Schema)**।

### ১.৪ Tactical DDD — উদাহরণ (Tasking)

```csharp
// Domain — কোনো I/O নেই
public sealed class TaskAggregate : AggregateRoot<TaskId>
{
    public TaskStatus Status { get; private set; }
    private readonly List<PlanVersion> _plans = new();

    public Result ApproveAndStart(PlanVersion plan, ActorId actor)
    {
        // Invariants: কেবল VALIDATED ও অনুমোদিত প্ল্যান চালু করা যাবে
        if (Status != TaskStatus.Ready)       return Errors.Task.NotReady;
        if (!plan.IsValidated)                return Errors.Plan.NotValidated;
        Status = TaskStatus.Running;
        Raise(new TaskStarted(Id, plan.Version, actor));   // Domain Event
        return Result.Success();
    }
}
```
- **Value Objects:** `RiskLevel`, `DataClass`, `Money`, `ActionHash`, `PlanVersion`, `EnvironmentTier` (E0–E3) — immutable, নিজস্ব validation।
- **Domain Events:** `TaskStarted`, `ApprovalGranted`, `CommandBlocked`… → ট্রানজ্যাকশনের ভেতরে Outbox-এ লেখা হয়।
- **Aggregate সীমা:** একটি ট্রানজ্যাকশন = একটি aggregate; aggregate-দের মধ্যে সমন্বয় event/workflow দিয়ে (eventual consistency)।

---

## ২. ডিজাইন প্যাটার্ন ক্যাটালগ — কোন প্যাটার্ন কোথায়

| প্যাটার্ন | কোথায় ব্যবহার হবে | উদ্দেশ্য |
|---|---|---|
| **State** | Task/Workflow/Approval/Skill/Release lifecycle | অবৈধ transition অসম্ভব করা; একটি জায়গায় transition টেবিল |
| **CQRS (লাইট)** | সব মডিউল: Command (write, EF) / Query (read, Dapper/SQL) আলাদা | write-এ নিয়ম, read-এ গতি |
| **Mediator + Pipeline Behaviors** | Application লেয়ার | প্রতিটি use case-এ একই ক্রমে: Logging → Validation → Authorization → Idempotency → Transaction → Audit |
| **Chain of Responsibility** | Policy মূল্যায়ন (Hard-deny → Data-class → Env → Budget → Allow-list) | নিয়ম-ক্রম স্থির ও যোগ-করা সহজ |
| **Specification** | Policy rule শর্ত, query filter | পুনঃব্যবহারযোগ্য, টেস্টযোগ্য শর্ত |
| **Strategy** | Resolution Ladder-এর প্রতিটি ধাপ (L0…L7), Provider Router, Retry policy | একই ইন্টারফেসে বদলযোগ্য কৌশল |
| **Command** | Tool call, Device Job, Terminal কমান্ড (typed, serializable, signed) | বাতিল/রেকর্ড/রিপ্লে/অডিট |
| **Adapter / Anti-Corruption** | LLM প্রোভাইডার, GitHub, Email, Social, Payment | বাইরের API পরিবর্তনে নিয়ম অক্ষত |
| **Factory + Registry** | Tool Registry, Agent Registry, Resource Registry | নতুন Tool/Agent = রেজিস্ট্রিতে এন্ট্রি, কোডে `if/else` নয় |
| **Decorator** | Tool/Provider-এর চারপাশে logging, redaction, rate-limit, cost-metering, circuit-breaker | ক্রস-কাটিং এক জায়গায় |
| **Template Method** | Agent run: `BuildContext → Plan → Act → Verify → Record` কাঠামো স্থির, ভেতরের অংশ Agent-ভেদে | সব এজেন্ট একই কাঠামো মানবে |
| **Saga / Process Manager** | Temporal Workflow (দীর্ঘ কাজ, ক্ষতিপূরণ/rollback ধাপ) | নির্ভরযোগ্য বহু-ধাপ প্রক্রিয়া |
| **Transactional Outbox + Inbox** | DB commit ↔ Workflow/Event dispatch | হারানো/ডুপ্লিকেট বার্তা রোধ |
| **Repository + Unit of Work** | EF Core DbContext (write side) | aggregate persistence |
| **Observer / Domain Events** | মডিউল-সীমানার মধ্যে ঢিলেঢালা সংযোগ | Audit, Notification, Learning-এর ট্রিগার |
| **Circuit Breaker / Retry / Bulkhead / Timeout** | বাইরের কল (Polly/Resilience) | ব্যর্থতা ছড়ানো রোধ |
| **Idempotent Receiver** | Webhook, Device job result, Workflow activity | ডুপ্লিকেট কাজ রোধ |
| **Result / Railway** | Application + Domain | exception-ছাড়া প্রত্যাশিত ব্যর্থতা |
| **Event Sourcing-lite** | `task_events`, `audit_events` (append-only) | সম্পূর্ণ ইতিহাস ও রিপ্লে; পুরো aggregate event-sourced নয় |
| **Memento/Snapshot** | Lab VM/E2 স্ন্যাপশট-ভিত্তিক rollback | নিরাপদ পুনরুদ্ধার |
| **Plugin/Skill (Playbook)** | Skill Library — যাচাইকৃত ধাপ-স্ক্রিপ্ট | নির্ধারিত সমাধান পুনঃব্যবহার (পুনরায় "উদ্ভাবন" নয়) |

নিয়ম: নতুন প্যাটার্ন যোগ করতে ADR লাগবে; প্যাটার্ন "থাকার জন্য" নয়, সমস্যা সমাধানের জন্য।

---

## ৩. ধারাবাহিকতার কৌশল — কীভাবে "একেক সময় একেক রকম" ঠেকানো হবে

| # | কৌশল | বাস্তবায়ন |
|---|---|---|
| 1 | **একটিই প্রবেশপথ** | সব কাজ (Panel/Telegram/Schedule/Webhook) `Tasking.CreateTask` দিয়ে; সাইড-চ্যানেল নেই |
| 2 | **নির্ধারিত ধাপ-ক্রম (NEP)** | Temporal workflow কোডে ক্রম হার্ডকোডেড; AI ক্রম বদলাতে পারে না |
| 3 | **একটিই Action Pipeline** | প্রতিটি পার্শ্বপ্রতিক্রিয়ার (side-effect) কাজ §৫-এর একই পাইপলাইনে; পাইপলাইন এড়ানোর পথ নেই |
| 4 | **Typed Output** | AI আউটপুট JSON Schema/Pydantic/DTO-তে; অবৈধ → সর্বোচ্চ ২ বার "repair" → ব্যর্থ |
| 5 | **Task-type টেমপ্লেট** | পরিচিত ধরনের কাজ (যেমন "broken-link audit") → পূর্ব-নির্ধারিত ওয়ার্কফ্লো টেমপ্লেট; AI শুধু প্যারামিটার পূরণ করে |
| 6 | **অপরিচিত কাজ = Exploratory মোড** | শুধু E0/E1-এ; সফল হলে ধাপগুলো Skill/Template হিসেবে Candidate → যাচাই → Published; পরের বার ডিটারমিনিস্টিক |
| 7 | **AI সেটিংস পিন** | planner/classifier-এ temperature=0, মডেল ভার্সন পিন, প্রম্পট Git-এ ভার্সনড (`nexus-governance`) |
| 8 | **Record & Replay** | প্রতিটি LLM কল (ইনপুট/আউটপুট/মডেল/প্যারাম) সংরক্ষিত; টেস্টে VCR-স্টাইল রিপ্লে; Temporal deterministic replay |
| 9 | **Golden Tests / Evals** | প্রতিটি task-type-এর জন্য golden প্ল্যান; প্রম্পট/মডেল বদলালে CI-তে regression গেট |
| 10 | **Policy-as-code** | নিয়ম কোড/ডেটা হিসেবে ভার্সনড; একই ইনপুটে একই সিদ্ধান্ত (pure function) |
| 11 | **Extension Recipes** | নতুন Tool/Agent/Endpoint/Module যোগের নির্ধারিত চেকলিস্ট (§১২) |
| 12 | **Architecture Tests + Analyzers** | নিয়ম ভাঙলে build fail |

---

## ৪. Nexus Execution Protocol (NEP) — নির্ধারিত ১১-ধাপের ক্রম

```
S0 Intake → S1 Classify → S2 Context → S3 Plan → S4 Validate → S5 Authorize
→ S6 Approve (প্রয়োজনে) → S7 Execute → S8 Verify → S9 Report → S10 Learn
                       ↑___ ব্যর্থ হলে: Resolution escalation (সীমিত) বা Fail-Review ___|
```

| ধাপ | কী হয় | কে করে | ইনপুট → আউটপুট (Typed) | ব্যর্থতায় |
|---|---|---|---|---|
| **S0 Intake** | অনুরোধ গ্রহণ, পরিচয় যাচাই, idempotency | Tasking (deterministic) | `CreateTaskCommand → Task(DRAFT)` | প্রত্যাখ্যান + কারণ |
| **S1 Classify** | task-type, data-class, ঝুঁকির প্রাথমিক ধারণা | Classifier (নিয়ম + ছোট মডেল, temp=0) | `Task → TaskClassification` | অনিশ্চিত হলে Admin-কে প্রশ্ন (L7) |
| **S2 Context** | প্রাসঙ্গিক Skill/Knowledge/ইতিহাস (permission-ফিল্টার সহ) | KnowledgeSkills + Retrieval | `Classification → ContextBundle` | খালি হলেও চলবে (Exploratory) |
| **S3 Plan** | টেমপ্লেট থাকলে তা পূরণ; না থাকলে AI Planner প্ল্যান বানায় | Planner (AI, typed) | `ContextBundle → Plan JSON` | repair ≤২ → FAILED_PLANNING |
| **S4 Validate** | schema, dependency-cycle, tool-allowlist, বাজেট, acceptance criteria আছে কি | Domain function (pure) | `Plan → ValidatedPlan` | অবৈধ প্ল্যান কখনোই চলে না |
| **S5 Authorize** | প্রতি ধাপের Policy সিদ্ধান্ত (ALLOW/DENY/REQUIRE_APPROVAL) | Policy chain (pure) | `ValidatedPlan → AuthorizedPlan` | DENY → ধাপ বাদ/টাস্ক ব্যর্থ |
| **S6 Approve** | Admin অনুমোদন (plan-version + action-hash-এ বাঁধা) | Admin (Workflow signal) | `ApprovalRequest → Decision` | Reject → থামে; Timeout → মেয়াদোত্তীর্ণ |
| **S7 Execute** | প্রতি ধাপ **Action Pipeline** (§৫) দিয়ে | Temporal Activities | `Step → StepResult + Evidence` | bounded retry → Resolution escalation |
| **S8 Verify** | acceptance criteria, টেস্ট, দ্বিতীয় যাচাই | QA (deterministic checks আগে, AI পরে) | `Results → VerificationReport` | ব্যর্থ → fix-loop (সীমিত) বা Fail-Review |
| **S9 Report** | রিপোর্ট, প্রমাণ, খরচ | Reporting | `→ Report` | — |
| **S10 Learn** | Candidate Skill/Knowledge, Resolution ইতিহাস আপডেট | Learning (নিজে Verified করে না) | `→ Candidates` | — |

**নিয়ম:** ধাপ বাদ দেওয়া, ক্রম বদলানো বা ধাপের মধ্যে "AI সিদ্ধান্ত নিল তাই এড়িয়ে গেলাম" — অসম্ভব, কারণ ক্রম Temporal workflow কোডে।

### ৪.১ Task-type টেমপ্লেট
```yaml
# nexus-governance/workflows/templates/website-broken-link-audit.yaml
type: website.broken_link_audit
version: 3
parameters: { domain: string(allowlisted), max_pages: int<=5000 }
steps:
  - id: verify_domain      tool: policy.check_domain      risk: low
  - id: crawl              tool: browser.crawl_readonly   risk: low   env: E0
  - id: classify_links     tool: analysis.classify        risk: low
  - id: report             tool: report.generate          risk: low
acceptance: [ "report.contains(all_broken_links)", "no_write_operations==true" ]
```
টেমপ্লেট থাকলে S3 = "প্যারামিটার পূরণ" (ছোট কাজ, প্রায় ডিটারমিনিস্টিক)।

---

## ৫. Action Pipeline — প্রতিটি পার্শ্বপ্রতিক্রিয়ার একই পথ

প্রতিটি Tool call/Terminal কমান্ড/GUI অ্যাকশন/Device job/মেইল/পেমেন্ট — সবই এই ক্রমে:

```
1  Validate        (schema, size, encoding)
2  Authenticate    (actor / service identity)
3  Classify Risk   (Command Risk Classifier — সার্ভার-সাইড, AI-এর দাবি অগ্রাহ্য)
4  Authorize       (Policy chain)
5  Budget/Quota    (খরচ, rate-limit, blast-radius)
6  Approval Gate   (REQUIRE_APPROVAL হলে থামুন)
7  Idempotency     (কী দিয়ে ডুপ্লিকেট রোধ)
8  Pre-snapshot    (E2/R2+: স্ন্যাপশট/ব্যাকআপ)
9  Execute         (timeout + resource limit, নির্ধারিত Environment-এ)
10 Sanitize        (আউটপুট redaction, untrusted ট্যাগ)
11 Record          (audit + evidence + usage)
12 Emit Events     (outbox)
```
**বাস্তবায়ন:** Application লেয়ারে Mediator pipeline behaviors (ক্রম কোডে স্থির) + ডিভাইস-সাইডে একই ক্রমের ছোট সংস্করণ (সাইন যাচাই → Policy → Execute → Record)। Architecture test নিশ্চিত করে কোনো Tool সরাসরি Executor ডাকছে না।

---

## ৬. ফাংশন / EF Core / API / Event — কোথায় কোনটি (গুরুত্বপূর্ণ সিদ্ধান্ত-ম্যাট্রিক্স)

### ৬.১ ডেটা-অ্যাক্সেস: EF Core বনাম Dapper/SQL বনাম DB-ফাংশন

| কাজ | ব্যবহার করুন | কারণ |
|---|---|---|
| Aggregate-এর write (Task, Approval, Device, Skill, Resource, Release…) | **EF Core** (Repository + UoW, optimistic concurrency `xmin`) | নিয়ম+ট্রানজ্যাকশন+change-tracking |
| Migration (schema পরিবর্তন) | **EF Core Migrations** (code-first, মডিউল-ভিত্তিক); বিপজ্জনক ধাপে হাতে-লেখা SQL | ভার্সনড, CI-তে যাচাইযোগ্য |
| Read model/তালিকা/ড্যাশবোর্ড/রিপোর্ট/পেজিনেশন | **Dapper বা raw SQL** (Query side) | গতি, JOIN-নমনীয়তা, প্রজেকশন |
| Full-text, pgvector সার্চ, hybrid retrieval | **Raw SQL** (বা Pgvector.EntityFrameworkCore সাধারণ কেসে) | ইনডেক্স/অপারেটর নিয়ন্ত্রণ |
| বিপুল বাল্ক-ইনসার্ট (লগ, trajectory, usage) | **Npgsql COPY / batch** | EF-এ ধীর |
| Append-only audit | EF দিয়ে INSERT; DB-তে **UPDATE/DELETE নিষিদ্ধ (role permission/trigger)** | ছেঁড়াছেঁড়া অসম্ভব |
| Partition ম্যানেজমেন্ট, retention জব | **DB ফাংশন/স্ক্রিপ্ট** (pg_partman বা নির্ধারিত জব) | অবকাঠামোগত |
| ব্যবসায়িক নিয়ম | ❌ **Stored procedure-এ নয়** | টেস্ট/ভার্সন/পোর্টেবিলিটি |
| Row-Level Security | DB policy (পরে multi-team-এ) | ডিফেন্স-ইন-ডেপথ |

**স্কিমা-per-module:** `tasking.*`, `policy.*`, `execution.*`, `devices.*` … — নিজের মডিউল ছাড়া অন্য স্কিমা write/JOIN নয়।

### ৬.২ কোথায় "শুধু ফাংশন" (Pure Domain Function)

যে লজিকে I/O নেই — **pure function/ডোমেইন সার্ভিস**, ইউনিট-টেস্টে ১০০% কভারেজ লক্ষ্য:
- Task/Approval/Release **state transition** নির্ধারণ।
- **Policy মূল্যায়ন** (chain), **Command Risk Classifier-এর নিয়ম**।
- **Plan validation** (cycle, allow-list, budget)।
- **Resolution স্কোরিং** (`score = P·মান − খরচ·w1 − …`)।
- **Redaction**, **ActionHash/Idempotency-key** তৈরি, checksum।
- **Retry/backoff** গণনা, **cost estimation**।

### ৬.৩ কোথায় API বানাতে হবে এবং কোন ধরনের

| যোগাযোগ | মাধ্যম | কেন |
|---|---|---|
| Web UI ↔ Core | **REST + OpenAPI** (JSON), লাইভের জন্য **SSE** | ব্রাউজার-বান্ধব, কোডজেন TS ক্লায়েন্ট |
| মডিউল ↔ মডিউল (Core-এর ভেতরে) | **In-process** Contracts interface / Mediator call (**HTTP নয়**) | monolith-এর সুবিধা; পরে আলাদা করলে adapter বদলাবে |
| Core ↔ AI Orchestrator | **gRPC (Protobuf)** (streaming সহ) | কঠোর টাইপ, দ্বিমুখী stream |
| Core ↔ Device Agent | **gRPC bidi stream, outbound-only, mTLS** | ফায়ারওয়াল-বান্ধব, কম-লেটেন্সি |
| Core ↔ Temporal | Temporal SDK | — |
| Workflow Activity → বাইরের সিস্টেম | Activity (retry/timeout সহ) | durable, idempotent |
| বাইরের সিস্টেম → Nexus (Webhook, Telegram) | REST endpoint (signature যাচাই + dedupe) | — |
| ইভেন্ট (মডিউল-সীমানা) | Domain event → **Outbox** → in-process handler / Temporal signal | নির্ভরযোগ্য |
| Orchestrator → DB | **শুধু রিড-অনলি রোল** (retrieval); write সবসময় Core API-র মাধ্যমে | ডেটা-অখণ্ডতা |

**API নিয়ম:** `/api/v1/...` ভার্সনড; Contract-first (OpenAPI/Proto আগে, কোড পরে); RFC 7807 Problem Details; Idempotency-Key; Correlation-ID; পেজিনেশন বাধ্যতামূলক; breaking change = নতুন ভার্সন।

### ৬.৪ সংক্ষেপে সিদ্ধান্ত-গাছ

```
নতুন লজিক লিখছি…
├─ I/O নেই, শুধু নিয়ম/গণনা?              → Pure function (Domain)
├─ একটি aggregate-এর অবস্থা বদলাচ্ছে?      → Domain method + EF Core (Command)
├─ তালিকা/রিপোর্ট/সার্চ পড়ছি?              → Dapper/SQL (Query)
├─ বাইরের সিস্টেম/AI/টুল ডাকছি, পুনঃচেষ্টা লাগে? → Port + Adapter, Temporal Activity-তে
├─ অন্য মডিউলের তথ্য/কাজ লাগে?             → ওই মডিউলের public Contract (in-process)
├─ ব্রাউজার/Agent/Orchestrator/বাইরের পক্ষ?  → API (REST বা gRPC)
└─ দীর্ঘ/বহু-ধাপ/অনুমোদন-অপেক্ষা?          → Temporal Workflow
```

---

## ৭. প্রযুক্তি স্ট্যাক — অ্যাপ্লিকেশন-ভিত্তিক চূড়ান্ত তালিকা

### ৭.১  Web UI (Admin Panel)
| বিষয় | সিদ্ধান্ত |
|---|---|
| ফ্রেমওয়ার্ক | **Next.js + React + TypeScript** (বিকল্প: Blazor — তবে লাইভ AI-স্ট্রিমিং ও টার্মিনাল/GUI ভিউয়ারের ইকোসিস্টেম React-এ বেশি) |
| স্টাইল/কম্পোনেন্ট | Tailwind + shadcn/ui |
| সার্ভার-স্টেট | TanStack Query; লাইভ: SSE |
| ফর্ম/ভ্যালিডেশন | React Hook Form + Zod |
| API ক্লায়েন্ট | OpenAPI থেকে জেনারেটেড (openapi-typescript/orval) — হাতে লেখা নয় |
| টার্মিনাল ভিউ | xterm.js |
| GUI লাইভ ভিউ/টেকওভার | noVNC / Apache Guacamole (E1 VM) |
| প্ল্যান গ্রাফ | React Flow |
| চার্ট | Recharts/ECharts |
| i18n | next-intl (বাংলা/English) |
| টেস্ট | Vitest, Testing Library, Playwright E2E, Storybook |
| আর্কিটেকচার | **Feature-Sliced** (features/tasks, features/approvals…); UI-তে ব্যবসায়িক নিয়ম নেই — সার্ভারের সিদ্ধান্ত দেখায় |
| মোবাইল | **PWA (রেসপন্সিভ)** — প্রথমে নেটিভ অ্যাপ নয়; পরে প্রয়োজনে React Native/Flutter |
| ডেস্কটপ অ্যাপ | এখন নয়। (প্রয়োজনে পরে Tauri) |

### ৭.২ Core Backend (.NET)
| বিষয় | সিদ্ধান্ত |
|---|---|
| ভাষা/রানটাইম | C# + .NET (সর্বশেষ LTS) |
| Web | ASP.NET Core (Minimal APIs বা Controllers — একটি বেছে সব মডিউলে একই) |
| ORM | **EF Core + Npgsql** (write); **Dapper** (read) |
| CQRS/Mediator | MediatR **বাণিজ্যিক লাইসেন্সে গেছে বলে জানা যায় — লাইসেন্স যাচাই করুন**; ফ্রি বিকল্প: `Mediator` (source-generated, MIT) বা হাতে-লেখা ছোট pipeline (সুপারিশ: নিজস্ব ছোট pipeline, ~১০০ লাইন, নির্ভরতা শূন্য) |
| Validation | FluentValidation (লাইসেন্স যাচাই) বা বিল্ট-ইন/হাতে-লেখা |
| Resilience | Polly / Microsoft.Extensions.Resilience |
| Workflow | **Temporalio (.NET SDK)** |
| Auth | ASP.NET Core Identity + **OpenIddict** (OSS) অথবা Keycloak; TOTP/WebAuthn (Fido2NetLib) |
| gRPC | Grpc.AspNetCore |
| Logging/Tracing | Serilog + OpenTelemetry .NET |
| Result টাইপ | নিজস্ব `Result<T>` (বা ErrorOr) |
| টেস্ট | xUnit, Testcontainers (Postgres/Temporal), NetArchTest (আর্কিটেকচার), Verify (snapshot), Bogus |
| স্ট্যাটিক বিশ্লেষণ | Roslyn analyzers, `TreatWarningsAsErrors`, SonarAnalyzer |
| মেসেজিং | শুরুতে নয় (Outbox + Temporal)। MassTransit-ও বাণিজ্যিক হয়েছে বলে জানা যায় — এড়িয়ে চলুন |

### ৭.৩ AI Orchestrator (Python)
| বিষয় | সিদ্ধান্ত |
|---|---|
| ভাষা/ফ্রেমওয়ার্ক | Python 3.12+, FastAPI (বা শুধু gRPC সার্ভার), Pydantic v2 |
| এজেন্ট গ্রাফ | **LangGraph — প্রতিটি এজেন্ট একটি নির্দিষ্ট গ্রাফ** (নোড = ছোট ফাংশন; edge = নির্ধারিত শর্ত); "ফ্রি-ফর্ম লুপ" নয় |
| আর্কিটেকচার | **Hexagonal:** `domain/` (pure), `ports/`, `adapters/` (LLM, Core-gRPC, retrieval), `graphs/` |
| ডেটা | DB-তে রিড-অনলি (SQLAlchemy/psycopg); write = Core gRPC |
| টুলিং | uv, ruff, mypy (strict), pytest, pytest-recording (LLM রিপ্লে) |
| Eval | নিজস্ব harness + golden dataset |

### ৭.৪ Device Agent — Windows ও Linux

**সিদ্ধান্ত পরিবর্তন:** v1-এ Go বলেছিলাম। এখন সুপারিশ **C#/.NET** (Worker Service), কারণ: (ক) Windows GUI অটোমেশনের নেটিভ API (UI Automation) .NET-এ সহজ; (খ) Core-এর সঙ্গে একই ভাষা ও Protobuf/gRPC কোডজেন; (গ) Windows Service/Linux systemd হোস্টিং বিল্ট-ইন; (ঘ) টিমের একটিই প্রধান ভাষা। Go-র সুবিধা (ছোট বাইনারি, কম মেমরি) এখানে নির্ণায়ক নয়। **Agent ↔ Core সীমানা gRPC Contract**, তাই ভবিষ্যতে ভাষা বদলানো সম্ভব।

```
nexus-device-agent/
├── Agent.Core/            # Domain+Application: Job validation, Policy-lite, state, retry (OS-নিরপেক্ষ, pure)
├── Agent.Ports/           # ITerminalExecutor, IGuiController, IUpdater, ISnapshotter, ISecureStore
├── Agent.Host.Service/    # Windows Service / systemd hosting, gRPC client (outbound mTLS)
├── Agent.Adapters.Windows/  # ConPTY, Windows Service control, Registry, WMI
├── Agent.Adapters.Linux/    # PTY, systemd, package managers
├── Agent.GuiHelper.Windows/ # ★ আলাদা প্রসেস: ইউজারের ইন্টারঅ্যাকটিভ সেশনে চলে (FlaUI/UIA, SendInput, স্ক্রিনশট)
├── Agent.GuiHelper.Linux/   # X11: xdotool + AT-SPI; Wayland: ydotool/portal (সীমাবদ্ধতা সহ)
├── Agent.Updater/         # স্বাধীন আপডেটার (A/B স্লট, Cosign যাচাই, রোলব্যাক)
└── tests/
```
- **★ গুরুত্বপূর্ণ:** Windows-এ Service "Session 0"-এ চলে, ডেস্কটপ দেখতে পায় না। তাই GUI কাজের জন্য **ইউজার-সেশনে আলাদা Helper প্রসেস** লাগবে; Service ↔ Helper স্থানীয় IPC (named pipe/Unix socket) দিয়ে। E1 Lab VM-এ অটো-লগইন সেশন।
- Agent ভেতরে: স্থানীয় **SQLite** (অফলাইন কিউ/অবস্থা) — EF নয়, সরল স্টোর।
- Publish: self-contained single-file (`win-x64`, `linux-x64`, প্রয়োজনে `linux-arm64`); সাইনিং: Windows Authenticode + Cosign।
- ডিভাইসে Policy-lite: সাইন যাচাই, expiry, target, ঝুঁকি-শ্রেণি, resource limit (সার্ভারের সিদ্ধান্ত **দ্বিতীয়বার** ডিভাইসে যাচাই)।
- Linux GUI: Wayland-এ ইনপুট ইনজেকশন সীমিত — E1 ভিডিও/সেশনে X11 (Xvfb/Xorg) ব্যবহার করুন; এটি Phase 4-এর PoC-তে যাচাই করতে হবে।

### ৭.৫ Computer-Use / Sandbox (E0/E1)
| বিষয় | সিদ্ধান্ত |
|---|---|
| E0 | Docker/containerd (শুরু), পরে Firecracker/KVM microVM (শক্ত আইসোলেশন) |
| E1 | KVM/QEMU বা Proxmox/libvirt-এ Windows ও Linux VM; স্ন্যাপশট/রিভার্ট |
| ব্রাউজার | Playwright (Python বা .NET বাইন্ডিং) — আলাদা নেটওয়ার্কে |
| GUI লুপ | Orchestrator (Python) সিদ্ধান্ত নেয় → Execution Gateway → Helper অ্যাকশন করে → স্ক্রিনশট/ট্রি ফেরত |
| Windows VM লাইসেন্স | আপনার লাইসেন্স শর্ত যাচাই করুন |

### ৭.৬ Infra/Data (v2-র মতোই)
PostgreSQL (+pgvector), Temporal, Valkey (ঐচ্ছিক), MinIO বা ডিস্ক-ভলিউম, OpenBao/SOPS, OpenTelemetry+Prometheus+Grafana+Loki, Caddy, Docker Compose। Auth/Gateway: Caddy/YARP (ঐচ্ছিক)।

---

## ৮. .NET সলিউশন কাঠামো (Core)

```
nexus-core/
├── src/
│   ├── BuildingBlocks/
│   │   ├── Nexus.SharedKernel/          # Result, AggregateRoot, ValueObject, DomainEvent, Clock, Ids
│   │   ├── Nexus.Application.Abstractions/   # ICommand, IQuery, IPipelineBehavior, IUnitOfWork
│   │   ├── Nexus.Infrastructure.Core/   # Outbox, EF base, Polly, telemetry
│   │   └── Nexus.Contracts.Generated/   # nexus-contracts থেকে জেনারেটেড (proto/OpenAPI)
│   ├── Modules/
│   │   ├── Tasking/
│   │   │   ├── Nexus.Tasking.Domain/
│   │   │   ├── Nexus.Tasking.Application/
│   │   │   ├── Nexus.Tasking.Infrastructure/   # EF DbContext (schema "tasking"), Dapper queries
│   │   │   ├── Nexus.Tasking.Api/              # endpoints
│   │   │   └── Nexus.Tasking.Contracts/        # অন্য মডিউলের জন্য public interface/event
│   │   ├── PolicyApproval/ … Execution/ … Devices/ … Resolution/ …
│   │   └── (বাকি মডিউল একই কাঠামো)
│   ├── Hosts/
│   │   ├── Nexus.Api.Host/              # Composition root (সব মডিউল রেজিস্টার)
│   │   ├── Nexus.Workflows.Host/        # Temporal worker (Workflows + Activities)
│   │   └── Nexus.DeviceControl.Host/    # gRPC endpoint for agents
├── tests/
│   ├── Nexus.ArchitectureTests/         # নির্ভরতা-নিয়ম
│   ├── <Module>.UnitTests/ · <Module>.IntegrationTests/ (Testcontainers)
│   └── Nexus.ContractTests/
└── Directory.Build.props · .editorconfig · global.json
```
Module-এর `Contracts` প্রজেক্ট ছাড়া অন্য মডিউল কিছুই reference করতে পারবে না (architecture test)।

---

## ৯. Workflow/Temporal-এর সাথে Domain-এর সীমানা

- **Workflow কোড = কেবল ক্রম + সিদ্ধান্ত-বিন্দু** (deterministic, কোনো I/O নেই)। I/O সব **Activity**-তে।
- Activity = Application use case-এর পাতলা মোড়ক (একই Action Pipeline)।
- Workflow ↔ Domain: Workflow সরাসরি DB ছোঁয় না; Activity-র মাধ্যমে Application ডাকে।
- Signal: Approval সিদ্ধান্ত, pause/cancel। Query: লাইভ স্ট্যাটাস।
- Workflow ভার্সনিং: `GetVersion`/patching; পুরনো চলমান workflow-এর সঙ্গে সামঞ্জস্য রেখে বদল।

---

## ১০. রিপোজিটরি তালিকা — আপডেটেড (৯টি; শুরুতে ৪টি)

ভাষা বহুমুখী হওয়ায় Web ও Core আলাদা হলো; Contract আলাদা রিপোতে (চার ভাষায় ব্যবহৃত)।

| # | রিপো | ভাষা | মূল বিষয় |
|---|---|---|---|
| 1 | `nexus-contracts` | Protobuf/OpenAPI/JSON Schema | **একক সত্য-উৎস:** API, gRPC, ইভেন্ট, Plan schema; CI জেনারেট করে .NET/TS/Python প্যাকেজ |
| 2 | `nexus-core` | C# | API, Workflows, Device Control, সব মডিউল |
| 3 | `nexus-web` | TypeScript | Admin Panel (PWA) |
| 4 | `nexus-ai-orchestrator` | Python | Planner, Agents, Resolution adapters, evals |
| 5 | `nexus-device-agent` | C# | Windows/Linux Agent + Helpers + Updater |
| 6 | `nexus-computer-use` | মিশ্র | sandbox/VM ইমেজ, নিয়ন্ত্রিত নেটওয়ার্ক, browser runner |
| 7 | `nexus-learning` | Python | ডেটা পাইপলাইন, fine-tune, eval harness (ডেটাসেট নয়) |
| 8 | `nexus-infra` | YAML/HCL/Shell | Compose/IaC, reusable CI, deploy-agent, backup, monitoring |
| 9 | `nexus-governance` | YAML/MD | Policy, workflow টেমপ্লেট, প্রম্পট/Agent ডেফিনিশন, ADR, থ্রেট মডেল |

**শুরু (Phase 0–2):** `nexus-contracts`, `nexus-core`, `nexus-web`, `nexus-infra` (+ governance-এর ফোল্ডার আপাতত `nexus-infra`-এ)। Phase 3-এ orchestrator; Phase 4-এ agent+computer-use; Phase 8-এ learning।

**Contract workflow:** `nexus-contracts`-এ PR → breaking-change detector (buf breaking / oasdiff) → merge → ট্যাগ → জেনারেটেড প্যাকেজ publish → ব্যবহারকারী রিপো Renovate/Dependabot-এর PR পায়। এভাবে Web/Core/Python/Agent একই ভাষায় কথা বলে।

---

## ১১. মান-নিয়ন্ত্রণ — নিয়ম মানা নিশ্চিত করার ব্যবস্থা

| প্রক্রিয়া | টুল |
|---|---|
| আর্কিটেকচার নির্ভরতা | NetArchTest/ArchUnitNET (.NET), import-linter (Python), eslint-plugin-boundaries (TS) |
| Pipeline-এড়ানো রোধ | Architecture test: "Executor-কে শুধু ActionPipeline ডাকতে পারে" |
| কোড স্টাইল | `.editorconfig`, analyzers `TreatWarningsAsErrors`, ruff, ESLint, Prettier |
| Contract সামঞ্জস্য | buf breaking, oasdiff, contract tests |
| AI আচরণ | Eval স্যুট + golden plans + prompt-injection কেস; CI গেট |
| নিরাপত্তা | CodeQL, gitleaks, dependency audit, SBOM |
| ডকুমেন্টেশন | ADR, module README (উদ্দেশ্য/নির্ভরতা/নিরাপত্তা), C4 ডায়াগ্রাম (Structurizr/Mermaid) |
| PR-টেমপ্লেট | কোন NEP ধাপ/মডিউল বদলাল, ঝুঁকি, টেস্ট প্রমাণ, rollback |

---

## ১২. Extension Recipes — নতুন কিছু যোগের নির্ধারিত ধাপ

**নতুন Tool যোগ:** ১) `nexus-contracts`-এ input/output schema ২) `Resource/Tool Registry`-তে এন্ট্রি (risk, scope, data-class সীমা, timeout) ৩) Adapter (Port ইমপ্লিমেন্ট) + Decorators (logging/redaction/metering) ৪) Policy rule ৫) sandbox টেস্ট + eval কেস ৬) Admin activation। *(Action Pipeline-এ নতুন কোড লাগে না।)*

**নতুন Agent যোগ:** ১) Agent definition (Git, ভার্সনড) ২) LangGraph গ্রাফ (Template Method কাঠামো) ৩) allowed_tools ৪) golden eval স্যুট ৫) staging → stable চ্যানেল।

**নতুন Task-type টেমপ্লেট:** workflow YAML + acceptance + golden test + ঝুঁকি-পর্যালোচনা।

**নতুন API endpoint:** Contract (OpenAPI) আগে → Command/Query + handler → Policy/permission → Validation → test → কোডজেন TS ক্লায়েন্ট রিজেনারেট → ডক।

**নতুন Module:** কাঠামো টেমপ্লেট (dotnet new template) → নিজস্ব schema → Contracts প্রজেক্ট → Architecture test-এ রেজিস্টার → README + ADR।

**নতুন Connector:** Adapter + OAuth scope ন্যূনতম + Terms/ToS পর্যালোচনা + অনুমোদন-নীতি।

**নতুন Skill:** Candidate → টেস্ট (E0/E1) → Review → Verified → Published (E2 ব্যবহারের আগে মানুষ)।

---

## ১৩. Python Orchestrator-এর স্থির কাঠামো (Hexagonal)

```
nexus-ai-orchestrator/
├── src/orchestrator/
│   ├── domain/        # pure: Plan, Step, Score, Rules (I/O নেই)
│   ├── ports/         # LLMPort, CoreGatewayPort, RetrievalPort, ClockPort
│   ├── adapters/      # ollama.py, anthropic.py, openai.py, core_grpc.py, pgvector_ro.py
│   ├── graphs/        # planner_graph.py, coding_graph.py, research_graph.py, qa_graph.py
│   ├── templates/     # task-type টেমপ্লেট লোডার (nexus-governance থেকে)
│   ├── safety/        # injection_guard, redaction, schema_repair (সর্বোচ্চ ২ বার)
│   └── api/           # gRPC servicer
├── evals/  tests/  pyproject.toml
```
- প্রতিটি graph: নোড = ছোট ফাংশন; edge শর্ত = domain-এর pure function; max_steps/max_cost/timeout বাধ্যতামূলক।
- LLM আউটপুট = Pydantic মডেল; ব্যর্থ → `schema_repair` (≤২) → অন্যথায় `PlanInvalid` ত্রুটি।

---

## ১৪. ফেজ-ভিত্তিক বাস্তবায়ন ক্রম — আর্কিটেকচারের দৃষ্টিকোণ

| ফেজ | আর্কিটেকচার-সংক্রান্ত ডেলিভারেবল |
|---|---|
| 0 | ADR: Clean+DDD+Modular Monolith, .NET সিদ্ধান্ত, NEP ডকুমেন্ট, Contract-first নীতি; `nexus-contracts` ও solution টেমপ্লেট, architecture tests |
| 1 | SharedKernel, pipeline behaviors (Validation→Auth→Idempotency→Tx→Audit), IdentityAccess, AuditObservability, PolicyApproval (chain + pure functions), outbox |
| 2 | Tasking (state machine), Temporal workflow-এ NEP S0–S10 কঙ্কাল (AI ছাড়া, স্টাব দিয়ে), Web: Task/Approval স্ক্রিন |
| 3 | Orchestrator (Hexagonal), Planner/QA গ্রাফ, Task-type টেমপ্লেট ২–৩টি, Resolution (L0–L5) |
| 4 | Execution context + E0 sandbox + Action Pipeline-এর Execute ধাপ; Linux GUI helper PoC |
| 5 | Device Agent (Windows service + GUI helper PoC আগে), Command Risk Classifier |
| 6–8 | Skills/Connectors/Wallet/Learning (v2 অনুযায়ী) |

**নীতি:** Phase 2-এর শেষে AI ছাড়াই (স্টাব দিয়ে) পুরো NEP ক্রম প্রমাণিত হতে হবে — তারপর AI ঢোকানো। এতে ক্রম ও নিরাপত্তা আগে স্থির, AI পরে "ফাঁকে বসে"।

---

## ১৫. ঝুঁকি ও সীমাবদ্ধতা (সততার সাথে)

1. **১০০% একই আউটপুট নিশ্চিত করা যায় না** — যা নিশ্চিত করা যায়: একই প্রক্রিয়া, একই যাচাই, অবৈধ আউটপুট অগ্রহণযোগ্য। Task-type টেমপ্লেট যত বাড়বে, ধারাবাহিকতা তত বাড়বে।
2. **DDD-র ওভারহেড:** ছোট টিমে অতিরিক্ত অ্যাবস্ট্রাকশনের ঝুঁকি। নিয়ম: যেখানে ব্যবসায়িক জটিলতা (Tasking, Policy, Resolution, Execution) সেখানে পূর্ণ DDD; সরল CRUD মডিউলে (Settings, Notifications) হালকা কাঠামো (Application+Infrastructure যথেষ্ট)।
3. **Windows GUI ও Linux Wayland** — প্রযুক্তিগতভাবে সবচেয়ে অনিশ্চিত; Phase 4–5-এ PoC আগে।
4. **লাইসেন্স-পরিবর্তন:** MediatR/MassTransit-এর মতো লাইব্রেরি বাণিজ্যিক হয়েছে — প্রতিটি ডিপেন্ডেন্সির লাইসেন্স dependency inventory-তে রাখুন।
5. **একাধিক ভাষা (C#, TS, Python):** Contract-first ও কোডজেন ছাড়া এটি ভেঙে পড়বে; তাই `nexus-contracts` বাধ্যতামূলক।

---

## ১৬. আপনার সিদ্ধান্ত দরকার

1. **টিমের মূল দক্ষতা .NET কি?** হ্যাঁ হলে এই প্ল্যান; না হলে NestJS/TypeScript বিকল্প (আর্কিটেকচার একই)।
2. **Device Agent: .NET (সুপারিশ) নাকি Go?** সিদ্ধান্ত ফেজ ৫-এর আগে নিলেও চলে; Contract একই।
3. Task-type টেমপ্লেটের প্রথম ৫টি তালিকা কী হবে (আপনার বাস্তব কাজ থেকে)?
4. উপরের v2 §১৪-এর ৭টি সিদ্ধান্ত (আসল সার্ভারে স্বাধীনতা, খরচ-সীমা, data-class ইত্যাদি)।
