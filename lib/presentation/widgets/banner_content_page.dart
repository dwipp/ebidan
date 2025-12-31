import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class BannerContentScreen extends StatelessWidget {
  const BannerContentScreen({super.key});

  static const String markdownContent = '''
# Garansi Uang Kembali 30 Hari

Kami ingin Anda merasa aman saat mencoba **eBidan**.  
Karena itu, kami memberikan **Garansi Uang Kembali 100%** untuk pengguna baru.

---

## Apa itu Garansi Uang Kembali?

Garansi ini memungkinkan Anda mengajukan **pengembalian dana penuh** jika dalam masa awal penggunaan eBidan dirasa belum sesuai dengan kebutuhan Anda.

**Tanpa ribet. Tanpa alasan panjang.**

---

## Ketentuan Garansi

Garansi uang kembali berlaku dengan ketentuan berikut:

- Berlaku maksimal **30 hari sejak tanggal pembayaran**
- Hanya untuk **pembelian pertama**
- Berlaku untuk **paket 6 Bulan dan Tahunan**
- **1 akun hanya dapat mengajukan refund 1 kali**

---

## Paket yang Tidak Termasuk Garansi

- Paket Bulanan
- Pembelian ulang / perpanjangan langganan

---

## Cara Mengajukan Garansi

Hubungi **WhatsApp resmi eBidan**, lalu kirimkan:

- Nama  
- Nomor HP terdaftar  

Tim kami akan melakukan **verifikasi singkat**.

⏱️ Proses maksimal **1–2 hari kerja**

---

## Proses Pengembalian Dana

- Dana dikembalikan ke **metode pembayaran awal**
- Proses maksimal **7 hari kerja**
- Setelah refund, akun akan otomatis kembali ke **mode gratis**

---

## Bagaimana dengan Data Saya?

Data pasien Anda **tidak dihapus**.  
Namun, fitur premium akan **dinonaktifkan** setelah refund.

---

## Catatan Penting

Garansi dapat dibatalkan jika ditemukan penyalahgunaan, seperti:

- Pembuatan akun ganda
- Klaim berulang
- Aktivitas tidak wajar

---

## Komitmen Kami

Garansi ini dibuat **bukan untuk mempersulit**,  
tetapi untuk memberi Anda **rasa aman saat mencoba eBidan**.

Jika cocok, lanjutkan.  
Jika belum, **kami kembalikan uang Anda.**
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Markdown(
          data: markdownContent,
          padding: const EdgeInsets.all(16),
          styleSheet: MarkdownStyleSheet(
            h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            p: const TextStyle(fontSize: 14, height: 1.6),
            listBullet: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
