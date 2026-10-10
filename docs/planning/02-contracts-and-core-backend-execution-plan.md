# প্ল্যান ২: কন্ট্রাক্টস ও কোর ব্যাকএন্ড বাস্তবায়ন পরিকল্পনা (Contracts & Core Backend)

এই প্ল্যানে `nexus-contracts` এবং `nexus-core` রিপোজিটরির স্থাপত্য, মডিউলার মনোলিথ কাঠামো, ক্লিন আর্কিটেকচার, ডোমেন ড্রিভেন ডিজাইন (DDD), ডাটাবেস ডিজাইন এবং টেম্পোরাল ওয়ার্কফ্লো বাস্তবায়নের বিস্তারিত ধাপ নির্ধারণ করা হলো।

---

## ১. ফেজ ও ধাপভিত্তিক এক্সিকিউশন রোডম্যাপ

```
ধাপ ১: Contract-First সংজ্ঞা (Protobuf + OpenAPI + Schemas)
  │
  ▼
ধাপ ২: Multi-Language Code Generation CI Pipeline
  │
  ▼
ধাপ ৩: nexus-core সলিউশন ও BuildingBlocks লেয়ার স্থাপন
  │
  ▼
ধাপ ৪: Bounded Contexts ও Modular Monolith স্কিমা ম্যাপিং
  │
  ▼
ধাপ ৫: Mediator Action Pipeline & Pure Domain Rules বাস্তবায়ন
  │
  ▼
ধাপ ৬: Temporalio .NET SDK Integration (NEP S0–S10 Workflow কঙ্কাল)
  │
  ▼
ধাপ ৭: NetArchTest ও Integration Tests দিয়ে নিরাপত্তা ও নির্ভরযোগ্যতা নিশ্চিতকরণ
```

---

## ২. ধাপ ১: `nexus-contracts` সিঙ্গেল সোর্স অব ট্রুথ স্থাপন

### ২.১ Protobuf ও OpenAPI সংজ্ঞা
- **Protobuf স্ট্রাকচার:**
  - `nexus/core/v1/task.proto`: Task Creation, Status Query, Task Event streaming.
  - `nexus/core/v1/approval.proto`: Approval Request, Signal, Audit event.
  - `nexus/orchestrator/v1/orchestrator.proto`: GeneratePlan, RepairPlan, ValidateStep, EvaluateCase.
  - `nexus/device/v1/device.proto`: RegisterDevice, Heartbeat, CommandStream, ExecuteCommandResponse.
- **OpenAPI v3.1 (`openapi/v1/nexus-api.yaml`):**
  - RESTful এন্ডপয়েন্ট: `/api/v1/tasks`, `/api/v1/approvals`, `/api/v1/devices`, `/api/v1/policies`, `/api/v1/resources`।
  - স্ট্যান্ডার্ডাইজড RFC 7807 Problem Details এরর হ্যান্ডলিং ও Idempotency-Key হেডার।
- **JSON Schemas (`schemas/plans/v1/plan.json`):**
  - এআই প্ল্যানারের জন্য স্ট্রাকচার্ড স্কিমা (ধাপের আইডি, অ্যাকশন, প্যারামিটার, ডিপেন্ডেন্সি গ্রাফ, ঝুঁকি রেটিং, একসেপ্টেন্স ক্রাইটেরিয়া)।

### ২.২ অটোমেটেড কোড-জেন সিআই পাইপলাইন
- `buf lint` এবং `buf breaking` (মেইন ব্রাঞ্চের বিরুদ্ধে ব্রেকিং চেঞ্জ টেস্ট)।
- `buf generate` চালিয়ে স্বয়ংক্রিয়ভাবে তৈরি করা হবে:
  - C# ক্লাস এবং gRPC ক্লায়েন্ট/সার্ভিস স্টাব (`Dapplesoft.Nexus.Contracts.Generated`)
  - TypeScript টাইপস এবং gRPC-web/Connect-es স্টাব
  - Python Pydantic v2 মডেলস এবং gRPC servicer stubs।

