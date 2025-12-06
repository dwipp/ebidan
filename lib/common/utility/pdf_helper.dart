import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/data/models/bidan_model.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';

class PdfHelper {
  final _firestore = FirebaseFirestore.instance;

  // =============================
  // Ambil data dari Firestore
  // =============================
  Future<Map<String, dynamic>> getStatistics(String uid) async {
    final doc = await _firestore.collection('statistics').doc(uid).get();

    if (!doc.exists) throw Exception("Data statistik tidak ditemukan");

    final data = doc.data();
    return data?['by_month'] ?? {};
  }

  // =============================
  // Pilih Bulan
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

  // =============================
  // Generate PDF on selected month
  // =============================
  Future<Uint8List> generatePdfSingleMonth({
    required Bidan bidan,
    required Map<String, dynamic> byMonth,
    required String month,
    required String uid,
  }) async {
    final pdf = pw.Document();

    final logo = await imageFromAssetBundle('assets/icons/app_icon.png');

    final content = byMonth[month] ?? {};

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER tetap sama
              pw.Container(
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
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    pw.Spacer(),
                    pw.Text(
                      "generated at: ",
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 11),
                    ),
                    pw.Text(
                      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),
              pw.Text(
                "Bidan: ${bidan.nama}",
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.Text("NIP: ${bidan.nip}", style: pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 16),

              ...content.keys.map((sectionName) {
                final section = Map<String, dynamic>.from(content[sectionName]);

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(vertical: 6),
                      color: PdfColors.pink100,
                      child: pw.Text(
                        sectionName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Table(
                      border: pw.TableBorder.all(width: 0.5),
                      children: section.entries.map((e) {
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
                    ),
                    pw.SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // =============================
  // Generate PDF semua Bulan
  // =============================
  Future<Uint8List> generatePdf({
    required Bidan bidan,
    required Map<String, dynamic> byMonth,
    required String uid,
  }) async {
    final pdf = pw.Document();

    // Load logo dari assets
    final logo = await imageFromAssetBundle('assets/icons/app_icon.png');

    byMonth.forEach((month, content) {
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ================= HEADER PROFESIONAL =================
                pw.Container(
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
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 48,
                        height: 48,
                        child: pw.Image(logo),
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
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      pw.Spacer(),
                      pw.Text(
                        "generated at: ",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                        ),
                      ),
                      pw.Text(
                        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Bidan: ${bidan.nama}",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text("NIP: ${bidan.nip}", style: pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 16),

                // =====================================================
                ...content.keys.map((sectionName) {
                  final section = Map<String, dynamic>.from(
                    content[sectionName],
                  );

                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.symmetric(vertical: 6),
                        color: PdfColors.pink100,
                        child: pw.Text(
                          sectionName.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 6),

                      pw.Table(
                        border: pw.TableBorder.all(width: 0.5),
                        children: section.entries.map((e) {
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
                      ),

                      pw.SizedBox(height: 20),
                    ],
                  );
                }).toList(),
              ],
            );
          },
        ),
      );
    });

    return pdf.save();
  }

  // =============================
  // END-TO-END: Generate + Download
  // =============================
  Future<void> generateAndDownload(Bidan bidan) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final data = await getStatistics(uid);
    final pdfBytes = await generatePdf(bidan: bidan, byMonth: data, uid: uid);
    await downloadPdf(pdfBytes, uid);
  }

  Future<void> downloadPdf(Uint8List pdfBytes, String uid) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: "laporan-$uid.pdf");
  }

  // =============================
  // END-TO-END: Generate + Preview
  // =============================
  Future<void> generateAndPreview(BuildContext context, Bidan bidan) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final data = await getStatistics(uid);

    final months = data.keys.toList()..sort();

    final selectedMonth = await pickMonthDialog(context, months);
    if (selectedMonth == null) return; // user cancel

    Snackbar.show(
      context,
      message: 'Generate PDF...',
      type: SnackbarType.general,
    );
    // final pdfBytes = await generatePdf(bidan: bidan, byMonth: data, uid: uid);
    final pdfBytes = await generatePdfSingleMonth(
      bidan: bidan,
      byMonth: data,
      month: selectedMonth,
      uid: uid,
    );
    previewPdf(context, pdfBytes, 'laporan-${bidan.desa.toLowerCase()}');
  }

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
}
