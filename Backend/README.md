# API Backend Finora

Ini adalah backend REST API berbasis Express.js yang terhubung dengan Firebase untuk aplikasi manajemen keuangan Finora.

## Teknologi Utama
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database & Auth**: Firebase (Firestore & Auth melalui Firebase Admin SDK)

---

## Memulai

### 1. Prasyarat
- Node.js (v18 ke atas)
- pnpm

### 2. Konfigurasi
Buat file `.env` di dalam folder root `backend`:
```env
PORT=3000
FIREBASE_API_KEY=api-key-web-firebase-anda
```

Tempatkan file kunci akun layanan (*service account key*) Firebase Admin SDK Anda di folder root backend dengan nama `firebase-key.json`.

### 3. Instalasi Dependensi
```bash
pnpm install
```

### 4. Menjalankan Server
```bash
# Menjalankan dalam mode produksi
pnpm start

# Menjalankan dalam mode pengembangan
pnpm run dev
```

---

## Referensi API Endpoint

Semua endpoint (kecuali rute autentikasi) memerlukan Firebase ID Token yang valid dikirim melalui header `Authorization`:
`Authorization: Bearer <firebase_id_token>`

### 1. Autentikasi (`/api/auth`)
- **POST `/api/auth/register`**
  - Payload: `{ "email": "...", "password": "...", "displayName": "..." }`
  - Respons: `201 Created` beserta token akses dan objek data pengguna.
- **POST `/api/auth/login`**
  - Payload: `{ "email": "...", "password": "..." }`
  - Respons: `200 OK` beserta token akses dan objek data pengguna.
- **POST `/api/auth/refresh`**
  - Payload: `{ "refreshToken": "..." }`
  - Respons: `200 OK` dengan token baru.
- **POST `/api/auth/logout`**
  - Respons: `200 OK`.
- **POST `/api/auth/change-password`**
  - Payload: `{ "newPassword": "..." }`
  - Respons: `200 OK`.

### 2. Profil Pengguna (`/api/users`)
- **GET `/api/users/me`**
  - Respons: `200 OK` berisi detail data pengguna.
- **PUT `/api/users/me`**
  - Payload: Bidang data pengguna yang ingin diperbarui.
  - Respons: `200 OK` berisi data pengguna yang telah diperbarui.

### 3. Kategori (`/api/categories`)
- **GET `/api/categories`**
  - Respons: `200 OK` dengan format `{ "data": [...] }`.
- **POST `/api/categories`**
  - Payload: `{ "name": "...", "icon": "...", "color": "...", "type": "expense/income" }`
  - Respons: `201 Created` berisi objek kategori yang baru dibuat.
- **PUT `/api/categories/:id`**
  - Payload: Bidang kategori yang ingin diperbarui.
  - Respons: `200 OK` berisi data kategori terupdate.
- **DELETE `/api/categories/:id`**
  - Respons: `204 No Content`.

### 4. Transaksi (`/api/transactions`)
- **GET `/api/transactions`**
  - Respons: `200 OK` dengan format `{ "data": [...] }`.
- **GET `/api/transactions/:id`**
  - Respons: `200 OK` berisi detail transaksi.
- **POST `/api/transactions`**
  - Payload: `{ "categoryId": "...", "amount": 0.0, "type": "expense/income", "description": "...", "date": "..." }`
  - Respons: `201 Created`. (Memicu pengiriman push notification FCM di latar belakang).
- **PUT `/api/transactions/:id`**
  - Payload: Bidang transaksi yang ingin diperbarui.
  - Respons: `200 OK`.
- **DELETE `/api/transactions/:id`**
  - Respons: `204 No Content`.

### 5. Anggaran (`/api/budgets`)
- **GET `/api/budgets`**
  - Respons: `200 OK` dengan format `{ "data": [...] }`.
- **GET `/api/budgets/:id`**
  - Respons: `200 OK` berisi detail anggaran.
- **POST `/api/budgets`**
  - Payload: `{ "categoryId": "...", "limitAmount": 0.0, "month": "..." }`
  - Respons: `201 Created`.
- **PUT `/api/budgets/:id`**
  - Payload: `{ "limitAmount": 0.0 }`
  - Respons: `200 OK`.
- **DELETE `/api/budgets/:id`**
  - Respons: `204 No Content`.

### 6. Tujuan Tabungan (`/api/saving-goals`)
- **GET `/api/saving-goals`**
  - Respons: `200 OK` dengan format `{ "data": [...] }`.
- **GET `/api/saving-goals/:id`**
  - Respons: `200 OK` berisi detail tujuan tabungan.
- **POST `/api/saving-goals`**
  - Payload: `{ "name": "...", "description": "...", "targetAmount": 0.0, "deadline": "..." }`
  - Respons: `201 Created`.
- **PUT `/api/saving-goals/:id`**
  - Payload: `{ "targetAmount": 0.0, "deadline": "..." }`
  - Respons: `200 OK`.
- **DELETE `/api/saving-goals/:id`**
  - Respons: `204 No Content`.
- **POST `/api/saving-goals/:id/contribute`**
  - Payload: `{ "amount": 0.0 }`
  - Respons: `200 OK` berisi objek tujuan tabungan yang telah diperbarui.

### 7. Registrasi Token FCM (`/api/fcm`)
- **POST `/api/fcm/register`**
  - Payload: `{ "userId": "...", "fcmToken": "...", "deviceName": "...", "deviceInfo": "..." }`
  - Respons: `200 OK`.
