# Pocket Spend

> An offline-first expense tracker that also reads your bank and MoMo alerts and tells you where your money actually went.

**Platform:** Android first (Flutter), iOS later
**Status:** Core app built; bank-alert tracking feature in design
**Working name:** Pocket Spend. *SikaTrail* is being considered if the alert-tracking feature becomes the app's main identity.

---

## Table of Contents

1. [Overview](#1-overview)
2. [The Problem](#2-the-problem)
3. [Goals](#3-goals)
4. [Core Features (Existing)](#4-core-features-existing)
5. [Bank Alert Tracking (New Feature)](#5-bank-alert-tracking-new-feature)
6. [How Alert Processing Works](#6-how-alert-processing-works)
7. [Alert Format Reference](#7-alert-format-reference)
8. [Classification Rules](#8-classification-rules)
9. [Duplicate Detection and Balance Reconciliation](#9-duplicate-detection-and-balance-reconciliation)
10. [Linking Bank Transfers to MoMo](#10-linking-bank-transfers-to-momo)
11. [Learning From the User](#11-learning-from-the-user)
12. [User Experience](#12-user-experience)
13. [Technology Stack](#13-technology-stack)
14. [Architecture](#14-architecture)
15. [Data Models](#15-data-models)
16. [Data Storage](#16-data-storage)
17. [Android Integration](#17-android-integration)
18. [iOS Considerations](#18-ios-considerations)
19. [Privacy and Security](#19-privacy-and-security)
20. [Play Store Compliance](#20-play-store-compliance)
21. [Edge Cases](#21-edge-cases)
22. [Testing Strategy](#22-testing-strategy)
23. [Roadmap](#23-roadmap)
24. [Success Metrics](#24-success-metrics)
25. [Open Questions](#25-open-questions)

---

## 1. Overview

Pocket Spend is an offline-first personal expense tracker built with Flutter. Users record income and expenses, categorise them, and view daily and weekly summaries. All data stays on the device.

The new **Bank Alert Tracking** feature removes most of the manual entry. The app listens for debit alerts from the user's bank and mobile money provider and turns each one into a transaction. When an alert doesn't say enough, the app asks the user right away, while they still remember what the money was for.

---

## 2. The Problem

Bank debit alerts tell you that money left and how much, but rarely where it went or why.

A typical alert:

```
A/C No.: 140*******721 has been debited with GHS 30.00 on 21 JUL 2026 Tarkwa.
Info: CalPay MTN Pull Txn.. Avail. bal: GHS 10.43. Thank you.
```

A week later, nobody remembers what that GHS 30 was for. Three things make it worse:

- **Vague narrations.** "Transfer Charges" and "CalPay MTN Pull Txn" describe the mechanism, not the purpose.
- **Money hops between wallets.** A lot of bank "spending" is really money moving to MTN MoMo. The real spending (the shop, the airtime, the person paid) only shows up in the MoMo message.
- **Small fees add up unnoticed.** GHS 2 transfer charges are easy to ignore one at a time and significant over a month.

Manual expense trackers fail because people forget to log things. Bank alerts already capture the amount and date. What's missing is the context.

---

## 3. Goals

### Product goals
- Capture every bank and MoMo debit automatically, with no manual entry of amounts.
- Recover the context the alert lacks: category, merchant, purpose.
- Separate **spending**, **fees** and **transfers between your own wallets**, so totals are honest.
- Ask the user as little as possible, and less over time.

### Technical goals
- Keep the app fully usable offline, with no server dependency.
- Keep the alert feature opt-in, so the core app needs no sensitive permissions.
- Keep all financial data encrypted on the device.
- Use a clean, testable architecture that is easy to extend to new banks.

### Non-goals (for now)
- Connecting to bank APIs or open banking.
- Budgeting advice or financial recommendations.
- Multi-user or shared household accounts.
- Investment or loan tracking.

---

## 4. Core Features (Existing)

### 4.1 Income and expense tracking
- Add income or expense transactions.
- Enter amount, category, date and an optional note.
- Clear visual distinction between income and expenses.

### 4.2 Categories
- Predefined categories: Food, Transport, Data/Airtime, Utilities, Rent, Shopping, Health, Education, Entertainment, Bank Fees, Transfers, Other.
- Custom categories planned.

### 4.3 Daily and weekly summaries
- Total income and expenses for a selected day.
- Weekly summaries over date ranges.
- Calculated automatically from stored transactions.

### 4.4 Offline-first storage
- Local storage only.
- No account or login required.
- Instant reads and writes.

---

## 5. Bank Alert Tracking (New Feature)

### 5.1 What it does
1. Detects debit and credit alerts from supported banks and MoMo.
2. Extracts the amount, date, account, location, narration and balance.
3. Classifies the transaction automatically where it can.
4. Saves it as a transaction, either **confirmed** (the app knows what it was) or **pending** (the user needs to add details).
5. Prompts the user to fill in pending transactions with one-tap answers.
6. Learns from the user's answers so future alerts need less input.

### 5.2 What makes it different
- **It follows the money across wallets.** A bank-to-MoMo transfer is linked to the MoMo payment that follows, so the user sees where the money finally went.
- **It reconciles against the balance.** Every alert includes the balance after the transaction, so the app can detect missed alerts and duplicates.
- **It surfaces hidden costs.** Fees are separated out and totalled.

### 5.3 Opt-in
The feature is off by default. The user turns on "Auto-track bank alerts" in settings, sees an explanation of what the app reads and why, and then grants notification access in Android system settings. Users who never turn it on keep using Pocket Spend as a manual tracker.

---

## 6. How Alert Processing Works

```
Alert arrives on phone
        │
        ▼
Native listener (Android) checks: is this from a bank or MoMo sender?
        │  no → ignore
        ▼  yes
Store raw alert in a native queue + show "Add details?" notification
        │
        ▼
Flutter app opens / resumes → drains the queue
        │
        ▼
Filter: is it a debit/credit alert? (ignore OTPs, promos, balance enquiries)
        │
        ▼
Parse with the matching bank template
        │  no template matches → save to "Unrecognised alerts"
        ▼
Duplicate check (amount + date + balance)
        │  duplicate → discard
        ▼
Classify from narration (fee, transfer, merchant, unknown)
        │
        ▼
Apply learned rules
        │
        ▼
Save transaction as CONFIRMED or PENDING
        │
        ▼
Run balance reconciliation → flag gaps as "missing transaction"
        │
        ▼
Try to link with MoMo alerts (transfer matching)
        │
        ▼
UI updates: home badge, "Needs details" inbox, summaries
```

### Why the queue?
Alerts usually arrive while the app is closed, when Flutter isn't running. The native listener can't write to the Flutter database directly, so it saves the raw alert in a small native store. The Flutter side processes everything the next time the app opens or resumes. This also means no alert is lost if processing fails, because the raw message is kept and can be re-processed.

---

## 7. Multi-Bank & Mobile Money Alert Format Reference

Kudi Lens supports all major Ghanaian commercial banks and mobile network operators through a modular template engine. Each institution has distinct SMS/notification structures, sender IDs, and narration styles.

### 7.1 GCB Bank Ghana (Ghana Commercial Bank)
**Sample:**
```
Acc: 101*******402 debited with GHS 240.00 on 26 OCT 2026. Info: POS CHOP BAR OSU. Avail Bal: GHS 1,180.00.
```
- **Sender ID:** `GCB`, `GCBBank`
- **Fields:** Account masked (`101*******402`), Direction (`debited`), Amount (`240.00`), Date (`26 OCT 2026`), Info (`POS CHOP BAR OSU`), Avail Bal (`1,180.00`).

### 7.2 Ecobank Ghana
**Sample:**
```
ECOBANK: Dr GHS 95.00 from A/c 144*******319 at TOTAL AIRPORT on 26-OCT-2026. Avail Bal GHS 755.50.
```
- **Sender ID:** `Ecobank`, `EcobankGH`
- **Fields:** Indicator (`Dr` = Debit, `Cr` = Credit), Amount (`95.00`), Account (`144*******319`), Location/Merchant (`TOTAL AIRPORT`), Avail Bal (`755.50`).

### 7.3 CalBank Ghana
**Sample:**
```
A/C No.: 140*******721 has been debited with GHS 2.00 on 21 OCT 2026 @BNK. Info: Transfer Charges. Avail. bal: GHS 268.42. Thank you.
```
- **Sender ID:** `CalBank`
- **Fields:** Account (`140*******721`), Direction (`debited`), Amount (`2.00`), Date (`21 OCT 2026`), Channel (`@BNK` or city/terminal), Info (`Transfer Charges`), Balance (`268.42`).

### 7.4 Stanbic Bank Ghana
**Sample:**
```
Stanbic: Debit txn of GHS 150.00 on A/C **5012 on 26/10/2026 14:22. Desc: ACCRA MALL POS. Bal: GHS 3,410.00.
```
- **Sender ID:** `Stanbic`, `StanbicGH`

### 7.5 Absa Bank Ghana
**Sample:**
```
Absa: A debit of GHS 80.00 occurred on your account ending with 8812 on 26-OCT-2026. Ref: Kfc Junction. Available balance: GHS 1,940.00.
```
- **Sender ID:** `Absa`, `AbsaGhana`

### 7.6 Fidelity Bank Ghana
**Sample:**
```
Fidelity Alert: Acct 209****101 has been debited for GHS 65.00 on 26-OCT-2026. Narration: PHARMACY EAST LEGON. Available Bal: GHS 520.00.
```
- **Sender ID:** `Fidelity`, `FidelityBk`

### 7.7 MTN Mobile Money (MoMo)
**Sample:**
```
Payment made for GHS 35.00 to 0551234567. Current Balance: GHS 415.00. Reference: Lunch. Fee was GHS 0.00.
Cash Out of GHS 100.00 received from Agent 249012. Fee: GHS 1.00. Balance: GHS 314.00.
```
- **Sender ID:** `MobileMoney`, `MTN MoMo`

### 7.8 Telecel Cash & AT Money
- **Telecel Cash Sample:** `You have paid GHS 50.00 to Telecel Merchant 338102. Fee: GHS 0.00. Balance: GHS 280.00.`
- **AT Money Sample:** `Transfer of GHS 40.00 to 0261234567 successful. New balance: GHS 190.00.`

### 7.9 Modular Multi-Bank Engine Architecture
Each provider registers a parser specification declaring:
1. Sender IDs matched (e.g., `GCB`, `Ecobank`, `CalBank`, `Stanbic`, `Absa`, `Fidelity`, `MobileMoney`, `Telecel`).
2. Regex templates for Debit, Credit, and Balance Enquiries.
3. Narration phrase dictionary to extract merchant tags, channels, fees, and inter-wallet transfers.
4. Auto-fallback to "Unrecognised Financial Alerts" for unknown templates so new banks can be trained with zero app store updates.

---

## 8. Classification Rules

The narration decides what kind of transaction it is.

| Narration contains | Type | Category | Counts as spending? | Ask the user? |
|---|---|---|---|---|
| Transfer Charges, Charge, Fee, SMS Alert Fee, Levy | Fee | Bank Fees | Yes | No |
| MTN Pull, MoMo, Wallet | Transfer | Transfer to MoMo | No | Only if no matching MoMo credit is found |
| POS, Purchase + merchant name | Expense | From learned rules, else pending | Yes | If no rule exists |
| ATM, Cash Withdrawal | Cash | Cash | Yes, as "Cash (unspecified)" | Optional |
| Anything else | Expense | Pending | Yes | Yes |

### Transaction types
- **Expense:** money spent on goods or services.
- **Income:** money received from outside (salary, payment from a client).
- **Fee:** bank or network charges.
- **Transfer:** money moved between the user's own accounts. Excluded from spending and income totals, so the same money isn't counted twice.
- **Cash:** money withdrawn. Optionally broken down later.

### Linking fees to transfers
A fee alert that arrives within a few minutes of a transfer from the same account is linked to it. The user then sees one item: "GHS 30 to MoMo + GHS 2 fee."

---

## 9. Duplicate Detection and Balance Reconciliation

### 9.1 Duplicates
The same alert can appear twice: from the SMS app and the bank's own app, or because the bank resent it.

The rule:
- **Same account, amount, date and balance after** → duplicate. Keep one.
- **Same account, amount and date, but a different balance** → two real transactions. Keep both.

Comparing the balance is what makes this reliable. Two genuine GHS 2 charges on the same day leave two different balances; one alert seen twice shows the same balance both times.

### 9.2 Balance reconciliation
For each account, the app keeps the last known balance. When a new alert arrives:

```
expected balance = last known balance − debit (or + credit)
```

If the alert's actual balance doesn't match, a transaction was missed (no alert, or an alert the parser didn't recognise). The app creates a **pending "Unaccounted"** entry for the difference:

> "About GHS 29.58 left your CalBank account without an alert. What was it?"

Reconciliation runs in date order, so alerts that arrive late are handled correctly.

### 9.3 Account balance display
Each account shows its last balance as reported by the bank. Because this figure comes from the bank, users can trust it and check it against their own records.

---

## 10. Linking Bank Transfers to MoMo

This is how the app answers "where did my money go?"

### The flow
1. Bank alert: **GHS 30 debited, "CalPay MTN Pull Txn"** → recorded as a *Transfer out*.
2. MoMo alert within a few minutes: **GHS 30 received from CalBank** → matched and recorded as a *Transfer in*.
3. The two are linked and shown as one movement: **CalBank → MoMo, GHS 30**.
4. Later MoMo debits (e.g. "Payment to Melcom GHS 28") are recorded as actual spending.

### Matching rules
- Same amount (allowing for a known fee difference).
- Within a short time window.
- Directions are opposite (debit on one side, credit on the other).
- When several candidates match, the closest in time wins. If it's still ambiguous, the user confirms.

### Result in summaries
- The bank-to-MoMo transfer does **not** count as spending.
- The MoMo payment to the merchant **does**.
- Total spending is accurate, with no double counting.

---

## 11. Learning From the User

### 11.1 Rules
Every time the user categorises a pending transaction, the app saves a rule:

| Rule type | Example | When used |
|---|---|---|
| Narration rule | "SHOPRITE" → Groceries | Alert narration contains the text |
| Recipient rule (MoMo) | "Kofi Mensah" → Rent | MoMo recipient matches |
| Pattern rule | ~GHS 50, weekday mornings → Fuel | No merchant; amount and time pattern match |

### 11.2 Confidence
- **First match:** the category is pre-selected, but the user still confirms.
- **After about 3 consistent confirmations:** the app auto-confirms and only notifies the user.
- **If the user changes an auto-confirmed transaction:** the rule's confidence drops and the app goes back to asking.

### 11.3 Managing rules
Users can view, edit and delete learned rules in settings, so the app never gets stuck on a wrong guess.

---

## 12. User Experience

### 12.1 Capture at the moment
When a debit arrives, the user gets a notification such as:

> **GHS 145 left your CalBank account**
> What was it? [Food] [Transport] [Shopping] [More…]

One tap and it's categorised, without opening the app. The aim is to capture context within minutes, while the user still remembers.

### 12.2 Home screen
- Today's and this week's spending, as before.
- A **"Needs details" badge** showing how many pending transactions there are.
- Account cards with the latest bank-reported balance.

### 12.3 "Needs details" inbox
- A list of pending transactions, newest first.
- Each shows the amount, date, account and the original narration.
- Tapping one opens the existing add-transaction form, pre-filled. The user only picks a category and optionally adds a merchant or note.
- Swipe actions: categorise quickly, mark as transfer, or dismiss as a duplicate.

### 12.4 Summaries
Summaries are split into:
- **Spending** by category.
- **Fees:** e.g. "Bank fees this month: GHS 14".
- **Transfers:** shown separately, not counted in spending.
- A note such as "includes 3 transactions without details", so totals are accurate even before everything is tagged.

### 12.5 Transaction detail
- The parsed fields.
- The original alert text, so the user can see exactly what the bank sent.
- Linked items (its fee, the matching MoMo credit).
- Source label: *Manual* or *From bank alert*.

### 12.6 Settings
- Turn auto-tracking on or off.
- Choose which banks and wallets to track.
- Manage learned rules.
- View unrecognised alerts.
- Export data, delete all data.

---

## 13. Technology Stack

| Area | Choice | Reason |
|---|---|---|
| Framework | Flutter (Dart) | Existing app |
| State management | Riverpod | Existing app; reactive updates when alerts are processed |
| Local database | Hive CE (community fork of Hive) | Drop-in replacement; the original Hive is barely maintained |
| Encryption | Hive AES encryption + `flutter_secure_storage` for the key | Raw bank messages must be protected |
| Charts | fl_chart | Summaries |
| Alert listening | Native Android `NotificationListenerService` (Kotlin) | Reads alert notifications without the restricted SMS permission |
| Flutter ↔ native | Platform channel | Draining the alert queue, checking permission status |
| Local notifications | flutter_local_notifications | "Add details" prompts with quick actions |
| Receipt OCR (later) | Google ML Kit text recognition | On-device, no data upload |

---

## 14. Architecture

Pocket Spend uses a feature-based structure with MVVM-style layers: **Models → Repositories → ViewModels (Riverpod notifiers) → Views**.

### 14.1 Folder structure

```
lib/
├── core/
│   ├── database/          # Hive setup, encryption, box management
│   ├── models/            # Shared data models
│   └── utils/             # Dates, currency formatting
│
├── features/
│   ├── transactions/      # Add / view / edit transactions (existing)
│   ├── summary/           # Daily & weekly summaries (existing)
│   ├── accounts/          # Bank & MoMo accounts, balances
│   ├── bank_alerts/
│   │   ├── data/          # Native channel, parsers, bank templates
│   │   ├── domain/        # Classification, dedup, reconciliation, linking
│   │   ├── viewmodel/     # Pending alerts state
│   │   └── views/         # "Needs details" inbox, unrecognised alerts
│   ├── rules/             # Learned categorisation rules
│   └── settings/          # Permissions, preferences, data management
│
└── main.dart

android/app/src/main/kotlin/…/
├── AlertListenerService   # Watches notifications from bank/MoMo apps
└── AlertQueue             # Native store for alerts received while app is closed
```

### 14.2 Responsibilities

| Component | Responsibility |
|---|---|
| Alert listener (native) | Watch notifications, filter by sender, queue raw alerts, show prompt |
| Alert channel | Move queued alerts from native to Flutter |
| Parser | Turn raw text into structured fields using bank templates |
| Classifier | Decide fee / transfer / expense / income from the narration |
| Deduplicator | Drop repeated alerts using the balance check |
| Reconciler | Compare balances, create "unaccounted" entries |
| Linker | Match bank transfers with MoMo credits, fees with transfers |
| Rule engine | Apply and update learned rules |
| Transaction repository | Save and query transactions (shared with the manual flow) |

The domain logic (parsing, classification, dedup, reconciliation, linking) is plain Dart with no Flutter or platform dependencies, so it can be unit-tested with real alert samples.

---

## 15. Data Models

### 15.1 Transaction (extended)

| Field | Type | Description |
|---|---|---|
| id | String | Unique ID |
| amount | Number | Transaction amount |
| currency | String | e.g. GHS |
| type | Enum | expense, income, fee, transfer, cash |
| category | String? | Category name; empty while pending |
| note | String? | User note |
| date | DateTime | Date from the alert + arrival time |
| isIncome | Bool | Kept for compatibility with existing data |
| source | Enum | manual, bankAlert, reconciliation |
| status | Enum | confirmed, pending |
| accountId | String? | Which account |
| merchant | String? | Merchant or recipient |
| narration | String? | The alert's "Info" text |
| location | String? | e.g. Tarkwa, @BNK |
| balanceAfter | Number? | Balance reported by the bank |
| rawMessage | String? | Original alert text |
| messageHash | String? | For duplicate detection |
| linkedTransactionId | String? | Matching transfer leg or fee |
| ruleId | String? | Rule that categorised it, if any |

New fields are optional with sensible defaults, so existing Pocket Spend data loads without migration. Old records read as *manual* and *confirmed*.

### 15.2 Account

| Field | Description |
|---|---|
| id | Unique ID |
| name | e.g. "CalBank Current" |
| provider | calbank, mtn_momo, … |
| maskedNumber | Visible digits only, e.g. 140…721 |
| lastBalance | Last bank-reported balance |
| lastBalanceDate | When that balance was reported |

### 15.3 Rule

| Field | Description |
|---|---|
| id | Unique ID |
| matchType | narration, recipient, pattern |
| matchValue | Text or pattern to match |
| category | Category to apply |
| type | Transaction type to apply |
| confirmations | How many times the user agreed |
| autoConfirm | Whether to skip asking |

### 15.4 Unrecognised alert

| Field | Description |
|---|---|
| id | Unique ID |
| sender | Who sent it |
| rawMessage | Full text |
| receivedAt | Arrival time |

---

## 16. Data Storage

| Box | Contents | Encrypted |
|---|---|---|
| transactions | All transactions | Yes |
| accounts | Accounts and balances | Yes |
| rules | Learned rules | Yes |
| unrecognised_alerts | Alerts the parser couldn't read | Yes |
| settings | Preferences, feature toggle | No |

- Boxes are opened once at startup.
- The encryption key is generated on first launch and stored in Android Keystore via `flutter_secure_storage`.
- Raw messages can be cleared after a set period (e.g. 90 days) once parsed, keeping only the structured fields.

---

## 17. Android Integration

### 17.1 Why notifications, not SMS
Reading SMS directly needs the `READ_SMS` permission, which Google Play restricts. Only apps approved for specific uses can request it, and approval is not guaranteed. A **Notification Listener** reads the notification that the SMS app or banking app displays. It is a user-granted special permission and is usually much easier to justify in a Play review.

### 17.2 How the listener works
- Runs as an Android system service once the user grants notification access.
- Receives every posted notification and checks the sending app and sender name.
- Ignores everything except known bank and MoMo senders.
- Saves matching alerts to the native queue and posts the "Add details" prompt.
- Never sends anything off the device.

### 17.3 Reliability
- Some phone makers (Tecno, Infinix, Xiaomi, Samsung) aggressively stop background services. The setup flow should guide users to exempt Pocket Spend from battery optimisation.
- On app start, the app checks that notification access is still granted and prompts the user if it was revoked.
- A manual fallback lets the user share or paste an alert into the app, which runs it through the same parser.

---

## 18. iOS Considerations

iOS does not let apps read SMS or other apps' notifications. Options:
- **Shortcuts automation:** the user sets up an automation that forwards messages from their bank to Pocket Spend.
- **Share/paste:** the user copies an alert and pastes it in; the same parser handles it.
- **Manual entry:** as the app does today.

Android is the priority. On iOS, the core tracker works fully and alert parsing is semi-manual.

---

## 19. Privacy and Security

- **Everything stays on the device.** No server, no account, no analytics on financial data.
- **Encrypted at rest.** All financial data is stored in encrypted boxes.
- **Minimum data read.** Only notifications from selected bank and MoMo senders are processed; everything else is ignored immediately.
- **Masked numbers only.** The app stores only the visible digits of account numbers.
- **User control.** Users can turn the feature off, delete raw messages, export their data or wipe everything.
- **Optional backup later.** Any cloud backup will be opt-in and encrypted before it leaves the device.

The positioning: *"Your financial data never leaves your phone."*

---

## 20. Play Store Compliance

- **Prominent disclosure:** before sending users to notification access settings, show an in-app screen explaining what is read, why, and that it stays on the device.
- **Data Safety form:** declare that financial information is processed on-device and not collected or shared.
- **Privacy policy:** required; describe the notification listener clearly.
- **No restricted SMS permissions** in the first release.
- **Category:** Finance.

---

## 21. Edge Cases

| Case | Handling |
|---|---|
| Same alert received twice | Deduplicated by amount + date + balance |
| Two genuine identical charges | Kept, because the balances differ |
| Alert missed entirely | Detected by balance gap; "Unaccounted" pending entry |
| Alerts arrive out of order | Reconciliation sorts by date and balance |
| Bank changes message format | Falls into "Unrecognised alerts"; template updated |
| Reversal or refund | Recognised as a credit; linked to the original debit where possible |
| Failed transaction alert | Ignored if the balance is unchanged |
| Multiple accounts at the same bank | Separated by masked account number |
| Alert with no balance | Saved, but skipped for reconciliation |
| User edits an auto-confirmed transaction | Saved; rule confidence reduced |
| App uninstalled and reinstalled | Data lost unless exported; backup in a later version |
| Notification access revoked | Detected at app start; user prompted |

---

## 22. Testing Strategy

- **Parser tests:** a library of real, masked alerts per bank, each with its expected parsed result. Every new format variant becomes a test case.
- **Classifier tests:** each known narration phrase maps to the right type and category.
- **Dedup and reconciliation tests:** sequences of alerts including duplicates, gaps and out-of-order arrivals.
- **Linking tests:** bank transfers with and without matching MoMo credits, and ambiguous matches.
- **Migration test:** old Pocket Spend data loads correctly with the new model.
- **Device testing:** the notification listener on common Ghanaian phones (Tecno, Infinix, Samsung) with battery optimisation on and off.

---

## 23. Roadmap

### Phase 1: Foundation
- Switch to Hive CE with encryption.
- Extend the Transaction model; add Account model with Ghanaian multi-bank support.
- Add transaction types (expense, income, fee, transfer, cash).

### Phase 2: Universal Multi-Bank & Mobile Money Engine
- Native notification listener service and local SQLite/Hive queue.
- Modular Ghanaian bank parsers: GCB, Ecobank, CalBank, Stanbic, Absa, Fidelity, Zenith, Access, Stanchart.
- Mobile Money parsers: MTN MoMo, Telecel Cash, AT Money.
- Duplicate detection across SMS & in-app push notifications.
- Automatic fee detection and inter-account transfer classification.
- "Needs details" inbox and 1-tap quick categorization actions.

### Phase 3: Mobile Money & Cross-Bank Reconciliation
- Deep MoMo parser (merchant payments, transfers, airtime, cash-outs, QR payments).
- Bank-to-MoMo and MoMo-to-Bank transfer auto-pairing.
- Balance reconciliation and automated "unaccounted" entry detection.
- Categorized summaries split into spending, fees, and internal transfers.

### Phase 4: Intelligence & Auto-Categorization
- On-device learned rule engine with confidence scoring and auto-confirm thresholds.
- Smart fee-to-transfer linking and tax/levy identification.
- Community and local pattern repository for Ghanaian merchant recognition.

### Phase 5: Power User & Analytics
- Receipt capture with on-device OCR (ML Kit).
- Multi-bank statement import (PDF/CSV) to backfill history and reconcile past months.
- Monthly budgets, category caps, and velocity alerts.
- Encrypted export (CSV/JSON/PDF) and local backup.
- iOS Shortcuts integration.

---

## 24. Success Metrics

| Metric | Target |
|---|---|
| Alerts parsed successfully | > 95% across all supported Ghanaian banks and wallets |
| Pending transactions tagged within 24 hours | > 70% |
| Transactions auto-categorised after 4 weeks of use | > 60% |
| Duplicate transactions in data | ~0 |
| Reported balance matches bank balance | 100% of accounts with complete alerts |
| Users keeping auto-tracking on after 30 days | > 60% of those who enable it |

---

## 25. Open Questions & Expansion

1. **Format Variations:** Collecting real masked samples for all Ghanaian bank credit/debit alerts and MoMo variations (merchant payment, cash-out, airtime, bank pull/push).
2. **Notification Channels:** Handling dual notifications when both bank SMS and bank mobile banking app notifications fire simultaneously.
3. **Credit Alerts:** Normalizing incoming payment narrations across banks for income classification and transfer matching.
4. **Offline Resilience:** Handling notification queue bursts when a phone comes back online after being disconnected.
5. **Cash Tracking:** User options for breaking down ATM cash withdrawals vs leaving as a lumped cash wallet balance.