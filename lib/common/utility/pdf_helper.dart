import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/common/Utils.dart';
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
    List<String> months,
  ) async {
    String selected = months.isNotEmpty ? months.last : "";

    return showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Pilih Bulan"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                value: selected,
                items: months.map((m) {
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
      MapEntry("Kehamilan", stats.kehamilan.toMap()),
      MapEntry("Pasien", stats.pasien.toMap()),
      MapEntry("Kunjungan", stats.kunjungan.toMap()),
      MapEntry("Persalinan", stats.persalinan.toMap()),
      MapEntry("Risiko Tinggi", stats.resti.toMap()),
      MapEntry("SF", stats.sf.toMap()),
    ];
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

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        header: (context) {
          return _header(bidan, month, logo);
        },
        build: (context) {
          final sections = extractSections(stats);

          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                ...sections.map((entry) {
                  // print('entry: ${entry}');
                  final sectionName = entry.key;
                  final values = entry.value;

                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
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
                      pw.SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // =============================
  // Generate PDF All Month
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

      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _header(bidan, month, logo),

                pw.SizedBox(height: 20),
                pw.Text(
                  "Bidan: ${bidan.nama}",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text("NIP: ${bidan.nip}", style: pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 16),

                ...sections.map((entry) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(entry.key),
                      pw.SizedBox(height: 6),
                      _table(entry.value),
                      pw.SizedBox(height: 20),
                    ],
                  );
                }),
              ],
            );
          },
        ),
      );
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
        children: [
          pw.Container(width: 48, height: 48, child: pw.Image(logo)),
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
          pw.Text(
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
            style: pw.TextStyle(color: PdfColors.white, fontSize: 11),
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
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      color: PdfColors.pink100,
      child: pw.Text(
        title.toUpperCase(),
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
        return pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(e.key),
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

    previewPdf(context, pdfBytes, "laporan-${bidan.desa.toLowerCase()}");

    Snackbar.show(
      context,
      message: 'PDF berhasil dibuat.',
      type: SnackbarType.success,
    );
  }
}
