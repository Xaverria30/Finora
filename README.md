# 💙 Finora

<div align="center">

# Finora — Smart Personal Finance App

### *Manage • Track • Save • Grow*

A modern mobile application that helps users manage personal finances, monitor expenses, achieve savings goals, and build better financial habits.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white">
  <img src="https://img.shields.io/badge/MVVM-Architecture-success?style=for-the-badge">
  <img src="https://img.shields.io/badge/SQLite-Database-blue?style=for-the-badge">
  <img src="https://img.shields.io/badge/Platform-Android-success?style=for-the-badge">
</p>

### 💰 Your Smart Financial Companion

Helping users build better financial habits through technology.

</div>

---

## 📖 Overview

Finora is a personal finance mobile application developed to help users manage their finances efficiently and securely. The application allows users to track income and expenses, monitor savings goals, analyze spending habits, and maintain financial awareness through an intuitive and user-friendly interface.

---

## ✨ Key Features

### 🔐 Authentication System

* User registration and login
* Secure authentication process
* Account management

### 📊 Financial Dashboard

* Display current balance
* Income and expense summaries
* Financial statistics visualization

### 💸 Transaction Management

* Record income transactions
* Record expense transactions
* Edit and delete transaction history
* Transaction categorization

### 🎯 Savings Goals

* Set financial targets
* Track saving progress
* Monitor achievement status

### 👤 User Profile

* View personal information
* Update account details
* Manage user settings

### 🔔 Notifications

* Financial reminders
* Transaction updates
* Activity notifications

---

## 📱 Application Screenshots

<div align="center">

|                      Dashboard                     |                    Transactions                    |                     Profile                     |
| :------------------------------------------------: | :------------------------------------------------: | :---------------------------------------------: |
| <img src="Screenshots/dashboard.jpeg" width="220"> | <img src="Screenshots/transaksi.jpeg" width="220"> | <img src="Screenshots/profil.jpeg" width="220"> |
|                   Dashboard Page                   |                  Transaction Page                  |                   Profile Page                  |

</div>

---

## 🏗️ System Architecture

Finora implements the **Model-View-ViewModel (MVVM)** architecture along with the **Repository Pattern** to ensure maintainable and scalable code.

```text
┌────────────────────┐
│   Presentation UI  │
└─────────┬──────────┘
          │
┌─────────▼──────────┐
│     ViewModel      │
└─────────┬──────────┘
          │
┌─────────▼──────────┐
│     Repository     │
└─────────┬──────────┘
          │
┌─────────▼──────────┐
│ Database / API     │
└────────────────────┘
```

---

## ⚙️ Technology Stack

| Technology         | Description                     |
| ------------------ | ------------------------------- |
| Flutter            | Cross-platform mobile framework |
| Dart               | Programming language            |
| SQLite             | Local database                  |
| MVVM               | Application architecture        |
| Repository Pattern | Data management                 |
| REST API           | Backend communication           |

---

## 📂 Project Structure

```text
Finora/
│
├── Backend/              # Backend services
├── Frontend/             # Flutter application source code
├── DetailsPage/          # Additional application pages
├── Screenshots/          # Application screenshots
│
└── README.md
```

---

## 🚀 Installation

### Clone Repository

```bash
git clone https://github.com/username/finora.git
```

### Navigate to Project Folder

```bash
cd finora/Frontend
```

### Install Dependencies

```bash
flutter pub get
```

### Run Application

```bash
flutter run
```

---

## 🎯 Future Enhancements

* 📈 Financial analytics dashboard
* ☁️ Cloud synchronization
* 🌙 Dark mode support
* 📄 Export financial reports
* 🤖 Smart financial insights
* 🔔 Advanced notifications

---

## 📊 Project Objectives

* Improve financial awareness.
* Help users track income and expenses.
* Encourage healthy saving habits.
* Provide simple financial management tools.
* Deliver an intuitive user experience.

---

## 👨‍💻 Development Team

Developed as a mobile application project focused on personal financial management using modern software architecture and Flutter technology.

---

<div align="center">

## 💙 Finora

### Your Smart Financial Companion

*Track your money, achieve your goals, and build better financial habits.*

</div>
