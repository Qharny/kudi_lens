# Kudi Lens (Pocket Spend)

> An offline-first, privacy-focused expense tracker built with Flutter that reads bank and Mobile Money (MoMo) alerts to tell you where your money actually went.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20(Planned)-3DDC84?logo=android)](https://android.com)
[![Storage](https://img.shields.io/badge/Storage-Hive%20CE%20(Encrypted)-FFA000)](https://github.com/isar/hive_ce)
[![State Management](https://img.shields.io/badge/State-Riverpod-0D47A1)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-Private-lightgrey.svg)]()

---

## 📌 Overview

**Kudi Lens** (working name *Pocket Spend*, also exploring *SikaTrail*) is a personal expense tracker designed for African and emerging mobile money ecosystems (starting with Ghana 🇬🇭). 

Traditional expense trackers fail because manual logging is tedious and easily forgotten. While banks and MoMo services send debit alerts, their notifications are often cryptic (e.g. `"CalPay MTN Pull Txn"`, `"Transfer Charges"`), leaving users clueless weeks later about where their money went.

Kudi Lens bridges this gap by automatically listening for financial alerts, stripping away the noise, identifying fees and multi-hop transfers, and prompting the user in real time for context while the transaction is still fresh in mind—**all with 100% on-device privacy**.

---

## 💡 The Problem Solved

1. **Vague Narrations:** Bank debit alerts often record technical channel mechanics instead of actual merchants or purposes.
2. **Multi-Hop Wallet Transfers:** Much of bank "spending" is simply money moving to MTN MoMo before paying a vendor. Kudi Lens links these transfers so you see the real merchant transaction instead of double-counting.
3. **Hidden Fees:** SMS alert fees, transfer charges, and network levies slip by unnoticed. Kudi Lens separates and surfaces fees automatically.
4. **Data Privacy Concerns:** Users should never have to hand over bank credentials or upload financial history to a remote server. Kudi Lens operates strictly offline.

---

## ✨ Key Features

### 1. Core Expense Tracking (Offline-First)
- **Manual Logging:** Quick entry of income and expenses with amount, category, date, and notes.
- **Categorization:** Built-in categories (Food, Transport, Utilities, Rent, Shopping, Health, Education, Bank Fees, Transfers, etc.) and custom categories.
- **Visual Analytics:** Daily breakdowns, weekly summaries, and spending trends with interactive charts.
- **Zero Cloud Footprint:** No mandatory accounts, login credentials, or cloud tracking.

### 2. Automated Bank Alert Tracking (Opt-in)
- **On-Device Notification Listener:** Employs Android's `NotificationListenerService` to capture alerts locally without requiring risky `READ_SMS` permissions.
- **Intelligent Template Parsers:** Parses amounts, masked account numbers, dates, locations/terminals, transaction narrations, and post-transaction balances (initial support for CalBank & MTN MoMo).
- **Multi-Hop Transfer Matching:** Links a bank debit (e.g., bank-to-MoMo pull) with the corresponding MoMo credit, recording it as an internal transfer rather than spending.
- **Fee Segregation:** Identifies fees (e.g. transfer levies, SMS charges) and tallies them separately so spending totals remain honest.
- **Duplicate Detection & Balance Reconciliation:** Uses post-transaction balances to differentiate identical repeat charges from true duplicates and detects missed alerts.
- **On-the-Fly Micro-Prompts:** Sends an interactive local notification prompting the user for one-tap categorization right after a debit arrives.
- **Self-Learning Categorization Engine:** Learns from user answers over time (matching narrations, MoMo recipients, or patterns) to auto-categorize recurring payments.

---

## 🔄 How Alert Processing Works

```
Alert arrives on device
        │
        ▼
Android Native NotificationListenerService (filters for bank / MoMo senders)
        │
        ▼
Persist raw alert to Native Queue + Display quick-tag notification
        │
        ▼
Flutter App opens or resumes (drains native queue)
        │
        ▼
Filter non-transactional messages (ignores OTPs, promos, balance inquiries)
        │
        ▼
Parse alert text with Bank / Provider Template
        │
        ├── No match? ──► Store in "Unrecognised Alerts" for template creation
        ▼
Duplicate Check (Account + Amount + Date + Balance After)
        │
        ├── Duplicate? ──► Discard
        ▼
Narration Classifier (Fee, Transfer, POS Merchant, Cash Withdrawal, Expense)
        │
        ▼
Apply User-Learned Rules (Auto-confirm if confidence threshold is met)
        │
        ▼
Balance Reconciliation (Flags unexplained balance discrepancies as "Unaccounted")
        │
        ▼
Transfer & Fee Linker (Matches bank transfers with MoMo credits and fees)
        │
        ▼
Update UI: "Needs Details" Inbox, Balances, and Spending Summaries
```

---

## 🏗️ Architecture & Project Structure

The project follows a clean, feature-driven MVVM architecture: **Models → Repositories → ViewModels (Riverpod Notifiers) → Views**. The core domain logic (parsing, deduplication, reconciliation, rules) is pure Dart with zero platform dependencies for maximum testability.

```
lib/
├── core/
│   ├── database/          # Hive CE setup, AES encryption, box management
│   ├── models/            # Core shared data models
│   └── utils/             # Formatters (currency, dates), constants
│
├── features/
│   ├── transactions/      # Manual transaction entry, listing, and editing
│   ├── summary/           # Daily & weekly charts and summary widgets
│   ├── accounts/          # Account models, balances, and institutions
│   ├── bank_alerts/
│   │   ├── data/          # Method channels, bank parsers, template definitions
│   │   ├── domain/        # Parsers, classifier, dedup, reconciliation, transfer linking
│   │   ├── viewmodel/     # State management for pending & incoming alerts
│   │   └── views/         # "Needs Details" inbox, raw alert viewer
│   ├── rules/             # Rule management & auto-categorization engine
│   └── settings/          # Permissions, preferences, data export & wipe
│
└── main.dart

android/app/src/main/kotlin/.../
├── AlertListenerService   # Background notification listener service
└── AlertQueue             # Native persistent store for background alerts
```

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Framework** | [Flutter](https://flutter.dev) (Dart ^3.13) | Cross-platform core framework |
| **State Management** | [Riverpod](https://riverpod.dev) | Reactive state management & dependency injection |
| **Local Database** | [Hive CE](https://github.com/isar/hive_ce) | Fast, lightweight, embedded NoSQL database |
| **Encryption** | Hive AES-256 + [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) | Hardware-backed keystore encryption for financial data |
| **Visualizations** | [fl_chart](https://pub.dev/packages/fl_chart) | Interactive expense and income charts |
| **Alert Detection** | Native Android `NotificationListenerService` (Kotlin) | Battery-efficient alert monitoring without SMS permissions |
| **Inter-process Comm** | Platform Channels (Method/Event Channels) | Draining queued native alerts into Flutter |
| **Notifications** | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) | Instant quick-action categorization prompts |
| **Receipt OCR (Future)**| Google ML Kit Text Recognition | 100% on-device receipt scanning |

---

## 🔒 Privacy & Security First

- **Zero Cloud Transmission:** Financial data never leaves the user's phone. There are no servers, no telemetry on finances, and no remote databases.
- **Encrypted at Rest:** All sensitive Hive boxes (`transactions`, `accounts`, `rules`, `unrecognised_alerts`) are encrypted using AES keys securely stored in the Android Keystore.
- **Strict Data Minimization:** Non-financial notifications are ignored immediately. Account numbers are masked and only visible digits are preserved.
- **Play Store Compliant:** Uses Android Notification Listener access rather than restricted SMS permissions (`READ_SMS`), accompanied by prominent in-app disclosure.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.13.5` or later)
- Android Studio / Android SDK (API level 26+ recommended)
- A physical Android device (recommended for testing notification listening)

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Qharny/kudi_lens.git
   cd kudi_lens
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation (if using Hive/Riverpod generators):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Launch the application:**
   ```bash
   flutter run
   ```

5. **Enable Bank Alert Tracking (Optional):**
   - In the app, navigate to **Settings** → **Auto-track bank alerts**.
   - Review the privacy disclosure and grant **Notification Access** in Android Settings.
   - For OEMs with aggressive background restrictions (e.g. Transsion/Tecno, Samsung, Xiaomi), exempt the app from battery optimization.

---

## 🧪 Testing

Run unit and widget tests:
```bash
flutter test
```

Domain logic testing includes:
- **Parser Tests:** Masked real-world bank alert fixtures tested against extraction rules.
- **Deduplication & Reconciliation:** Validating out-of-order, missed, and repeated alert scenarios.
- **Transfer & Fee Linker:** Verifying matching bank debit and MoMo credit transactions.

---

## 🗺️ Roadmap

- [x] **Phase 1: Foundation** — Core manual expense tracker, Hive local storage, categorisation, and daily/weekly summaries.
- [ ] **Phase 2: CalBank Alerts** — Native Android notification listener & queue, CalBank parser, "Needs details" inbox, and quick-tag local notifications.
- [ ] **Phase 3: MoMo Integration** — MTN MoMo parser, automated bank-to-MoMo transfer linking, and segregated fee summaries.
- [ ] **Phase 4: Smart Learning & Reconciliation** — Confidence-weighted learning rules, auto-confirmation, and balance reconciliation for unaccounted transactions.
- [ ] **Phase 5: Multi-Institution & Expansion** — Support for additional Ghanaian banks (GCB, Ecobank, Fidelity, Stanbic, Absa), Telecel Cash, on-device receipt OCR, and CSV/PDF export.

---

## 📄 Documentation

For the comprehensive design document, parsing specifications, edge-case analysis, and data models, see [doc.md](file:///c:/Users/canny/Desktop/flutter/kudi_lens/doc.md).