---

## ৩. ধাপ ২: `nexus-core` সলিউশন ও আর্কিটেকচার

### ৩.১ সলিউশন আর্কিটেকচার (.NET 10 LTS)
- **`src/BuildingBlocks/`**:
  - `Nexus.SharedKernel`: `Result<T, Error>`, `AggregateRoot<TId>`, `Entity<TId>`, `ValueObject`, `IDomainEvent`, `SystemClock`।
  - `Nexus.Application.Abstractions`: `ICommand`, `IQuery`, `IPipelineBehavior`, `IUnitOfWork`, `IRepository<T>`।
  - `Nexus.Infrastructure.Core`: Transactional Outbox প্যাটার্ন, Npgsql EF Core কনফিগারেশন, Dapper কানেকশন ফ্যাক্টরি, Polly রেসিলিয়েন্স পলিসি, OpenTelemetry মিটারিং।
  - `Nexus.Contracts.Generated`: `nexus-contracts` থেকে প্রস্তুতকৃত কোড।

### ৩.২ Bounded Contexts (মডিউলসমূহ) ও ডাটাবেস স্কিমা
প্রতিটি মডিউলের নিজস্ব ফোল্ডার ও স্কিমা থাকবে:
1. **`Tasking` (স্কিমা `tasking.*`):**
   - Aggregate Root: `TaskAggregate` (Status: DRAFT, CLASSIFIED, PLANNED, VALIDATED, AUTHORIZED, RUNNING, COMPLETED, FAILED, CANCELLED)।
   - Entities: `PlanVersion`, `TaskStep`, `StepResult`।
2. **`PolicyApproval` (স্কিমা `policy.*`):**
   - Aggregate Roots: `PolicySet`, `ApprovalRequest`।
   - Value Objects: `RiskLevel`, `DataClass`, `ActionHash`, `Decision`।
3. **`Execution` (স্কিমা `execution.*`):**
   - Aggregate Root: `ExecutionSession`।
   - Entities: `EnvironmentAllocation` (E0, E1, E2, E3), `CommandExecutionLog`।
4. **`Devices` (স্কিমা `devices.*`):**
   - Aggregate Root: `DeviceAggregate`।
   - Entities: `DeviceHeartbeat`, `DeviceSession`, `EnrolledCredential`।
5. **`Resolution` (স্কিমা `resolution.*`):**
   - Aggregate Root: `ResolutionCase`।
   - Resolution Ladder স্ট্র্যাটেজিস (L0 Self-Heal থেকে L7 Admin Escalation)।
6. **`AuditObservability` (স্কিমা `audit.*`):**
   - Append-only `audit_events` (ডাটাবেস লেভেলে UPDATE/DELETE নিষিদ্ধ)।

---

## ৪. ধাপ ৩: Action Pipeline ও পিওর ডোমেন ইঞ্জিন

### ৪.১ Mediator Action Pipeline (১২-ধাপের গ্যারান্টি)
যেকোনো পার্শ্বপ্রতিক্রিয়া সৃষ্টিকারী কাজের জন্য এই পাইপলাইন আচরণ বাধ্যতামূলক:
1. `ValidateBehavior`: স্কিমা ও প্যারামিটার রেঞ্জ যাচাই।
2. `AuthenticateBehavior`: অ্যাক্টর ও রোল ক্রেডেনশিয়াল চেক।
3. `RiskClassifyBehavior`: সার্ভার-সাইড কমান্ড রিস্ক ক্লাস নির্ধারণ (AI এর দাবি অগ্রাহ্য)।
4. `PolicyAuthorizeBehavior`: Chain of Responsibility পলিসি রুলস চেক।
5. `QuotaBudgetBehavior`: রেট-লিমিট ও বাজেট কোটা অ্যাপ্রুভাল।
6. `ApprovalGateBehavior`: `REQUIRE_APPROVAL` হলে টেম্পোরাল সিগন্যালের অপেক্ষা।
7. `IdempotencyBehavior`: ক্যাশড কিউ বা ডুপ্লিকেট টাস্ক ডিটেকশন।
8. `PreSnapshotBehavior`: E1/E2 পরিবেশ হলে স্ন্যাপশট ক্যাপচার।
9. `ExecutionBehavior`: নির্দিষ্ট এনভায়রনমেন্টে এক্সেকিউশন।
10. `SanitizeBehavior`: সিক্রেট/PII রিড্যাকশন।
11. `AuditRecordBehavior`: Append-only অডিট লগে রাইট।
12. `OutboxEmitBehavior`: ট্রানজ্যাকশনের মধ্যে ডোমেন ইভেন্ট ডেসপ্যাচ।

