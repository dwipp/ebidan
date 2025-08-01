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

  // Text Controllers
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

  Future<List<Map<String, dynamic>>> _searchPuskesmas(String query) async {
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
    if (_formKey.currentState!.validate() && _selectedPuskesmasRef != null) {
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bidan berhasil diregistrasi')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi Bidan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _nipController,
                decoration: const InputDecoration(labelText: 'NIP'),
              ),
              TextFormField(
                controller: _noHpController,
                decoration: const InputDecoration(labelText: 'No HP'),
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
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: ['bidan', 'admin'].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (val) => setState(() => _role = val!),
              ),
              const SizedBox(height: 16),
              Autocomplete<Map<String, dynamic>>(
                displayStringForOption: (option) => option['nama'],
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text == '')
                    return const Iterable.empty();
                  return _searchPuskesmas(textEditingValue.text);
                },
                onSelected: (option) {
                  setState(() {
                    _selectedPuskesmasName = option['nama'];
                    _selectedPuskesmasRef = option['ref'];
                  });
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Puskesmas',
                        ),
                        validator: (_) => _selectedPuskesmasRef == null
                            ? 'Pilih puskesmas'
                            : null,
                      );
                    },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _desaController,
                decoration: const InputDecoration(labelText: 'Desa'),
              ),
              TextFormField(
                controller: _kecamatanController,
                decoration: const InputDecoration(labelText: 'Kecamatan'),
              ),
              TextFormField(
                controller: _kabupatenController,
                decoration: const InputDecoration(labelText: 'Kabupaten'),
              ),
              TextFormField(
                controller: _provinsiController,
                decoration: const InputDecoration(labelText: 'Provinsi'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Daftarkan Bidan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
