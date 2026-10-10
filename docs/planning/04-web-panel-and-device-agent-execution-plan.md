# প্ল্যান ৪: ওয়েব প্যানেল ও ডিভাইস এজেন্ট বাস্তবায়ন পরিকল্পনা (Web Panel & Device Agent)

এই প্ল্যানে `nexus-web` (Next.js অ্যাডমিন প্যানেল) এবং `nexus-device-agent` (উইন্ডোজ ও লিনাক্স ডিভাইস এক্সেকিউশন এজেন্ট) রিপোজিটরির পূর্ণাঙ্গ স্থাপত্য, ইন্টারফেস আর্কিটেকচার, লাইভ স্ট্রিমিং ও নিরাপদ ডিভাইস অটোমেশনের বিস্তারিত বাস্তবায়ন পরিকল্পনা সংজ্ঞায়িত করা হলো।

---

## ১. ফেজ ও ধাপভিত্তিক এক্সিকিউশন রোডম্যাপ

```
ধাপ ১: nexus-web প্রজেক্ট সেটআপ (Next.js 15, Feature-Sliced Design, Tailwind, shadcn/ui)
  │
  ▼
ধাপ ২: OpenAPI জেনারেটেড ক্লায়েন্ট ও রিয়েল-টাইম SSE ইভেন্ট স্ট্রিমিং লেয়ার
  │
  ▼
ধাপ ৩: কোর প্যানেল স্ক্রিনসমূহ (টাস্ক ট্র্যাকার, React Flow প্ল্যান গ্রাফ, অ্যাপ্রুভাল গেট)
  │
  ▼
ধাপ ৪: ইন্টারেক্টিভ কনসোল (xterm.js টার্মিনাল ও noVNC লাইভ GUI ভিউয়ার)
  │
  ▼
ধাপ ৫: nexus-device-agent (.NET 10 Worker Service, Outbound mTLS gRPC)
  │
  ▼
ধাপ ৬: উইন্ডোজ সেশন-০ আইসোলেশন বাইপাস (GuiHelper IPC ও ConPTY টার্মিনাল)
  │
  ▼
ধাপ ৭: লিনাক্স অ্যাডাপ্টার (PTY, systemd) ও A/B স্লট অটো-আপডেটার
```

---

## ২. ধাপ ১: `nexus-web` অ্যাডমিন কনসোল আর্কিটেকচার

### ২.১ টেকনোলজি স্ট্যাক ও ফ্রেমওয়ার্ক
- **ফ্রেমওয়ার্ক:** Next.js 15+ (App Router), React 19, TypeScript।
- **স্টাইলিং ও কম্পোনেন্টস:** Tailwind CSS, shadcn/ui, Lucide Icons।
- **স্টেট ম্যানেজমেন্ট ও ক্যাশিং:** TanStack React Query v5 (সার্ভার স্টেট) + Server-Sent Events (SSE) লাইভ আপডেটস।
- **ফর্ম ভ্যালিডেশন:** React Hook Form + Zod (ক্লায়েন্ট সাইড ভ্যালিডেশন)।
- **ভিজ্যুয়ালাইজেশন:** React Flow (টাস্ক ও প্ল্যান DAG গ্রাফ), Recharts (মেট্রিক্স ও কোটা চার্ট)।
- **অ্যাক্সেস কন্ট্রোল:** OpenAPI জেনারেটেড টাইপড ক্লায়েন্ট (`openapi-typescript` / `orval`)।

### ২.২ ডিরেক্টরি সংগঠন (Feature-Sliced Design)
```text
nexus-web/
├── src/
│   ├── app/                      # App router layout & route pages
│   │   ├── (dashboard)/
│   │   │   ├── tasks/
│   │   │   ├── approvals/
│   │   │   ├── devices/
│   │   │   └── settings/
│   │   └── api/                  # BFF / SSE Proxy (if needed)
│   ├── features/                 # বিজনেস ডোমেন ফিচার মডিউলস
│   │   ├── tasks/                # Task list, Task detail, Plan visualizer
│   │   ├── approvals/            # Approval modal, Diff viewer, Sign action
│   │   ├── devices/              # Device inventory, Health, Enrollment
│   │   └── interactive/          # xterm.js terminal, noVNC desktop viewer
│   ├── components/ui/            # shadcn/ui generic primitives
│   └── lib/
│       ├── api-client/           # Auto-generated from nexus-contracts
│       └── sse-client.ts         # Resilient event-stream listener
└── tests/                        # Vitest & Playwright E2E
```

### ২.৩ কোর UI মডিউল ও স্ক্রিনসমূহ
1. **Interactive Plan DAG (React Flow):**
   - টাস্কের প্রতিটি স্টেপ ভিজ্যুয়াল নোড হিসেবে প্রদর্শিত হবে।
   - নোডের স্টেট অনুযায়ী কালার কোডিং (Pending=Slate, Running=Blue Pulse, Completed=Emerald Green, Failed=Crimson Red)।
2. **Approval Gateway & Risk Diff Viewer:**
   - অ্যাডমিনের জন্য হাই-রিস্ক কমান্ড অনুমোদনের স্পেশাল পপ-আপ।
   - প্রস্তাবিত কমান্ড ও প্রাক্কলিত ঝুঁকির ডিটেইলস ডিসপ্লে।
   - One-Click Approve / Reject বাটন যা টেম্পোরাল ওয়ার্কফ্লোতে সিগন্যাল পাঠাবে।
