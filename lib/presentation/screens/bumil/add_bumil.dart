import 'package:ebidan/common/date_picker_field.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/logic/general/cubit/add_bumil_cubit.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddBumilScreen extends StatefulWidget {
  const AddBumilScreen({Key? key}) : super(key: key);

  @override
  State<AddBumilScreen> createState() => _AddBumilState();
}

class _AddBumilState extends State<AddBumilScreen> {
  final _formKey = GlobalKey<FormState>();

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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final bumil = Bumil(
      namaIbu: _namaIbuController.text.trim(),
      namaSuami: _namaSuamiController.text.trim(),
      alamat: _alamatController.text.trim(),
      noHp: _noHpController.text.trim(),
      agamaIbu: _selectedAgamaIbu!,
      agamaSuami: _selectedAgamaSuami!,
      bloodIbu: _selectedGolIbu!,
      bloodSuami: _selectedGolSuami!,
      jobIbu: _jobIbuController.text.trim(),
      jobSuami: _jobSuamiController.text.trim(),
      nikIbu: _nikIbuController.text.trim(),
      nikSuami: _nikSuamiController.text.trim(),
      kkIbu: _kkIbuController.text.trim(),
      kkSuami: _kkSuamiController.text.trim(),
      pendidikanIbu: _pendidikanIbuController.text.trim(),
      pendidikanSuami: _pendidikanSuamiController.text.trim(),
      birthdateIbu: _birthdateIbu!,
      birthdateSuami: _birthdateSuami!,
      idBumil: '',
      idBidan: '',
      createdAt: DateTime.now(),
    );

    context.read<AddBumilCubit>().submitBumil(bumil);
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
                    initialDate: DateTime(1990),
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
                    initialDate: DateTime(1990),
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

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: BlocConsumer<AddBumilCubit, AddBumilState>(
                      listener: (context, state) {
                        if (state.isSuccess && state.bumilId != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data Bumil berhasil disimpan'),
                            ),
                          );
                          Navigator.pushReplacementNamed(
                            context,
                            AppRouter.addRiwayatBumil,
                            arguments: {
                              'bumilId': state.bumilId,
                              'age': (_birthdateIbu != null
                                  ? DateTime.now().year - _birthdateIbu!.year
                                  : 0),
                            },
                          );
                        }
                        if (state.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Gagal menyimpan data: ${state.error}',
                              ),
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        final isSubmitting = state.isSubmitting;
                        return ElevatedButton.icon(
                          onPressed: isSubmitting ? null : _submitForm,
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check),
                          label: Text(
                            isSubmitting ? 'Menyimpan...' : 'Simpan Data Bumil',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        );
                      },
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
