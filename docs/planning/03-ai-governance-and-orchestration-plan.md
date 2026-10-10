# প্ল্যান ৩: এআই গভর্ন্যান্স ও পাইথন অর্কেস্ট্রেশন বাস্তবায়ন পরিকল্পনা (Governance & AI Orchestration)

এই প্ল্যানে `nexus-governance` এবং `nexus-ai-orchestrator` রিপোজিটরির স্থাপত্য, ডিক্লেয়ারেটিভ পলিসি-অ্যাজ-কোড, হেক্সাগোনাল আর্কিটেকচার, ল্যাংগ্রাফ (LangGraph) স্টেট মেশিন, রেজোলিউশন ল্যাডার (Resolution Ladder L0–L7) এবং গোল্ডেন এভালুয়েশন বাস্তবায়নের বিস্তারিত ধাপ সংজ্ঞায়িত করা হলো।

---

## ১. ফেজ ও ধাপভিত্তিক এক্সিকিউশন রোডম্যাপ

```
ধাপ ১: nexus-governance রিপোজিটরিতে পলিসি ও টেমপ্লেট কাঠামো তৈরি
  │
  ▼
ধাপ ২: টাস্ক-টাইপ ডিটারমিনিস্টিক ওয়ার্কফ্লো টেমপ্লেটসমূহ লেখা
  │
  ▼
ধাপ ৩: nexus-ai-orchestrator হেক্সাগোনাল প্রজেক্ট কাঠামো ও টুলিং সেটআপ (uv, Pydantic v2)
  │
  ▼
ধাপ ৪: LangGraph ড্রাইভেন প্ল্যানার, কোডিং ও কিউএ গ্রাফ তৈরি
  │
  ▼
ধাপ ৫: টাইপড আউটপুট গার্ডস, বাউন্ডেড স্কিমা রিপেয়ার (≤২) ও সেফটি লেয়ার
  │
  ▼
ধাপ ৬: রেজোলিউশন ল্যাডার (Resolution Ladder L0–L7) স্ট্র্যাটেজি ও এস্কেলেশন
  │
  ▼
ধাপ ৭: গোল্ডেন টেস্ট ডেটাসেট ও অটোমেটেড CI এভালুয়েশন হারনেস
```

---

## ২. ধাপ ১: `nexus-governance` পলিসি-অ্যাজ-কোড ও ওয়ার্কফ্লো টেমপ্লেটস

### ২.১ রিপোজিটরি ডিরেক্টরি সংগঠন
```text
nexus-governance/
├── policies/
│   ├── hard-deny.yaml          # বিধিনিষেধ (e.g. rm -rf /, format drive, direct prod push)
│   ├── data-classification.yaml # C0 (Public), C1 (Internal), C2 (Confidential), C3 (Restricted)
│   ├── env-boundaries.yaml      # E0 (Sandbox), E1 (Lab VM), E2 (Staging), E3 (Production)
│   └── tool-allowlists.yaml     # টুল ব্যবহারের রোলভিত্তিক অনুমতি
├── workflows/
│   └── templates/               # ডিটারমিনিস্টিক টেমপ্লেটস
├── prompts/
│   ├── planner.jinja2
│   ├── qa-verifier.jinja2
│   └── code-generator.jinja2
└── adrs/                        # আর্কিটেকচারাল ডিসিশন রেকর্ডস
```

### ২.২ ডিটারমিনিস্টিক টাস্ক-টাইপ টেমপ্লেটসমূহ (প্রথম ব্যাচ)
এআই যেন শূন্য থেকে সবকিছু কল্পনা না করে, তার জন্য পরিচিত কাজের ব্লুপ্রিন্ট তৈরি:
1. `website.broken_link_audit.yaml`:
   - ইনপুট: `domain`, `max_depth`
   - ধাপ: Domain Validation → Read-Only Crawler (E0) → Link Classifier → Report Generator.
   - একসেপ্টেন্স: `no_write_operations == true`, `report_format == Markdown`.
