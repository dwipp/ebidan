import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/date_picker_field.dart';
import 'package:ebidan/presentation/widgets/dropdown_field.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/state_management/bumil/cubit/submit_bumil_cubit.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditBumilScreen extends StatefulWidget {
  final Bumil bumil;
  const EditBumilScreen({Key? key, required this.bumil}) : super(key: key);

  @override
  State<EditBumilScreen> createState() => _EditBumilState();
}

class _EditBumilState extends State<EditBumilScreen> {
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

  final List<String> _pendidikanList = [
    'Tidak Sekolah',
    'SD',
    'SMP',
    'SMA',
    'S1',
    'S2',
    'S3',
  ];

  final List<String> _golDarahList = ['A', 'B', 'AB', 'O', '-'];

  String? _selectedPendidikanIbu;
  String? _selectedPendidikanSuami;
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

  @override
  void initState() {
    context.read<SubmitBumilCubit>().setInitial();
    _namaIbuController.text = widget.bumil.namaIbu;
    _namaSuamiController.text = widget.bumil.namaSuami;
    _alamatController.text = widget.bumil.alamat;
    _noHpController.text = widget.bumil.noHp;
    _selectedAgamaIbu = widget.bumil.agamaIbu;
    _selectedAgamaSuami = widget.bumil.agamaSuami;
    _selectedGolIbu = widget.bumil.bloodIbu;
    _selectedGolSuami = widget.bumil.bloodSuami;
    _jobIbuController.text = widget.bumil.jobIbu;
    _jobSuamiController.text = widget.bumil.jobSuami;
    _nikIbuController.text = widget.bumil.nikIbu;
    _nikSuamiController.text = widget.bumil.nikSuami;
    _kkIbuController.text = widget.bumil.kkIbu;
    _kkSuamiController.text = widget.bumil.kkSuami;
    _selectedPendidikanIbu = widget.bumil.pendidikanIbu;
    _selectedPendidikanSuami = widget.bumil.pendidikanSuami;
    _birthdateIbu = widget.bumil.birthdateIbu;
    _birthdateSuami = widget.bumil.birthdateSuami;

    super.initState();
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
      pendidikanIbu: _selectedPendidikanIbu!,
      pendidikanSuami: _selectedPendidikanSuami!,
      birthdateIbu: _birthdateIbu!,
      birthdateSuami: _birthdateSuami!,
      idBumil: widget.bumil.idBumil,
      idBidan: widget.bumil.idBidan,
      createdAt: widget.bumil.createdAt,
    );

    context.read<SubmitBumilCubit>().submitBumil(bumil);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title: 'Perbaharui Data Bumil'),
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
                  CustomTextField(
                    label: 'Nama Ibu',
                    icon: Icons.person,
                    controller: _namaIbuController,
                    textCapitalization: TextCapitalization.words,
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    label: 'Agama Ibu',
                    icon: Icons.account_balance,
                    items: _agamaList,
                    value: _selectedAgamaIbu,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedAgamaIbu = newValue;
                      });
                    },
                    validator: (val) => val == null ? 'Wajib dipilih' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    label: 'Golongan Darah Ibu',
                    icon: Icons.bloodtype,
                    items: _golDarahList,
                    value: _selectedGolIbu,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGolIbu = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Pekerjaan Ibu',
                    icon: Icons.work,
                    controller: _jobIbuController,
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'NIK Ibu',
                    icon: Icons.badge,
                    controller: _nikIbuController,
                    isNumber: true,
                    maxLength: 16,
                    validator: _validateNIK,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'KK Ibu',
                    icon: Icons.credit_card,
                    controller: _kkIbuController,
                    isNumber: true,
                    maxLength: 16,
                    validator: _validateKK,
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    label: 'Pendidikan Ibu',
                    icon: Icons.school,
                    items: _pendidikanList,
                    value: _selectedPendidikanIbu,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPendidikanIbu = newValue;
                      });
                    },
                    validator: (val) => val == null ? 'Wajib dipilih' : null,
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
                  CustomTextField(
                    label: 'Nama Suami',
                    icon: Icons.person,
                    controller: _namaSuamiController,
                    textCapitalization: TextCapitalization.words,
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    label: 'Agama Suami',
                    icon: Icons.account_balance,
                    items: _agamaList,
                    value: _selectedAgamaSuami,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedAgamaSuami = newValue;
                      });
                    },
                    validator: (val) => val == null ? 'Wajib dipilih' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    label: 'Golongan Darah Suami',
                    icon: Icons.bloodtype,
                    items: _golDarahList,
                    value: _selectedGolSuami,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGolSuami = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Pekerjaan Suami',
                    icon: Icons.work,
                    controller: _jobSuamiController,
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'NIK Suami',
                    icon: Icons.badge,
                    controller: _nikSuamiController,
                    isNumber: true,
                    maxLength: 16,
                    validator: _validateNIK,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'KK Suami',
                    icon: Icons.credit_card,
                    controller: _kkSuamiController,
                    isNumber: true,
                    maxLength: 16,
                    validator: _validateKK,
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    label: 'Pendidikan Suami',
                    icon: Icons.school,
                    items: _pendidikanList,
                    value: _selectedPendidikanSuami,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPendidikanSuami = newValue;
                      });
                    },
                    validator: (val) => val == null ? 'Wajib dipilih' : null,
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
                  CustomTextField(
                    label: 'Alamat',
                    icon: Icons.home,
                    controller: _alamatController,
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'No HP',
                    icon: Icons.phone,
                    controller: _noHpController,
                    keyboardType: TextInputType.phone,
                    validator: _validateHP,
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: BlocConsumer<SubmitBumilCubit, SubmitBumilState>(
                      listener: (context, state) {
                        if (state.isSuccess && state.bumilId != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data Bumil berhasil diperbaharui'),
                            ),
                          );
                          Navigator.pop(context);
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
                        return Button(
                          isSubmitting: isSubmitting,
                          onPressed: _submitForm,
                          label: 'perbaharui',
                          loadingLabel: 'Menyimpan...',
                          icon: Icons.check,
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
