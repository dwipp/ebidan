import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  // Controllers
  final _namaController = TextEditingController();
  final _nipController = TextEditingController();
  final _noHpController = TextEditingController();
  final _desaController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _kabupatenController = TextEditingController();
  final _provinsiController = TextEditingController();

  // Dropdown & Autocomplete
  String _role = 'bidan';
  String? _selectedPuskesmasName;
  DocumentReference? _selectedPuskesmasRef;

  bool _isSubmitting = false;

  Future<List<Map<String, dynamic>>> _searchPuskesmas(String query) async {
    if (query.isEmpty) return [];
    final snap = await _firestore
        .collection('puskesmas')
        .where('nama', isGreaterThanOrEqualTo: query)
        .where('nama', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    return snap.docs
        .map((doc) => {'nama': doc['nama'], 'ref': doc.reference})
        .toList();
  }

  Future<void> _submitForm() async {
    // if (!_formKey.currentState!.validate() || _selectedPuskesmasRef == null) {
    //   return;
    // }
    setState(() => _isSubmitting = true);

    await _firestore.collection('bidan').add({
      'nama': _namaController.text,
      'nip': _nipController.text,
      'no_hp': _noHpController.text,
      'role': _role,
      'created_at': FieldValue.serverTimestamp(),
      'puskesmas': _selectedPuskesmasName,
      'id_puskesmas': _selectedPuskesmasRef,
      'wilayah': {
        'desa': _desaController.text,
        'kecamatan': _kecamatanController.text,
        'kabupaten': _kabupatenController.text,
        'provinsi': _provinsiController.text,
      },
    });

    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sukses'),
        content: const Text('Bidan berhasil diregistrasi'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi Bidan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Data Pribadi'),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nipController,
                decoration: const InputDecoration(
                  labelText: 'NIP',
                  prefixIcon: Icon(Icons.badge),
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
                validator: (val) {
                  final hp = val?.trim();
                  final pattern = RegExp(r'^(\+62|62|0)8[1-9][0-9]{7,11}$');
                  if (hp == null || hp.isEmpty) {
                    return 'Wajib diisi';
                  } else if (!pattern.hasMatch(hp)) {
                    return 'Format no HP tidak valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('Role'),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.assignment_ind),
                ),
                items: ['bidan', 'admin'].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (val) => setState(() => _role = val!),
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('Puskesmas'),
              Autocomplete<Map<String, dynamic>>(
                displayStringForOption: (option) => option['nama'],
                optionsBuilder: (textEditingValue) async {
                  return await _searchPuskesmas(textEditingValue.text);
                },
                onSelected: (option) {
                  setState(() {
                    _selectedPuskesmasName = option['nama'];
                    _selectedPuskesmasRef = option['ref'];
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, _) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Cari Puskesmas',
                      prefixIcon: Icon(Icons.local_hospital),
                    ),
                    validator: (_) => _selectedPuskesmasRef == null
                        ? 'Pilih puskesmas'
                        : null,
                  );
                },
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('Wilayah'),
              TextFormField(
                controller: _desaController,
                decoration: const InputDecoration(labelText: 'Desa'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kecamatanController,
                decoration: const InputDecoration(labelText: 'Kecamatan'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kabupatenController,
                decoration: const InputDecoration(labelText: 'Kabupaten'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _provinsiController,
                decoration: const InputDecoration(labelText: 'Provinsi'),
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
                    _isSubmitting ? 'Menyimpan...' : 'Daftarkan Bidan',
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
      ),
    );
  }
}