3. **Live Terminal & Session Player (xterm.js):**
   - রিয়েল-টাইম শেল আউটপুট স্ট্রিমিং ও স্ক্রোলব্যাক সাপোর্ট।
4. **Remote GUI Takeover (noVNC):**
   - E1 ল্যাব ভিএম বা ডিভাইসের লাইভ ডেস্কটপ দেখার ব্যবস্থা।

---

## ৩. ধাপ ২: `nexus-device-agent` আর্কিটেকচার (.NET 10 LTS)

### ৩.১ সিস্টেম ডিজাইন ও নিরাপত্তা প্যাটার্ন
- **আউটবাউন্ড-অনলি mTLS gRPC:**
  - ডিভাইসটি কোনো ওপেন ইনবাউন্ড পোর্ট শুনবে না (জিরো ফায়ারওয়াল এক্সপোজার)।
  - আউটবাউন্ড কানেকশন দিয়ে `nexus-core`-এর সাথে দীর্ঘমেয়াদী বাইডাইরেকশনাল gRPC স্ট্রিম বজায় রাখবে।
- **ডিভাইস-সাইড পলিসি ভেরিফিকেশন (Policy-Lite):**
  - সার্ভার থেকে কমান্ড আসার পর ডিভাইস এজেন্ট দ্বিতীয়বার যাচাই করবে:
    1. ডিজিটাল সিগনেচার সঠিক কিনা।
    2. কমান্ডের টাইমস্ট্যাম্প এক্সপায়ার হয়েছে কিনা।
    3. ডিভাইস রিসোর্স লিমিট (CPU/RAM কোটা) অতিক্রম করছে কিনা।

### ৩.২ সলিউশন প্রজেক্ট সংগঠন
```text
nexus-device-agent/
├── Agent.Core/              # OS-অজ্ঞাত ডোমেন: Job Engine, State, Result Envelope, Local DB
├── Agent.Ports/             # ইন্টারফেস: ITerminalExecutor, IGuiController, IUpdater
├── Agent.Host.Service/      # .NET BackgroundService (Windows Service / Linux systemd)
├── Agent.Adapters.Windows/  # ConPTY, Windows Service API, Registry
├── Agent.Adapters.Linux/    # PTY, systemd, package managers
├── Agent.GuiHelper.Windows/ # ইন্টারেক্টিভ ইউজার-সেশন প্রসেস (FlaUI, SendInput, ScreenCapture)
├── Agent.GuiHelper.Linux/   # X11 (Xdotool/Xvfb) ও Wayland কম্পোনেন্ট
├── Agent.Updater/           # A/B পার্টিশন সেলফ-আপডেটার (Cosign সিগনেচার যাচাই)
└── tests/
```

### ৩.৩ উইন্ডোজ সেশন-০ আইসোলেশন বাইপাস মেকানিজম (Session 0 Isolation Solution)
- **চ্যালেঞ্জ:** উইন্ডোজ ব্যাকগ্রাউন্ড সার্ভিস চলে "Session 0"-তে, যা ব্যবহারকারীর ইন্টারেক্টিভ ডেস্কটপ বা উইন্ডো দেখতে বা ক্লিক করতে পারে না।
- **সমাধান আর্কিটেকচার:**
  1. `Agent.Host.Service` ব্যাকগ্রাউন্ডে সার্ভিস হিসেবে চলবে।
  2. ইউজার যখন লগইন করবে (অথবা E1 ল্যাব ভিএম অটো-লগইন হবে), তখন একটি হালকা ওজনের প্রসেস `Agent.GuiHelper.Windows.exe` ইউজার সেশনে রান করবে।
  3. `Host.Service` এবং `GuiHelper`-এর মধ্যে লোকাল আইপিসি (Named Pipe / Unix Domain Socket) সংযোগ থাকবে।
  4. স্ক্রিনশট নেওয়া, কীবোর্ড/মাউস ইভেন্ট ইনপুট এবং FlaUI ইউআই অটোমেশন পরিচালনা করবে `GuiHelper`।

### ৩.৪ টার্মিনাল এক্সিকিউশন ও সিউডো-টিটিওয়াই (ConPTY / PTY)
- সাধারণ `Process.Start` না করে ConPTY (Windows) এবং POSIX PTY (Linux) ব্যবহার করা হবে, যাতে ANSI কালার, প্রোগ্রেস বার এবং ইন্টারঅ্যাক্টিভ শেল সঠিকভাবে স্ট্রিমিং হতে পারে।

### ৩.৫ রেসিলিয়েন্ট A/B স্লট সেলফ-আপডেটার
- এজেন্টের জন্য থাকবে একটি স্বাধীন আপডেটার প্রসেস:
  - নতুন ভার্সন ডাউনলোড → Cosign সিগনেচার ও Checksum ভেরিফিকেশন।
  - স্লট B-তে ফাইল রিপ্লেস → সার্ভিস রিস্টার্ট।
  - ৫ মিনিটের মধ্যে ব্যাকগ্রাউন্ড হেলথচেক ফেইল করলে স্বয়ংক্রিয়ভাবে পূর্বের স্লট A-তে রোলব্যাক।
