import 'package:ebidan/common/date_picker_field.dart';
import 'package:ebidan/presentation/router/app_router.dart';
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

  // Tambah di atas (list pilihan dropdown)
  final List<String> _agamaList = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
  ];
  final List<String> _golDarahList = ['A', 'B', 'AB', 'O'];

  String? _selectedAgamaIbu;
  String? _selectedAgamaSuami;
  String? _selectedGolIbu;
  String? _selectedGolSuami;

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  String? _validateNIK(String? val) {
    if (val == null || val.isEmpty) return 'Wajib diisi';
    if (!RegExp(r'^\d{16}$').hasMatch(val)) return 'Harus 16 digit angka';
    return null;
  }

  String? _validateKK(String? val) {
    if (val == null || val.isEmpty) return 'Wajib diisi';
    if (!RegExp(r'^\d{16}$').hasMatch(val)) return 'Harus 16 digit angka';
    return null;
  }

  String? _validateHP(String? val) {
    if (val == null || val.isEmpty) return 'Wajib diisi';
    if (!RegExp(r'^\d{10,15}$').hasMatch(val)) return 'Nomor HP tidak valid';
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      final docRef = await FirebaseFirestore.instance.collection('bumil').add({
        "nama_ibu": _namaIbuController.text.trim(),
        "nama_suami": _namaSuamiController.text.trim(),
        "alamat": _alamatController.text.trim(),
        "no_hp": _noHpController.text.trim(),
        "agama_ibu": _selectedAgamaIbu,
        "agama_suami": _selectedAgamaSuami,
        "blood_ibu": _selectedGolIbu,
        "blood_suami": _selectedGolSuami,
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

        Navigator.pushReplacementNamed(
          context,
          AppRouter.riwayatBumil,
          arguments: {'bumilId': docRef.id},
        );
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
      appBar: AppBar(
        title: const Text("Tambah Data Bumil"),
        automaticallyImplyLeading: false,
      ),
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
                    textCapitalization: TextCapitalization.words,
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedAgamaIbu,
                    decoration: const InputDecoration(
                      labelText: 'Agama Ibu',
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    items: _agamaList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedAgamaIbu = newValue;
                      });
                    },
                    validator: (val) => val == null ? 'Wajib dipilih' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedGolIbu,
                    decoration: const InputDecoration(
                      labelText: 'Golongan Darah Ibu',
                      prefixIcon: Icon(Icons.bloodtype),
                    ),
                    items: _golDarahList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGolIbu = newValue;
                      });
                    },
                    validator: (val) => val == null ? 'Wajib dipilih' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _jobIbuController,
                    decoration: const InputDecoration(
                      labelText: 'Pekerjaan Ibu',
                      prefixIcon: Icon(Icons.work),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nikIbuController,
                    decoration: const InputDecoration(
                      labelText: 'NIK Ibu',
                      prefixIcon: Icon(Icons.badge),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateNIK,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _kkIbuController,
                    decoration: const InputDecoration(
                      labelText: 'KK Ibu',
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateKK,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pendidikanIbuController,
                    decoration: const InputDecoration(
                      labelText: 'Pendidikan Ibu',
                      prefixIcon: Icon(Icons.school),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  DatePickerFormField(
                    labelText: 'Tanggal Lahir Ibu',
                    prefixIcon: Icons.calendar_today,
                    initialValue: _birthdateIbu,
                    context: context,
                    onDateSelected: (date) {
                      setState(() {
                        _birthdateIbu = date;
                      });
                    },
                    validator: (val) => val == null ? 'Wajib diisi' : null,
                  ),

                  const SizedBox(height: 16),
                  _buildSectionTitle('Data Suami'),
                  TextFormField(
                    controller: _namaSuamiController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Suami',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedAgamaSuami,
                    decoration: const InputDecoration(
                      labelText: 'Agama Suami',
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    items: _agamaList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedAgamaSuami = newValue;
                      });
                    },
                    validator: (val) => val == null ? 'Wajib dipilih' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedGolSuami,
                    decoration: const InputDecoration(
                      labelText: 'Golongan Darah Suami',
                      prefixIcon: Icon(Icons.bloodtype),
                    ),
                    items: _golDarahList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGolSuami = newValue;
                      });
                    },
                    validator: (val) => val == null ? 'Wajib dipilih' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _jobSuamiController,
                    decoration: const InputDecoration(
                      labelText: 'Pekerjaan Suami',
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nikSuamiController,
                    decoration: const InputDecoration(
                      labelText: 'NIK Suami',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateNIK,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _kkSuamiController,
                    decoration: const InputDecoration(
                      labelText: 'KK Suami',
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateKK,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pendidikanSuamiController,
                    decoration: const InputDecoration(
                      labelText: 'Pendidikan Suami',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  DatePickerFormField(
                    labelText: 'Tanggal Lahir Suami',
                    prefixIcon: Icons.calendar_today,
                    initialValue: _birthdateSuami,
                    context: context,
                    onDateSelected: (date) {
                      setState(() {
                        _birthdateSuami = date;
                      });
                    },
                    validator: (val) => val == null ? 'Wajib diisi' : null,
                  ),

                  const SizedBox(height: 16),
                  _buildSectionTitle('Data Lain'),
                  TextFormField(
                    controller: _alamatController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat',
                      prefixIcon: Icon(Icons.home),
                    ),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noHpController,
                    decoration: const InputDecoration(
                      labelText: 'No HP',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: _validateHP,
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
