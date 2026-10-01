# eBidan

eBidan adalah aplikasi mobile untuk membantu **bidan** melakukan **pencatatan** dan **pelaporan** kesehatan ibu hamil, bersalin, dan nifas — mulai dari data pasien, kunjungan (K1–K6, KF1–KF4), persalinan, hingga statistik bulanan. Tersedia juga mode **koordinator** untuk memantau bidan di wilayahnya.

## Fitur

- **Data ibu hamil (bumil)** — pencatatan data pasien, riwayat, dan pemindaian KTP via OCR (ML Kit) untuk mempercepat input
- **Kehamilan** — pelacakan per kehamilan: HPHT/HTP, GPA, dan riwayat kunjungan
- **Kunjungan** — pencatatan kunjungan antenatal dengan format SOAP (Subjective, Objective, Analysis, Planning)
- **Persalinan & nifas** — pencatatan persalinan dan kunjungan nifas
- **Statistik** — agregasi bulanan (kunjungan, persalinan, resti, SF) dengan grafik, dihitung otomatis via Cloud Functions
- **Cetak PDF** — laporan siap cetak
- **Mode koordinator** — pantau bidan di wilayah kerja
- **Langganan (premium)** — Google Play in-app purchase dengan verifikasi server-side (Cloud Functions + RTDN)
- **Offline-friendly** — cache Firestore + peringatan pending writes sebelum logout

## Teknologi

- [Flutter](https://flutter.dev) (Dart SDK ^3.8)
- State management: [flutter_bloc](https://pub.dev/packages/flutter_bloc) + [hydrated_bloc](https://pub.dev/packages/hydrated_bloc)
- Backend: Firebase (Firestore, Auth, Cloud Functions, Messaging, Remote Config)
- Login: Google Sign-In
- OCR KTP: Google ML Kit (text & object recognition)
- PDF: `pdf` + `printing`

## Mulai Cepat

### Prasyarat

- Flutter SDK (lihat versi di `pubspec.yaml`)
- Firebase CLI (`npm i -g firebase-tools`)
- Akun Firebase dengan dua project: **dev** dan **prod**

### Setup

```bash
# 1. Install dependensi
flutter pub get

# 2. Generate konfigurasi Firebase per project
#    (firebase.json sudah berisi mapping project dev/prod)
flutterfire configure
```

Konfigurasi aplikasi dipilih lewat `APP_ENV` (`dev` / `prod`, default `dev`) yang menentukan `FirebaseOptions` yang dipakai (`lib/configs/firebase_dev_options.dart` / `firebase_prod_options.dart`).

### Menjalankan (development)

```bash
flutter run --flavor dev --dart-define=APP_ENV=dev
```

Flavor `dev` memakai applicationId `.dev` dan nama aplikasi "eBidan Dev".

### Build rilis (Android)

```bash
./build_release.sh   # flutter build appbundle --release --flavor prod
```

## Cloud Functions

Kode Cloud Functions ada di folder `functions/` (Node.js, ESM). Cakupan:

- Trigger agregasi statistik (increment/recalculate, pola rolling 13 bulan)
- Verifikasi & penyimpanan langganan Google Play (`verifySubscription`, RTDN)
- Notifikasi terjadwal (broadcast mingguan)
- Migrasi data (one-off)

Deploy:

```bash
cd functions
./deploy_dev.sh              # deploy semua function ke project dev
./deploy_dev.sh <namaFunc>   # deploy satu function
./deploy_prod.sh             # ke project prod, ada konfirmasi ketik YES
```

Secret (mis. `GOOGLE_SERVICE_ACCOUNT_JSON` untuk verifikasi Play) dikelola via Secret Manager, bukan file.

## Struktur Project

```
lib/
├── common/              # utilitas umum (OCR KTP, PDF helper, extensions)
├── configs/             # env, firebase options, AuthGate
├── data/models/         # model data (Bumil, Kehamilan, Kunjungan, Persalinan, ...)
├── presentation/
│   ├── router/          # AppRouter (onGenerateRoute)
│   ├── screens/
│   │   ├── auth/        # login, register, intro
│   │   ├── mode_bidan/  # bumil, kehamilan, kunjungan, nifas, persalinan, statistik, ...
│   │   ├── mode_koordinator/
│   │   ├── profile/
│   │   └── ...
│   └── widgets/         # widget bersama
└── state_management/    # cubit per fitur (+ bloc_providers)

functions/               # Cloud Functions (Node.js)
assets/                  # icons, images, model ML (tflite)
```

## Konvensi

- Bahasa aplikasi: Indonesia (`id_ID`)
- Versi aplikasi di-update di `pubspec.yaml` (`version: x.y.z+build`)
- Lint mengikuti `package:flutter_lints/flutter.yaml` (lihat `analysis_options.yaml`)
