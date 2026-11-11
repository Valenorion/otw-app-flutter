# 🚀 OTW. (On The Way) - Real-time Squad Ping & Chat Application

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Vercel](https://img.shields.io/badge/Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)
![Netlify](https://img.shields.io/badge/Netlify-00C7B7?style=for-the-badge&logo=netlify&logoColor=white)

**OTW.** adalah aplikasi *real-time squad coordination* berbasis Cross-Platform (Android & Web) yang dirancang untuk membantu grup teman/squad berkoordinasi secara instan melalui fitur **One-Tap Ping Notification** dan **Real-time Messaging**.

---

## 💡 Latar Belakang & Masalah
Dalam koordinasi aktivitas mendadak (seperti *mabar*, kumpul santai, atau *hangout*), pesan singkat di grup *messaging* biasa sering kali diabaikan (*ignored*) atau tenggelam dalam riwayat obrolan. **OTW.** menyelesaikan masalah ini dengan menyediakan mekanisme **Ping darurat berprioritas tinggi** yang dapat memicu notifikasi visual dan suara langsung ke HP seluruh anggota squad secara *real-time*.

---

## 🏗️ Arsitektur Sistem (Microservices Pattern)

Aplikasi ini dibangun menggunakan pendekatan **Serverless Microservices** untuk memisahkan beban *Frontend UI* dan eksekusi *Push Notification Server*:

```
  [ Flutter Web (Netlify) ]  ──┐
                               ├──> [ Firestore Database & Firebase Auth ]
  [ Flutter Android (APK) ]  ──┘                 ▲
                                                 │
                                                 │ HTTP POST /api/ping
                                                 ▼
                                    [ Node.js FCM Engine (Vercel) ]
```

- **Frontend Application (Flutter):** Dipublikasikan di Netlify untuk platform Web dan berjalan secara *native* pada Android.
- **Real-time Database & Auth (Firebase):** Mengelola sesi Google Sign-In, status pengguna, serta *channeling* obrolan *real-time*.
- **Notification Engine (Node.js + Vercel):** *Serverless Function* yang menangani otorisasi Service Account Firebase Admin SDK dan mengirimkan *Push Notification* (FCM) berprioritas tinggi ke HP pengguna.

---

## 🔥 Fitur Utama
1. **Google Single Sign-In (Cross-Platform):** Otentikasi aman menggunakan Firebase Auth yang terintegrasi di Android (SHA-1 fingerprint verified) dan Web Authorized Domains.
2. **One-Tap Squad PING:** Mengirimkan *push notification* instan berprioritas tinggi (`priority: high`) ke semua anggota squad yang terdaftar.
3. **Real-time Group Chat:** Obrolan langsung tanpa *delay* berbasis Cloud Firestore stream.
4. **Custom Audio & Visual Feedback:** Efek suara PING kustom dan animasi UI responsif.
5. **Background Notification Handling:** Tetap menerima notifikasi meskipun aplikasi di Android berada di latar belakang (*background state*) atau layar terkunci.

---

## 🛠️ Stack Teknologi & Alat

| Kategori | Teknologi / Library |
| :--- | :--- |
| **Frontend Framework** | Flutter (Dart SDK 3.x) |
| **Backend & Serverless** | Node.js, Vercel Serverless Functions |
| **Cloud Services** | Firebase (Auth, Firestore, FCM / Firebase Messaging) |
| **SDK & Libraries** | `firebase-admin` (Modular), `flutter_local_notifications`, `google_sign_in`, `audioplayers` |
| **CI/CD & Hosting** | GitHub, Netlify (Frontend Continuous Deployment), Vercel (Backend API) |
| **Tools & Build** | Flutter Launcher Icons, Gradle (Kotlin DSL), Android SDK (compileSdk 37) |

---

## 🧠 Pembelajaran Key (Key Learnings & Problem Solving)

Proyek ini menjadi sarana belajar intensif mengenai arsitektur perangkat lunak modern dan penanganan masalah *engineering* tingkat lanjut:

1. **Konfigurasi Serverless Backend & ESM Interop:**
   - Memahami tantangan pembungkusan modul CommonJS vs ESM pada lingkungan Vercel serverless.
   - Mengimplementasikan **Firebase Admin SDK Modular** (`firebase-admin/app` & `firebase-admin/messaging`) untuk mencegah kesalahan inisialisasi instance `cert` dan `apps`.

2. **Cross-Drive Compilation & Build System (Windows/Gradle):**
   - Memecahkan masalah keterbatasan kompilasi inkremental Kotlin ketika Pub Cache berada di drive berbeda (`C:`) dari repositori proyek (`D:`).
   - Mengonfigurasi `PUB_CACHE` environment variables serta migrasi ke **Gradle Kotlin DSL (`build.gradle.kts`)**.
   - Mengatur Java Desugaring (`isCoreLibraryDesugaringEnabled = true`) untuk mendukung fitur Java modern pada pustaka notifikasi Android.

3. **Keamanan & Integrasi Firebase Android:**
   - Mengonfigurasi *SHA-1 Fingerprint* dari JDK Local Keystore ke Firebase Console untuk mengizinkan otentikasi Google Sign-In secara *native* pada Android.
   - Mengatur *Authorized Domains* pada Firebase Auth agar *build release* di Netlify dapat berjalan tanpa hambatan keanggotaan OAuth.

4. **Optimasi Notifikasi Khas Vendor (MIUI / Android OS):**
   - Mengatasi pembatasan latar belakang (*battery optimization*) dan perizinan *Floating Notifications* / Pop-up pada perangkat Android (Xiaomi/MIUI).

---

## 📦 Cara Menjalankan Proyek Secara Lokal

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.13 atau terbaru)
- Node.js versi 18+
- HP Android fisik (dengan USB Debugging aktif) atau Emulator

### 1. Backend (Node.js / Vercel)
```bash
cd otw-backend
npm install
# Set environment variables: PROJECT_ID, CLIENT_EMAIL, PRIVATE_KEY
npx vercel dev
```

### 2. Frontend (Flutter)
```bash
cd otw_app
flutter pub get
flutter run
```

---

## 👨‍💻 Pengembang
**Valenorion** - *Full-Stack / Cross-Platform Mobile Developer*  
- GitHub: [@Valenorion](https://github.com/Valenorion)

---
*Dikembangkan sebagai portofolio eksplorasi arsitektur Real-Time Messaging & Cloud Push Notifications.*
