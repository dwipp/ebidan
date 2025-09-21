import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CheckBumilScreen extends StatefulWidget {
  const CheckBumilScreen({Key? key}) : super(key: key);

  @override
  State<CheckBumilScreen> createState() => _CheckBumilScreenState();
}

class _CheckBumilScreenState extends State<CheckBumilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nikController.dispose();
    super.dispose();
  }

  String? _validateNIK(String? val) {
    if (val == null || val.isEmpty) return 'Wajib diisi';
    if (!RegExp(r'^\d{16}$').hasMatch(val)) return 'Harus 16 digit angka';
    return null;
  }

  Future<void> _checkNIK() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    final firestore = FirebaseFirestore.instance;

    try {
      final snapshot = await firestore
          .collection('bumil')
          .where('id_bidan', isEqualTo: userId)
          .where('nik_ibu', isEqualTo: _nikController.text.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // tampilkan nama bumil
        // beri 1 tombol untuk masuk ke halaman add kehamilan
        // sudah terdaftar → masuk ke Padd kehamilan
        Navigator.pushReplacementNamed(context, AppRouter.addKehamilan);
      } else {
        // belum terdaftar → masuk ke tambah pasien baru
        Navigator.pushReplacementNamed(context, AppRouter.addBumil);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cek Pasien')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan NIK Ibu untuk pengecekan:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'NIK Ibu',
                icon: Icons.badge,
                controller: _nikController,
                isNumber: true,
                maxLength: 16,
                validator: _validateNIK,
              ),
              const SizedBox(height: 24),
              Button(
                isSubmitting: _isLoading,
                onPressed: _checkNIK,
                label: 'Cek Pasien',
                loadingLabel: 'Memeriksa...',
                icon: Icons.search,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
