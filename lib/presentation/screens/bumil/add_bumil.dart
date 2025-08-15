import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBumilScreen extends StatefulWidget {
  const AddBumilScreen({Key? key}) : super(key: key);

  @override
  State<AddBumilScreen> createState() => _AddBumilState();
}

class _AddBumilState extends State<AddBumilScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controllers
  final _namaIbuController = TextEditingController();
  final _namaSuamiController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();
  final _agamaIbuController = TextEditingController();
  final _agamaSuamiController = TextEditingController();
  final _bloodIbuController = TextEditingController();
  final _bloodSuamiController = TextEditingController();
  final _jobIbuController = TextEditingController();
  final _jobSuamiController = TextEditingController();
  final _nikIbuController = TextEditingController();
  final _nikSuamiController = TextEditingController();
  final _kkIbuController = TextEditingController();
  final _kkSuamiController = TextEditingController();
  final _pendidikanIbuController = TextEditingController();
  final _pendidikanSuamiController = TextEditingController();
  final _kabupatenController = TextEditingController();
  final _kecamatanController = TextEditingController();

  DateTime? _birthdateIbu;
  DateTime? _birthdateSuami;

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _pickDate(bool isIbu) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isIbu) {
          _birthdateIbu = picked;
        } else {
          _birthdateSuami = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('bumil').add({
        "nama_ibu": _namaIbuController.text.trim(),
        "nama_suami": _namaSuamiController.text.trim(),
        "alamat": _alamatController.text.trim(),
        "no_hp": _noHpController.text.trim(),
        "agama_ibu": _agamaIbuController.text.trim(),
        "agama_suami": _agamaSuamiController.text.trim(),
        "blood_ibu": _bloodIbuController.text.trim(),
        "blood_suami": _bloodSuamiController.text.trim(),
        "job_ibu": _jobIbuController.text.trim(),
        "job_suami": _jobSuamiController.text.trim(),
        "nik_ibu": _nikIbuController.text.trim(),
        "nik_suami": _nikSuamiController.text.trim(),
        "kk_ibu": _kkIbuController.text.trim(),
        "kk_suami": _kkSuamiController.text.trim(),
        "pendidikan_ibu": _pendidikanIbuController.text.trim(),
        "pendidikan_suami": _pendidikanSuamiController.text.trim(),
        "kabupaten": _kabupatenController.text.trim(),
        "kecamatan": _kecamatanController.text.trim(),
        "id_bidan": user.uid,
        "birthdate_ibu": _birthdateIbu,
        "birthdate_suami": _birthdateSuami,
        "created_at": DateTime.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data Bumil berhasil disimpan')),
        );
        // Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Data Bumil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Data Ibu'),
                  TextFormField(
                    controller: _namaIbuController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Ibu',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _agamaIbuController,
                    decoration: const InputDecoration(
                      labelText: 'Agama Ibu',
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bloodIbuController,
                    decoration: const InputDecoration(
                      labelText: 'Golongan Darah Ibu',
                      prefixIcon: Icon(Icons.bloodtype),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _jobIbuController,
                    decoration: const InputDecoration(
                      labelText: 'Pekerjaan Ibu',
                      prefixIcon: Icon(Icons.work),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nikIbuController,
                    decoration: const InputDecoration(
                      labelText: 'NIK Ibu',
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _kkIbuController,
                    decoration: const InputDecoration(
                      labelText: 'KK Ibu',
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pendidikanIbuController,
                    decoration: const InputDecoration(
                      labelText: 'Pendidikan Ibu',
                      prefixIcon: Icon(Icons.school),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _pickDate(true),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _birthdateIbu == null
                          ? "Pilih Tanggal Lahir Ibu"
                          : "Ibu: ${_birthdateIbu!.day}/${_birthdateIbu!.month}/${_birthdateIbu!.year}",
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionTitle('Data Suami'),
                  TextFormField(
                    controller: _namaSuamiController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Suami',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _agamaSuamiController,
                    decoration: const InputDecoration(
                      labelText: 'Agama Suami',
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bloodSuamiController,
                    decoration: const InputDecoration(
                      labelText: 'Golongan Darah Suami',
                      prefixIcon: Icon(Icons.bloodtype),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _jobSuamiController,
                    decoration: const InputDecoration(
                      labelText: 'Pekerjaan Suami',
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nikSuamiController,
                    decoration: const InputDecoration(
                      labelText: 'NIK Suami',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _kkSuamiController,
                    decoration: const InputDecoration(
                      labelText: 'KK Suami',
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pendidikanSuamiController,
                    decoration: const InputDecoration(
                      labelText: 'Pendidikan Suami',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _pickDate(false),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _birthdateSuami == null
                          ? "Pilih Tanggal Lahir Suami"
                          : "Suami: ${_birthdateSuami!.day}/${_birthdateSuami!.month}/${_birthdateSuami!.year}",
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionTitle('Data Lain'),
                  TextFormField(
                    controller: _alamatController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat',
                      prefixIcon: Icon(Icons.home),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noHpController,
                    decoration: const InputDecoration(
                      labelText: 'No HP',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _kabupatenController,
                    decoration: const InputDecoration(
                      labelText: 'Kabupaten',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _kecamatanController,
                    decoration: const InputDecoration(
                      labelText: 'Kecamatan',
                      prefixIcon: Icon(Icons.map),
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitForm,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(
                        _isSubmitting ? 'Menyimpan...' : 'Simpan Data Bumil',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