### ৪.২ পিওর ডোমেন ফাংশনস (Pure Functions)
নিম্নোক্ত লজিকগুলোতে কোনো ডাটাবেস বা নেটওয়ার্ক I/O থাকবে না:
- State Transition লজিক (`CanTransitionTo()`)
- Policy Evaluation Engine (শর্ত যাচাই ও অনুমোদন ফলাফল)
- Plan Validation (সাইক্লিক ডিপেন্ডেন্সি এবং বাজেট চেক)
- Resolution Scoring (`Score = P·মান − খরচ·w1 − ঝুঁকি·w2`)
- ActionHash ও Checksum ক্যালকুলেটর।

---

## ৫. ধাপ ৪: Temporal Workflows ও NEP S0–S10 ইঞ্জিন

### ৫.১ নেক্সাস এক্সিকিউশন প্রোটোকল (NEP)
- `NexusExecutionWorkflow` হার্ডকোডেড ১১টি স্টেপ পরিচালনা করবে:
  - `S0_Intake`: রিকোয়েস্ট যাচাই ও টাস্ক ড্রাফট তৈরি।
  - `S1_Classify`: টাস্ক টাইপ ও রিস্ক লেভেল নির্ধারণ।
  - `S2_Context`: প্রাসঙ্গিক নলেজ ও স্কিল রিট্রিভাল।
  - `S3_Plan`: ওয়ার্কফ্লো টেমপ্লেট থেকে লোড অথবা এআই প্ল্যান জেনারেশন।
  - `S4_Validate`: পিওর ডোমেন ফাংশন দিয়ে প্ল্যান ভ্যালিডেশন।
  - `S5_Authorize`: পলিসি চেইন দ্বারা অনুমোদন মূল্যায়ন।
  - `S6_Approve`: প্রয়োজন হলে অ্যাডমিন হিউম্যান সিগন্যালের অপেক্ষা।
  - `S7_Execute`: Action Pipeline এর মাধ্যমে ধাপসমূহ এক্সিকিউট করা।
  - `S8_Verify`: একসেপ্টেন্স ক্রাইটেরিয়া টেস্ট ও কিউএ ভেরিফিকেশন।
  - `S9_Report`: সারসংক্ষেপ ও প্রমাণাদি প্রস্তুতকরণ।
  - `S10_Learn`: ক্যান্ডিডেট স্কিল এক্সট্রাকশন ও রেজোলিউশন হিস্ট্রি আপডেট।

---

## ৬. টেস্ট ও কোয়ালিটি গেটস

1. **NetArchTest:**
   - ডোমেন লেয়ার কোনো ফ্রেমওয়ার্ক (EF/HTTP/Temporal) রেফারেন্স করতে পারবে না।
   - কোনো মডিউল অন্য মডিউলের ডোমেন বা ডাটাবেস সরাসরি স্পর্শ করতে পারবে না।
   - এক্সেকিউটর শুধুমাত্র `ActionPipeline` দ্বারা কল করা যাবে।
2. **Integration Tests (Testcontainers):**
   - PostgreSQL এবং Temporal কনটেইনারের মাধ্যমে এন্ড-টু-এন্ড টেস্ট।
   - কনকারেন্সি ও অপটিমিস্টিক লকিং (`xmin`) যাচাইকরণ।