2. `repository.static_security_scan.yaml`:
   - ইনপুট: `repo_url`, `branch`
   - ধাপ: Shallow Clone (E0) → Semgrep/Trivy Scan → Vulnerability Parser → PR Feedback.
3. `system.log_anomaly_triage.yaml`:
   - ইনপুট: `service_name`, `time_range`
   - ধাপ: Fetch Loki Logs → Pattern Clustering → Root-cause Hypothesis → Triage Ticket.
4. `database.schema_drift_check.yaml`:
   - ইনপুট: `db_cluster`, `target_schema`
   - ধাপ: Dump Metadata → Schema Compare → Difference Script Generation (Read-only).

---

## ৩. ধাপ ২: `nexus-ai-orchestrator` হেক্সাগোনাল আর্কিটেকচার

### ৩.১ প্যাকেজ ও আর্কিটেকচার লেআউট
```text
nexus-ai-orchestrator/
├── src/orchestrator/
│   ├── domain/               # Pure Python: Plan, Step, DependencyGraph, ResolutionScore
│   ├── ports/                # Interfaces: LLMPort, CoreGatewayPort, RetrievalPort
│   ├── adapters/             # Implementations:
│   │   ├── llm_anthropic.py
│   │   ├── llm_ollama.py
│   │   ├── core_grpc_client.py
│   │   └── pgvector_retriever.py
│   ├── graphs/               # LangGraph স্টেট মেশিনস
│   │   ├── planner_graph.py
│   │   ├── qa_graph.py
│   │   └── resolution_graph.py
│   ├── safety/               # Prompt Injection Guard, Redactor, Schema Repairer
│   └── api/                  # gRPC Servicer (nexus-contracts থেকে প্রস্তুত)
├── evals/
│   ├── golden-datasets/
│   └── test_planner_eval.py
└── pyproject.toml            # uv প্যাকেজ ম্যানেজার পরিচালিত
```

### ৩.২ ফ্রেমওয়ার্ক ও টুলিং স্ট্যান্ডার্ডস
- **রানটাইম:** Python 3.12+ (uv পরিচালিত দ্রুত এবং লকড ভার্চুয়াল এনভায়রনমেন্ট)।
- **টাইপিং ও ভ্যালিডেশন:** Strict mypy, Pydantic v2 (zero runtime type ambiguity)।
- **কোড কোয়ালিটি:** Ruff (লিল্টিং এবং ফরম্যাটিং)।

---

## ৪. ধাপ ৩: ল্যাংগ্রাফ স্টেট মেশিন ও ডিটারমিনিস্টিক ফ্লো

### ৪.১ প্ল্যানার স্টেট মেশিন (`planner_graph.py`)
- কোনো ইনফিনিট লুপ নেই; গ্রাফের প্রতিটি নোড একটি নিয়ন্ত্রিত পিওর ফাংশন:
  ```
  [Start] ──> [Check Template] 
                  ├── (Template Found) ──> [Fill Parameters] ──> [Validate Constraints] ──> [Output Plan]
                  └── (New Request)     ──> [Draft Plan (AI)]  ──> [Schema Check]
                                                                     ├── (Valid)   ──> [Validate Constraints]
                                                                     └── (Invalid) ──> [Repair (Max 2)]
                                                                                         ├── (Repaired) ──> [Validate]
                                                                                         └── (Failed)   ──> [L7 Escalation]
  ```
- **Max Steps ও Timeout:** প্রতিটি গ্রাফ এক্সিকিউশনে হার্ড টাইমআউট এবং সর্বোচ্চ স্টেপ লিমিট বাধ্যতামূলক।
- **Temperature Pinning:** প্ল্যানার ও ক্লাসিফায়ারে `temperature=0` এবং মডেল ভার্সন সুনির্দিষ্টভাবে পিন করা থাকবে।

