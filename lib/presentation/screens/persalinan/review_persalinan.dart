import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/logic/utility/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';

class ReviewPersalinanScreen extends StatefulWidget {
  final Map<String, Object?> data;

  const ReviewPersalinanScreen({super.key, required this.data});

  @override
  State<ReviewPersalinanScreen> createState() => _ReviewPersalinanScreenState();
}

class _ReviewPersalinanScreenState extends State<ReviewPersalinanScreen> {
  bool _isLoading = false;

  Future<void> _saveData() async {
    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('kehamilan')
          .doc(widget.data['kehamilanId'] as String)
          .collection('persalinan')
          .add({
            'berat_lahir': widget.data['berat_lahir'],
            'cara': widget.data['cara'],
            'lingkar_kepala': widget.data['lingkar_kepala'],
            'panjang_badan': widget.data['panjang_badan'],
            'penolong': widget.data['penolong'],
            'sex': widget.data['sex'],
            'tempat': widget.data['tempat'],
            'tgl_persalinan': widget.data['tgl_persalinan'],
            'umur_kehamilan': widget.data['umur_kehamilan'],
            'created_at': DateTime.now(),
          });

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
                "Detail Kelahiran",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                "Tanggal Persalinan",
                Utils.formattedDate(widget.data['tgl_persalinan'] as DateTime),
              ),
              Utils.generateRowLabelValue(
                "Berat Lahir",
                widget.data['berat_lahir'] as String,
                suffix: 'gram',
              ),
              Utils.generateRowLabelValue(
                "Panjang Badan",
                widget.data['panjang_badan'] as String,
                suffix: 'cm',
              ),
              Utils.generateRowLabelValue(
                "Lingkar Kepala",
                widget.data['lignkar_kepala'] as String,
                suffix: 'cm',
              ),
              Utils.generateRowLabelValue(
                "Umur Kehamilan",
                widget.data['umur_kehamilan'] as String,
                suffix: 'minggu',
              ),
              const SizedBox(height: 16),
              const Text(
                "Kondisi Kelahiran",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                "Jenis Kelamin",
                widget.data['sex'] as String,
              ),
              Utils.generateRowLabelValue(
                "Cara Lahir",
                widget.data['cara'] as String,
              ),
              Utils.generateRowLabelValue(
                "Penolong",
                widget.data['penolong'] as String,
              ),
              Utils.generateRowLabelValue(
                "Penolong",
                widget.data['penolong'] as String,
              ),
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
