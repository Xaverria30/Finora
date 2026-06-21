<div align="center">

# 💙 Finora

### *Manage • Track • Save • Grow*

**The smart personal finance app that turns spending chaos into financial confidence.**

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white">
  <img src="https://img.shields.io/badge/MVVM-Architecture-success?style=for-the-badge">
  <img src="https://img.shields.io/badge/SQLite-Database-blue?style=for-the-badge">
  <img src="https://img.shields.io/badge/Platform-Android-success?style=for-the-badge">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square">
  <img src="https://img.shields.io/badge/status-active-brightgreen?style=flat-square">
  <img src="https://img.shields.io/badge/PRs-welcome-orange?style=flat-square">
</p>

<br>

**[📥 Install](#-installation) · [✨ Features](#-key-features) · [📱 Screenshots](#-application-screenshots) · [🏗️ Architecture](#️-system-architecture) · [🛣️ Roadmap](#-future-enhancements)**

</div>

---

## 💭 Why Finora?

Most people don't lose money because they earn too little — they lose track of where it goes. Finora closes that gap. No spreadsheets, no guesswork, no end-of-month panic — just a clear, beautiful picture of your money, updated in real time, right in your pocket.

> *"You can't grow what you can't see. Finora makes your finances visible — and your goals achievable."*

---

## ✨ Key Features

<table>
<tr>
<td width="50%" valign="top">

### 🔐 Authentication System
Secure registration, login, and account management — your financial data, protected from the first tap.

### 📊 Financial Dashboard
A real-time snapshot of your balance, income, and expenses — visualized so you understand it at a glance, not after a headache.

### 💸 Transaction Management
Log income and expenses in seconds. Edit, delete, and categorize transactions to keep your history clean and meaningful.

</td>
<td width="50%" valign="top">

### 🎯 Savings Goals
Set a target, watch your progress bar fill, and stay motivated to actually hit it — not just hope for it.

### 👤 User Profile
View and update your personal information and settings, all in one simple, organized space.

### 🔔 Smart Notifications
Gentle reminders and timely updates that keep you engaged with your money — without the noise.

</td>
</tr>
</table>

---

## 📱 Application Screenshots

<div align="center">

|                      Dashboard                     |                    Transactions                    |                     Profile                     |
| :------------------------------------------------: | :------------------------------------------------: | :---------------------------------------------: |
| <img src="Screenshots/dashboard.jpeg" width="220"> | <img src="Screenshots/transaksi.jpeg" width="220"> | <img src="Screenshots/profil.jpeg" width="220"> |
|                 💰 Your money, at a glance         |               🧾 Every transaction, tracked        |              👤 Your profile, your control      |

</div>

---

## 🏗️ System Architecture

Finora is engineered, not just coded. It follows the **MVVM (Model-View-ViewModel)** pattern combined with the **Repository Pattern**, keeping the codebase clean, testable, and built to scale as new features come online.

```text
┌──────────────────────┐
│   Presentation UI     │   ← What users see & touch
└──────────┬────────────┘
           │
┌──────────▼────────────┐
│      ViewModel         │   ← UI logic & state
└──────────┬────────────┘
           │
┌──────────▼────────────┐
│      Repository        │   ← Single source of truth
└──────────┬────────────┘
           │
┌──────────▼────────────┐
│   Database / API       │   ← Where the data lives
└────────────────────────┘
```

---

## ⚙️ Technology Stack

| Technology | Role |
|---|---|
| 🐦 **Flutter** | Cross-platform mobile framework |
| 🎯 **Dart** | Programming language |
| 🗄️ **SQLite** | Local database |
| 🧩 **MVVM** | Application architecture |
| 📦 **Repository Pattern** | Data management layer |
| 🌐 **REST API** | Backend communication |

---

## 📂 Project Structure

```text
Finora/
│
├── Backend/              # Backend services
├── Frontend/              # Flutter application source code
├── DetailsPage/           # Additional application pages
├── Screenshots/           # Application screenshots
│
└── README.md
```

---

## 🚀 Installation

Get Finora running locally in under a minute.

```bash
# 1. Clone the repository
git clone https://github.com/username/finora.git

# 2. Move into the project folder
cd finora/Frontend

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

That's it — you're ready to start taking control of your finances. 🎉

---

## 🛣️ Future Enhancements

Finora is just getting started. Here's what's on the horizon:

- 📈 **Financial analytics dashboard** — deeper insight into spending trends
- ☁️ **Cloud synchronization** — your data, available everywhere
- 🌙 **Dark mode** — easy on the eyes, day or night
- 📄 **Export financial reports** — share or archive your data effortlessly
- 🤖 **Smart financial insights** — AI-driven tips tailored to your habits
- 🔔 **Advanced notifications** — smarter, more contextual reminders

---

## 🎯 Project Objectives

- Improve financial awareness, one transaction at a time
- Help users track income and expenses without friction
- Encourage healthy, lasting saving habits
- Provide simple, powerful financial management tools
- Deliver an intuitive, delightful user experience

---

## 👨‍💻 Development Team

Built as a mobile application project focused on personal financial management, combining modern software architecture with Flutter's cross-platform power.

---

<div align="center">

## 💙 Finora

### Your Smart Financial Companion

*Track your money, achieve your goals, and build better financial habits — starting today.*

⭐ **If Finora helped you, consider starring the repo!** ⭐

</div>
