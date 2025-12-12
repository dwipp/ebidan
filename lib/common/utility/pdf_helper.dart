import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/common/utility/extensions.dart';
import 'package:ebidan/data/models/bidan_model.dart';
import 'package:ebidan/data/models/statistic_model.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class PdfHelper {
  final _firestore = FirebaseFirestore.instance;

  final Map<String, String> fieldLabels = {
    // Kehamilan
    "kehamilan_total": "Total Kehamilan",
    "kehamilan_abortus": "Abortus",
    "kehamilan_resti_masyarakat": "Risiko Masyarakat",
    "kehamilan_resti_nakes": "Risiko Nakes",

    // Pasien
    "pasien_total": "Total Pasien",

    // Kunjungan
    "kunjungan_total": "Total Kunjungan",
    "kunjungan_abortus": "Abortus",
    "kunjungan_k1": "K1",
    "kunjungan_k1_4t": "K1 dengan 4T",
    "kunjungan_k1_akses": "K1 Akses",
    "kunjungan_k1_akses_dokter": "K1 Akses Skrining Dokter",
    "kunjungan_k1_akses_usg": "K1 Akses USG",
    "kunjungan_k1_murni": "K1 Murni",
    "kunjungan_k1_murni_dokter": "K1 Murni  Skrining Dokter",
    "kunjungan_k1_murni_usg": "K1 Murni USG",
    "kunjungan_k1_usg": "K1 USG",
    "kunjungan_k1_dokter": "K1 Skrining Dokter",
    "kunjungan_k2": "K2",
    "kunjungan_k3": "K3",
    "kunjungan_k4": "K4",
    "kunjungan_k5": "K5",
    "kunjungan_k5_usg": "K5 USG",
    "kunjungan_k6": "K6",
    "kunjungan_k6_usg": "K6 USG",

    // Persalinan
    "persalinan_total": "Total Persalinan",
    "persalinan_tempat_rs": "RS",
    "persalinan_tempat_rsb": "RS Bersalin",
    "persalinan_tempat_klinik": "Klinik",
    "persalinan_tempat_bpm": "Bidan Praktik Mandiri",
    "persalinan_tempat_pkm": "Puskesmas",
    "persalinan_tempat_poskesdes": "Poskesdes",
    "persalinan_tempat_polindes": "Polindes",
    "persalinan_persalinan_faskes": "Persalinan Faskes",
    "persalinan_tempat_rumah_nakes": "Rumah Nakes",
    "persalinan_tempat_jalan_nakes": "Jalan Nakes",
    "persalinan_nakes": "Persalinan Nakes",
    "persalinan_tempat_rumah_dk_klg": "Rumah dgn Dukun atau Keluarga",
    "persalinan_cara_normal": "Spontan Belakang Kepala (Normal)",
    "persalinan_cara_vacuum": "Vacuum Extraction",
    "persalinan_cara_forceps": "Forceps Delivery",
    "persalinan_cara_sc": "Section Caesarea (SC)",
    "persalinan_bayi_lahir_hidup": "Bayi Lahir Hidup",
    "persalinan_bayi_lahir_mati": "Bayi Lahir Mati",
    "persalinan_bayi_iufd": "IUFD",

    // Resti
    "resti_anemia": "Anemia",
    "resti_bb_bayi_under_2500": "BB Bayi < 2500g",
    "resti_hipertensi": "Hipertensi",
    "resti_jarak_hamil": "Jarak Kehamilan Tidak Ideal",
    "resti_kek": "Kekurangan Energi Kronis (KEK)",
    "resti_obesitas": "Obesitas",
    "resti_paritas_tinggi": "Paritas Tinggi (>= 4x)",
    "resti_pernah_abortus": "Pernah Abortus",
    "resti_resti_masyarakat": "Risiko Masyarakat",
    "resti_resti_nakes": "Risiko Nakes",
    "resti_tb_under_145": "Risiko Panggul Sempit (TB < 145 cm)",
    "resti_too_old": "Usia Terlalu Tua (> 35 tahun)",
    "resti_too_young": "Usia Terlalu Muda (< 20 tahun)",

    // SF
    "sf_30": "SF1",
    "sf_60": "SF2",
    "sf_90": "SF3",
    "sf_120": "SF4",
    "sf_150": "SF5",
    "sf_180": "SF6",
    "sf_210": "SF7",
    "sf_240": "SF8",
    "sf_270": "SF9",
  };

  // =============================
  // Ambil data dari Firestore → return Statistic
  // =============================
  Future<Statistic> getStatistics(String uid) async {
    final doc = await _firestore.collection('statistics').doc(uid).get();

    if (!doc.exists) throw Exception("Data statistik tidak ditemukan");

    return Statistic.fromMap(doc.data()!);
  }

  // =============================
  // Dialog pilih bulan
  // =============================
  Future<String?> pickMonthDialog(
    BuildContext context,
    List<String> months, // format: YYYY-MM
  ) async {
    final now = DateTime.now();

    // hitung bulan sebelumnya dari hari ini
    final previousMonth = DateTime(now.year, now.month - 1);

    // filter: hanya bulan <= previousMonth
    final allowedMonths = months.where((m) {
      final parts = m.split("-");
      final y = int.parse(parts[0]);
      final mo = int.parse(parts[1]);
      final date = DateTime(y, mo);

      return date.isBefore(
        DateTime(previousMonth.year, previousMonth.month + 1),
      );
    }).toList();

    // sorting biar urut naik
    allowedMonths.sort((a, b) => a.compareTo(b));

    if (allowedMonths.isEmpty) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Data Belum Siap"),
          content: const Text(
            "Belum ada data yang siap untuk dijadikan Laporan PDF.\n\nCoba lagi di awal bulan depan.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return null;
    }

    String selected = allowedMonths.last;

    return showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Pilih Bulan"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                value: selected,
                items: allowedMonths.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text(Utils.formattedDateFromYearMonth(m)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selected = value!);
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selected),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================
  // Helper: convert ByMonthStats menjadi list section (nama + map)
  // ===========================================================
  List<MapEntry<String, Map<String, dynamic>>> extractSections(
    ByMonthStats stats,
  ) {
    return [
      MapEntry("Kehamilan", renameKeys("kehamilan", stats.kehamilan.toMap())),
      MapEntry("Kunjungan", renameKeys("kunjungan", stats.kunjungan.toMap())),
      MapEntry(
        "Persalinan",
        renameKeys("persalinan", stats.persalinan.toMap()),
      ),
      MapEntry("Risiko Tinggi", renameKeys("resti", stats.resti.toMap())),
      MapEntry("Konsumsi Suplemen Fe", renameKeys("sf", stats.sf.toMap())),
      MapEntry("Pasien", renameKeys("pasien", stats.pasien.toMap())),
    ];
  }

  Map<String, dynamic> renameKeys(String prefix, Map<String, dynamic> source) {
    return source.map((key, value) {
      return MapEntry("${prefix}_$key", value);
    });
  }

  // =============================
  // Generate PDF Single Month
  // =============================
  Future<Uint8List> generatePdfSingleMonth({
    required Bidan bidan,
    required ByMonthStats stats,
    required String month,
    required String uid,
  }) async {
    final pdf = pw.Document();
    final logo = await imageFromAssetBundle('assets/icons/app_icon.png');

    final sections = extractSections(stats);

    for (var entry in sections) {
      final sectionName = entry.key;
      final values = entry.value;

      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _header(bidan, month, logo),
                pw.SizedBox(height: 16),
                pw.Text(
                  "Bidan: ${bidan.nama}",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text("NIP: ${bidan.nip}", style: pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 16),

                _sectionTitle(sectionName),
                pw.SizedBox(height: 6),

                _table(values),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  // =============================
  // Generate PDF All Months
  // =============================
  Future<Uint8List> generatePdf({
    required Bidan bidan,
    required Map<String, ByMonthStats> byMonth,
    required String uid,
  }) async {
    final pdf = pw.Document();
    final logo = await imageFromAssetBundle('assets/icons/app_icon.png');

    byMonth.forEach((month, stats) {
      final sections = extractSections(stats);

      for (var entry in sections) {
        final sectionName = entry.key;
        final values = entry.value;

        pdf.addPage(
          pw.Page(
            margin: const pw.EdgeInsets.all(24),
            build: (context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _header(bidan, month, logo),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    "Bidan: ${bidan.nama}",
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    "NIP: ${bidan.nip}",
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(height: 16),

                  _sectionTitle(sectionName),
                  pw.SizedBox(height: 6),

                  _table(values),
                ],
              );
            },
          ),
        );
      }
    });

    return pdf.save();
  }

  // =============================
  // Component: Header PDF
  // =============================
  pw.Widget _header(Bidan bidan, String month, pw.ImageProvider logo) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [PdfColors.blue300, PdfColors.blue100],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        // crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 48,
            height: 48,
            child: pw.ClipRRect(
              horizontalRadius: 8,
              verticalRadius: 8,
              child: pw.Image(logo, fit: pw.BoxFit.cover),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Laporan Desa ${bidan.desa}",
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                "Puskesmas ${bidan.puskesmas}",
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                Utils.formattedDateFromYearMonth(month),
                style: pw.TextStyle(color: PdfColors.white, fontSize: 12),
              ),
            ],
          ),
          pw.Spacer(),
          pw.Container(
            height: 48,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  "dibuat pada",
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 8),
                ),
                pw.Text(
                  "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================
  // Component: Section Title
  // =============================
  pw.Widget _sectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      color: PdfColors.pink100,
      child: pw.Text(
        title.capitalizeFirst(),
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  // =============================
  // Component: Table
  // =============================
  pw.Widget _table(Map<String, dynamic> map) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      children: map.entries.map((e) {
        final label =
            fieldLabels[e.key] ??
            e.key; // fallback ke key kalau belum dimapping

        return pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(label),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(e.value.toString()),
            ),
          ],
        );
      }).toList(),
    );
  }

  // =============================
  // Preview PDF
  // =============================
  void previewPdf(BuildContext context, Uint8List pdf, String filename) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPreview(
          build: (format) async => pdf,
          pdfFileName: "$filename.pdf",
        ),
      ),
    );
  }

  // =============================
  // Generate + Preview
  // =============================
  Future<void> generateAndPreview(BuildContext context, Bidan bidan) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final stat = await getStatistics(uid);
    final byMonth = stat.byMonth;

    final months = byMonth.keys.toList()..sort();

    final selectedMonth = await pickMonthDialog(context, months);
    if (selectedMonth == null) return;

    Snackbar.show(
      context,
      message: 'Generate PDF...',
      type: SnackbarType.general,
    );

    final pdfBytes = await generatePdfSingleMonth(
      bidan: bidan,
      stats: byMonth[selectedMonth]!,
      month: selectedMonth,
      uid: uid,
    );

    // generate all months
    // final pdfBytes = await generatePdf(
    //   bidan: bidan,
    //   byMonth: byMonth,
    //   uid: uid,
    // );
    final filename = bidan.kategoriBidan?.toLowerCase() == 'bidan desa'
        ? 'laporan ${bidan.desa?.toLowerCase()}'
        : 'laporan ${bidan.namaPraktik?.toLowerCase()}';
    previewPdf(context, pdfBytes, filename);

    Snackbar.show(
      context,
      message: 'PDF berhasil dibuat.',
      type: SnackbarType.success,
    );
  }
}