### ৪.২ সেফটি ও বাউন্ডেড স্কিমা রিপেয়ার (Bounded Schema Repair)
- এআই এর আউটপুট সরাসরি টেক্সট হিসেবে গণ্য হবে না; এটি Pydantic ভ্যালিডেটরের মধ্য দিয়ে পাস হতে হবে।
- যদি আউটপুট স্কিমা অমান্য করে:
  1. স্বয়ংক্রিয়ভাবে ভ্যালিডেশন এরর মেসেজ দিয়ে মডেলকে সর্বোচ্চ **২ বার** রিপেয়ার করার অনুরোধ জানানো হবে।
  2. ২ বারের মধ্যে সঠিক আউটপুট দিতে ব্যর্থ হলে টাস্কটি সরাসরি `FAILED_PLANNING` অবস্থায় গিয়ে মানুষের পর্যালোচনার জন্য এস্কেলেট হবে।

---

## ৫. ধাপ ৪: রেজোলিউশন ল্যাডার বাস্তবায়ন (Resolution Ladder L0–L7)

যখন কোনো ধাপ বা কাজ ব্যর্থ হয়, তখন অনিয়ন্ত্রিত রিট্রাই এর বদলে ৮টি ধাপে সমস্যার সমাধান মূল্যায়ন করা হবে:

| লেভেল | স্ট্র্যাটেজি নাম | কার্যপদ্ধতি | অনুমোদন প্রয়োজন |
|---|---|---|---|
| **L0** | Self-Heal | এক্সপোনেনশিয়াল ব্যাকঅফ সহ বাউন্ডেড রিট্রাই (নেটওয়ার্ক বা ট্রানজিয়েন্ট এরর)। | না |
| **L1** | Context Adjustment | প্রম্পট বা কনটেক্সট সাইজ সামঞ্জস্য করা, রিট্রাই উইথ ক্লিয়ার ক্যাশ। | না |
| **L2** | Strategy Shift | বিকল্প টুল ব্যবহার (যেমন: cURL ফেইল করলে WebBrowser ড্রাইভ করা)। | হ্যাঁ (Policy সাপেক্ষে) |
| **L3** | Model Upgrade | জটিল লজিকের জন্য ছোট মডেল থেকে বড় রিজনার মডেলে পরিবর্তন। | কোটা সাপেক্ষে |
| **L4** | Sandbox Revert | E1 ল্যাব স্যান্ডবক্স স্ন্যাপশটে ব্যাক করা এবং ভিন্ন পথে এগোনো। | হ্যাঁ |
| **L5** | Human Guidance | মানুষের কাছ থেকে স্পষ্টীকরণ (Clarification) চাওয়া। | হ্যাঁ |
| **L6** | Assisted Takeover | অ্যাডমিনকে লাইভ কন্ট্রোল দেওয়া (GUI Takeover / Terminal)। | হ্যাঁ |
| **L7** | Hard Escalation | টাস্ক ফেইল ঘোষণা এবং পোস্ট-মর্টেম ও লার্নিং টিকিট তৈরি। | হ্যাঁ |

---

## ৬. ধাপ ৫: গোল্ডেন এভাল স্যুট ও সিআই কোয়ালিটি গেট

1. **Golden Plan Evals:**
   - প্রতিটি স্ট্যান্ডার্ড টাস্কের জন্য একটি আদর্শ প্ল্যান (Golden Baseline) সংরক্ষিত থাকবে।
   - যেকোনো প্রম্পট বা মডেল আপগ্রেডের পর `pytest evals/` চালিয়ে রিগ্রেশন স্কোর পরিমাপ করা হবে (সাদৃশ্য স্কোর ≥ ৯৫%)।
2. **Prompt Injection Testing:**
   - ক্ষতিকর ইনপুট দিয়ে আক্রমণ সিমুলেট করে নিশ্চিত করা হবে যে প্ল্যানার হার্ড-পলিসি বাইপাস করছে না।
