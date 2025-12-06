import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfHelper {
  final _firestore = FirebaseFirestore.instance;

  // =============================
  // 1. Ambil data dari Firestore
  // =============================
  Future<Map<String, dynamic>> getStatistics(String uid) async {
    final doc = await _firestore.collection('statistics').doc(uid).get();

    if (!doc.exists) throw Exception("Data statistik tidak ditemukan");

    final data = doc.data();
    return data?['by_month'] ?? {};
  }

  // =============================
  // 2. Generate PDF
  // =============================
  Future<Uint8List> generatePdf({
    required Map<String, dynamic> byMonth,
    required String uid,
  }) async {
    final pdf = pw.Document();

    byMonth.forEach((month, content) {
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Laporan Statistik $month",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text("UID: $uid", style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 20),

                ...content.keys.map((sectionName) {
                  final section = Map<String, dynamic>.from(
                    content[sectionName],
                  );

                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        sectionName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
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
    });

    return pdf.save();
  }

  // =============================
  // 3. Share/download PDF ke HP
  // =============================
  Future<void> downloadPdf(Uint8List pdfBytes, String uid) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: "laporan-statistik-$uid.pdf",
    );
  }

  // =============================
  // 5. END-TO-END: Generate + Download
  // =============================
  Future<void> generateAndDownload() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final data = await getStatistics(uid);
    final pdfBytes = await generatePdf(byMonth: data, uid: uid);
    await downloadPdf(pdfBytes, uid);
  }

  // =============================
  // 6. END-TO-END: Generate + Preview
  // =============================
  Future<Uint8List?> generateAndPreview() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final data = await getStatistics(uid);
    final pdfBytes = await generatePdf(byMonth: data, uid: uid);
    return pdfBytes;
  }
}
