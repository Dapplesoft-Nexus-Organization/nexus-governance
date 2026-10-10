# Dapplesoft Nexus — রিপোজিটরি অনলাইন ও মাস্টার নলেজ সেটআপ গাইড

**অফিসিয়াল সংস্থা পেজ:** [https://github.com/Dapplesoft-Nexus-Organization](https://github.com/Dapplesoft-Nexus-Organization)

---

## ১. eShop এবং SRV থেকে অর্জিত মাস্টার নলেজ ও রুলস (১০০% সমন্বিত)

Dapplesoft Nexus-এর প্রতিটি রিপোজিটরি এবং কেন্দ্রীয় নীতিতে eShop ও SRV প্ল্যাটফর্মের গুরুত্বপূর্ণ আর্কিটেকচারাল জ্ঞান ও বাধ্যতামূলক নির্দেশনাসমূহ যুক্ত করা হয়েছে:

### ক. সার্বজনীন AI গিট নীতি (Universal AI Git & Commit Policy - STRICT)
1. **AI কখনো কমিট করবে না (`git commit` FORBIDDEN):** সমস্ত ফাইল লোকাল ওয়ার্কস্পেসে আনকমিটেড থাকবে যাতে ডেভেলপার নিজে GitHub Desktop বা CLI দিয়ে পর্যবেক্ষণ করে কমিট করতে পারেন।
2. **AI কখনো পুশ করবে না (`git push` FORBIDDEN):** অনলাইন রিপোজিটরিতে কোনো কোড AI নিজে পুশ করবে না।
3. **ব্রাঞ্চিং স্ট্যান্ডার্ড:** ফিচার ব্রাঞ্চের ক্ষেত্রে অবশ্যই পূর্ণাঙ্গ `feature/<kebab-case>` প্রিফিক্স ব্যবহার করতে হবে (কখনোই `feat/` ব্যবহার করা যাবে না)। বেস ব্রাঞ্চ সব সময় `dev` হতে হবে।
4. **জিরো ব্রাউজার টেস্ট রুল:** কোনো অটোমেটেড ব্রাউজার সাব-এজেন্ট বা হেডলেস টেস্ট চালানো যাবে না। সমস্ত ভেরিফিকেশন কেবল কোড-লেভেলে (বিল্ড, লিন্টার, ইউনিট টেস্ট) সম্পন্ন হবে।

### খ. পোর্ট স্পেকট্রাম রিজার্ভেশন (SRV জিরো-কনফ্লিক্ট পলিসি)
eShop এবং Dapplesoft ইনফ্রাস্ট্রাকচারের সাথে পোর্ট সংঘর্ষ প্রতিরোধে Nexus-এর নির্দিষ্ট পোর্ট বরাদ্দ:
- **`3000`**: `nexus-web` (Next.js 15 Admin Console)
- **`5200` / `5201`**: `nexus-core` (Kestrel REST API ও Internal gRPC)
- **`8000`**: `nexus-ai-orchestrator` (FastAPI / LangGraph)
- **`7233` / `8233`**: Temporal Server & Web UI
- **`5432`**: PostgreSQL 16 + pgvector (অভ্যন্তরীণ নেটওয়ার্ক / লুপব্যাক)
- **`6379`**: Redis 7 (অভ্যন্তরীণ নেটওয়ার্ক / লুপব্যাক)
- **`4317` / `4318`**: OpenTelemetry Collector
- **`9090` / `3100` / `3001`**: Prometheus / Loki / Grafana
- *(eShop-এর `4200, 4201, 5000, 5001, 5022, 44358` পোর্টগুলোর সাথে সম্পূর্ণ সংঘর্ষহীন।)*

### গ. মাল্টি-টেন্যান্সি ও বিজনেস আইসোলেশন (eShop অভিজ্ঞতা)
- eShop-এর `BusinessId` নীতির অনুরূপ Nexus-এর প্রতিটি টাস্ক, এক্সিকিউশন, প্ল্যান ও পলিসিতে বাধ্যতামূলকভাবে `tenant_id` / `organization_id` যুক্ত থাকবে যাতে কোনো ক্রস-টেন্যান্ট ডেটা লিক না ঘটে।

### ঘ. জিরো হার্ড-ডিলিট ও কমপেনসেটিং রিভার্সাল (eShop নীতি)
- কোনো রেকর্ড বা টাস্ক হিস্ট্রি সরাসরি হার্ড-ডিলিট (`DELETE FROM`) করা যাবে না। সফট-ডিলিট (`is_deleted = true`) এবং ফেইলিউর হলে কমপেনসেটিং রিভার্সাল কার্যকর হবে।

### ঙ. ডেটাবেজ ও ক্যাশ আইসোলেশন (SRV ডকার পলিসি)
- PostgreSQL ও Redis কখনোই পাবলিক `0.0.0.0` আইপিতে বাইন্ড হবে না। শুধুমাত্র `127.0.0.1` লুপব্যাক এবং ডকার অভ্যন্তরীণ নেটওয়ার্কে সীমাবদ্ধ থাকবে।
- টু-টিয়ার ব্যাকআপ: লোকাল SSD-তে ৪৮ ঘণ্টা এবং অফসাইট iDrive E2 S3 বাকেটে ৩ দিনের রিটেনশন।

---

## ২. ৯টি রিপোজিটরির বর্তমান অবস্থা ও সেটআপ

বর্তমানে ৯টি রিপোজিটরির প্রতিটিতেই নিচের ফাইলগুলো সম্পূর্ণ প্রস্তুত এবং লোকাল গিট ইনিশিয়ালাইজ করা হয়েছে:
1. **`README.md`**: রিপোজিটরির উদ্দেশ্য, আর্কিটেকচার ও ডিরেক্টরি কাঠামো।
2. **`AGENTS.md`**: eShop ও SRV-এর সমন্বিত মাস্টার গাইডলাইন ও রুলস।
3. **`GEMINI.md`**: AI মডেলের জন্য সুনির্দিষ্ট নির্দেশনাবলী।
4. **`.gitignore`**: প্রযুক্তি অনুযায়ী (C#, Node, Python, Docker) সিক্রেট এবং বিল্ড ফাইল ফিল্টার।
5. **Git Initialized (`.git`):** প্রতিটি রিপোজিটরিতে `git init -b main` রান করা হয়েছে এবং রিমোট অরিজিন হিসেবে `https://github.com/Dapplesoft-Nexus-Organization/<repo>.git` যুক্ত করা হয়েছে।

---

## ৩. অনলাইনে ৯টি রিপোজিটরি তৈরি ও পাঠানোর উপায়

### 🟢 ধাপ ১: গিটহাবে ৯টি রিপোজিটরি তৈরি করা (GitHub CLI)
আপনার কম্পিউটারে GitHub CLI ইনস্টল রয়েছে।
1. ডাবল ক্লিক করে রান করুন: **[`create-gh-repos.bat`](file:///d:/GitHub/Dapplesoft-Nexus-Organization/create-gh-repos.bat)**
2. আপনি যদি লগইন না থাকেন, এটি নিজে থেকেই ব্রাউজার উইন্ডো ওপেন করে এক ক্লিকে অথেন্টিকেশন করিয়ে নেবে এবং সংগঠনের অধীনে ৯টি পাবলিক রিপোজিটরি তৈরি করে দেবে।

*(বিকল্পভাবে, আপনার ব্রাউজারে থাকা [সংস্থা পেজে](https://github.com/orgs/Dapplesoft-Nexus-Organization/repositories) গিয়ে সবুজ **New repository** বাটনে ক্লিক করেও এক এক করে রিপোজিটরি তৈরি করা যাবে।)*

---

### 🟣 ধাপ ২: কোড কমিট ও পুশ করা (Developer Action)

AI-এর গিট পলিসি অনুযায়ী কমিট ও পুশ মানুষের এখতিয়ারাধীন। আপনি নিচের যেকোনো একটি উপায়ে কমিট ও পুশ সম্পন্ন করতে পারেন:

#### উপায় ক: GitHub Desktop ব্যবহার করে (ভিজ্যুয়াল পদ্ধতি — সবচেয়ে সহজ)
যেহেতু আপনার টাস্কবারে GitHub Desktop চালু আছে:
1. **File** মেনু থেকে **Add local repository...** (অথবা `Ctrl + O`) ক্লিক করুন।
2. ফোল্ডার হিসেবে `D:\GitHub\Dapplesoft-Nexus-Organization\nexus-contracts` সিলেক্ট করুন।
3. পরিবর্তনগুলো দেখে নিচে Commit বক্সে লিখুন: `feat: initial nexus contracts setup` এবং **Commit to main** দিন।
4. উপরে ডানপাশে **Push origin** বাটনে ক্লিক করুন।
5. একইভাবে বাকি ৮টি ফোল্ডার যোগ করে পুশ করুন।

#### উপায় খ: এক ক্লিকে স্ক্রিপ্ট রান করে (দ্রুততম)
আপনার সুবিধার জন্য একটি প্রস্তুত স্ক্রিপ্ট তৈরি রাখা হয়েছে:
- ডাবল ক্লিক করে রান করুন: **[`user-commit-and-push-all.bat`](file:///d:/GitHub/Dapplesoft-Nexus-Organization/user-commit-and-push-all.bat)**
- এটি আপনার নিশ্চিতকরণ (`y`) নিয়ে এক ক্লিকে ৯টি রিপোজিটরির সমস্ত প্রস্তুত ফাইল কমিট করে গিটহাবে পুশ করে দেবে!

---

## ৪. সংক্ষেপিত তালিকা

| # | রিপোজিটরি | টেকনোলজি | রিমোট URL |
|---|---|---|---|
| ১ | **nexus-contracts** | Protobuf, OpenAPI, JSON Schema | `https://github.com/Dapplesoft-Nexus-Organization/nexus-contracts.git` |
| ২ | **nexus-core** | C# .NET 10, Temporal | `https://github.com/Dapplesoft-Nexus-Organization/nexus-core.git` |
| ৩ | **nexus-web** | Next.js 15, Tailwind, React Flow | `https://github.com/Dapplesoft-Nexus-Organization/nexus-web.git` |
| ৪ | **nexus-governance**| YAML, Markdown, JSON Schema | `https://github.com/Dapplesoft-Nexus-Organization/nexus-governance.git` |
| ৫ | **nexus-ai-orchestrator**| Python 3.12+, LangGraph | `https://github.com/Dapplesoft-Nexus-Organization/nexus-ai-orchestrator.git` |
| ৬ | **nexus-device-agent**| C# .NET 10 Worker, ConPTY | `https://github.com/Dapplesoft-Nexus-Organization/nexus-device-agent.git` |
| ৭ | **nexus-computer-use**| Docker, QEMU, Playwright | `https://github.com/Dapplesoft-Nexus-Organization/nexus-computer-use.git` |
| ৮ | **nexus-learning** | Python, PyTorch, pgvector | `https://github.com/Dapplesoft-Nexus-Organization/nexus-learning.git` |
| ৯ | **nexus-infra** | Docker Compose, Caddy | `https://github.com/Dapplesoft-Nexus-Organization/nexus-infra.git` |
