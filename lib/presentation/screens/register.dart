import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  // Controllers
  final _namaController = TextEditingController();
  final _nipController = TextEditingController();
  final _noHpController = TextEditingController();
  final _emailController = TextEditingController();
  final _desaController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _kabupatenController = TextEditingController();
  final _provinsiController = TextEditingController();

  // Dropdown & Autocomplete
  String _role = 'bidan';
  String? _selectedPuskesmasName;
  DocumentReference? _selectedPuskesmasRef;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Prefill dari user Google
    if (user != null) {
      _namaController.text = user!.displayName ?? '';
      _noHpController.text = user!.phoneNumber ?? '';
      _emailController.text = user!.email ?? '';
    }
  }

  Future<List<Map<String, dynamic>>> _searchPuskesmas(String query) async {
    if (query.isEmpty) return [];
    final kataKunci = query
        .toLowerCase()
        .split(' ')
        .where((kata) => kata.trim().isNotEmpty)
        .toList();
    // print("query: $kataKunci");
    final snapshot = await FirebaseFirestore.instance
        .collection('puskesmas')
        .where('search', arrayContainsAny: kataKunci)
        .get();
    // print('result: ${snapshot.docs}');
    return snapshot.docs
        .map((doc) => {'nama': doc['nama'], 'ref': doc.reference})
        .toList();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedPuskesmasRef == null) {
      return;
    }
    if (user == null) {
      return;
    }
    setState(() => _isSubmitting = true);

    await _firestore.collection('bidan').doc(user!.uid).set({
      'nama': _namaController.text,
      'nip': _nipController.text,
      'no_hp': _noHpController.text,
      'email': _emailController.text,
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
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRouter.homepage);
            },
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
      appBar: AppBar(
        title: const Text("Registrasi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Kembali ke login screen
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (user?.photoURL != null)
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user!.photoURL!),
                  ),
                const SizedBox(height: 12),
              ],
            ),
            Form(
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true,
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
          ],
        ),
      ),
    );
  }
}
