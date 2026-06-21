<div align="center">

# 💙 Finora

### Manage • Track • Save • Grow

**The smart personal finance app that turns spending chaos into financial confidence.**

<p>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white">
  <img src="https://img.shields.io/badge/MVVM-Architecture-success?style=for-the-badge">
  <img src="https://img.shields.io/badge/SQLite-Database-blue?style=for-the-badge">
  <img src="https://img.shields.io/badge/Platform-Android-success?style=for-the-badge">
</p>

<p>
  <img src="https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square">
  <img src="https://img.shields.io/badge/status-active-brightgreen?style=flat-square">
  <img src="https://img.shields.io/badge/PRs-welcome-orange?style=flat-square">
</p>

[📥 Installation](#-installation) •
[✨ Features](#-key-features) •
[📱 Screenshots](#-application-screenshots) •
[🏗 Architecture](#-system-architecture) •
[🛣 Roadmap](#-future-enhancements)

</div>

---

# 💭 Why Finora?

Most people don't lose money because they earn too little — they lose track of where it goes.

Finora provides a clear, real-time overview of your finances, helping users monitor spending habits, manage income, and achieve financial goals directly from their smartphones.

> *"You can't grow what you can't see. Finora makes your finances visible and your goals achievable."*

---

# ✨ Key Features

| Feature                   | Description                                          |
| ------------------------- | ---------------------------------------------------- |
| 🔐 Authentication System  | Secure login, registration, and account management.  |
| 📊 Financial Dashboard    | Real-time overview of income, expenses, and balance. |
| 💸 Transaction Management | Add, edit, delete, and categorize transactions.      |
| 🎯 Savings Goals          | Track progress toward financial targets.             |
| 👤 User Profile           | Manage personal information and preferences.         |
| 🔔 Smart Notifications    | Receive reminders and financial updates.             |

---

# 📱 Application Screenshots

<div align="center">

|                      Dashboard                     |                    Transactions                    |                     Profile                     |
| :------------------------------------------------: | :------------------------------------------------: | :---------------------------------------------: |
| <img src="Screenshots/dashboard.jpeg" width="220"> | <img src="Screenshots/transaksi.jpeg" width="220"> | <img src="Screenshots/profil.jpeg" width="220"> |
|                💰 Financial Overview               |               🧾 Transaction Tracking              |                👤 User Management               |

</div>

---

# 🏗 System Architecture

Finora implements the **MVVM (Model-View-ViewModel)** architecture combined with the **Repository Pattern** to ensure scalability, maintainability, and clean code practices.

```text
┌────────────────────┐
│    Presentation    │
│       (UI)         │
└─────────┬──────────┘
          │
┌─────────▼──────────┐
│     ViewModel      │
│ Business Logic     │
└─────────┬──────────┘
          │
┌─────────▼──────────┐
│    Repository      │
│   Data Handling    │
└─────────┬──────────┘
          │
┌─────────▼──────────┐
│ Database / API     │
└────────────────────┘
```

---

# ⚙️ Technology Stack

| Technology            | Purpose                           |
| --------------------- | --------------------------------- |
| 🐦 Flutter            | Cross-platform mobile development |
| 🎯 Dart               | Programming language              |
| 🗄 SQLite             | Local database                    |
| 🧩 MVVM               | Software architecture             |
| 📦 Repository Pattern | Data management                   |
| 🌐 REST API           | Backend communication             |

---

# 📂 Project Structure

```text
Finora/
│
├── Backend/         # Backend services
├── Frontend/        # Flutter application
├── DetailsPage/     # Additional pages
├── Screenshots/     # Application screenshots
│
└── README.md
```

---

# 🚀 Installation

```bash
# Clone repository
git clone https://github.com/Xaverria30/Finora.git

# Enter frontend folder
cd Finora/Frontend

# Install dependencies
flutter pub get

# Run application
flutter run
```

---

# 🎯 Project Objectives

* Improve users' financial awareness.
* Help users monitor income and expenses.
* Encourage consistent saving habits.
* Provide accessible financial management tools.
* Deliver a simple and intuitive user experience.

---

# 🛣 Future Enhancements

* 📈 Financial analytics dashboard
* ☁️ Cloud synchronization
* 🌙 Dark mode
* 📄 Export financial reports
* 🤖 AI-powered financial insights
* 🔔 Advanced smart notifications

---

# 👨‍💻 Development Team

Finora was developed as a mobile application project focused on personal financial management using modern software architecture and Flutter technology.

---

<div align="center">

## 💙 Finora

### Your Smart Financial Companion

*Track your money, achieve your goals, and build better financial habits.*

⭐ **If you like this project, don't forget to give it a star!** ⭐

</div>
