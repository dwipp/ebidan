import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';

class ReviewKunjunganScreen extends StatefulWidget {
  final Map<String, String> data;

  const ReviewKunjunganScreen({super.key, required this.data});

  @override
  State<ReviewKunjunganScreen> createState() => _ReviewKunjunganScreenState();
}

class _ReviewKunjunganScreenState extends State<ReviewKunjunganScreen> {
  bool _isLoading = false;
  Widget _buildRow(String label, String value, {String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value.isNotEmpty ? '$value $suffix' : "-",
              softWrap: true,
              maxLines: null, // biar multiline
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveData() async {
    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('kehamilan')
          .doc(widget.data['kehamilanId'])
          .collection('kunjungan');

      // Ambil jumlah dokumen di collection kunjungan
      final snapshot = await docRef.get();
      final nextId = (snapshot.docs.length + 1).toString(); // 1,2,3 dst
      final uk = widget.data['uk'] as String;
      await docRef.doc(nextId).set({
        'bb': widget.data['bb'],
        'created_at': DateTime.now(),
        'keluhan': widget.data['keluhan'],
        'lila': widget.data['lila'],
        'lp': widget.data['lp'],
        'planning': widget.data['planning'],
        'status': widget.data['status'],
        'td': widget.data['td'],
        'tfu': widget.data['tfu'],
        'uk': uk.replaceAll(RegExp(r'[^0-9]'), ''),
      });
      print('resti masuk: ${widget.data['firstTime']}');
      if (widget.data['firstTime'] == "1") {
        List<String> resti = [];
        if (widget.data['td'] != null && widget.data['td']!.contains('/')) {
          List<String> parts = widget.data['td']!.split("/");
          if (parts.length == 2) {
            int sistolik = int.parse(parts[0]);
            int diastolik = int.parse(parts[1]);

            if (sistolik >= 140 || diastolik >= 90) {
              resti.add('Hipertensi dalam kehamilan ${widget.data['td']} mmHg');
            }
          }
        }
        if (widget.data['lila'] != null) {
          if (int.parse(widget.data['lila']!) < 23.5) {
            resti.add(
              'Kekurangan Energi Kronis (lila: ${widget.data['lila']} cm)',
            );
          }
        }
        print('resti: $resti');
        if (resti.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('kehamilan')
              .doc(widget.data['kehamilanId'])
              .update({'resti': FieldValue.arrayUnion(resti)});
        }
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan')));
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.homepage,
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal simpan: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hasil Kunjungan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Subjective",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildRow("Keluhan", widget.data['keluhan'] ?? ""),
              const SizedBox(height: 16),
              const Text(
                "Objective",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildRow("Berat Badan", widget.data['bb'] ?? "", suffix: 'kg'),
              _buildRow(
                "Lingkar Lengan Atas (LILA)",
                widget.data['lila'] ?? "",
                suffix: 'cm',
              ),
              _buildRow("Lingkar Perut", widget.data['lp'] ?? "", suffix: 'cm'),
              _buildRow(
                "Tekanan Darah",
                widget.data['td'] ?? "",
                suffix: 'mmHg',
              ),
              _buildRow("Tinggi Fundus Uteri (TFU)", widget.data['tfu'] ?? ""),
              const SizedBox(height: 16),
              const Text(
                "Analysis",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildRow(
                "Usia Kandungan",
                widget.data['uk'] ?? "",
                suffix: 'minggu',
              ),
              const SizedBox(height: 16),
              const Text(
                "Planning",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildRow("Planning", widget.data['planning'] ?? ""),
              _buildRow("Status Kunjungan", widget.data['status'] ?? ""),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveData,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(_isLoading ? 'Menyimpan...' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
