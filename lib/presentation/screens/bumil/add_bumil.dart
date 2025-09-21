import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/date_picker_field.dart';
import 'package:ebidan/presentation/widgets/dropdown_field.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/state_management/bumil/cubit/submit_bumil_cubit.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddBumilScreen extends StatefulWidget {
  final String nikIbu;
  const AddBumilScreen({Key? key, required this.nikIbu}) : super(key: key);

  @override
  State<AddBumilScreen> createState() => _AddBumilState();
}

class _AddBumilState extends State<AddBumilScreen> {
  final _formKey = GlobalKey<FormState>();

  // **Perbaikan Awal: Menyiapkan GlobalKey untuk setiap field wajib**
  GlobalKey? _firstErrorFieldKey;

  final Map<String, GlobalKey> _fieldKeys = {
    // Data Ibu
    'namaIbu': GlobalKey(),
    'agamaIbu': GlobalKey(),
    'golDarahIbu': GlobalKey(),
    'pekerjaanIbu': GlobalKey(),
    'nikIbu': GlobalKey(),
    'pendidikanIbu': GlobalKey(),
    'tanggalLahirIbu': GlobalKey(),
    // Data Suami
    'namaSuami': GlobalKey(),
    'agamaSuami': GlobalKey(),
    'golDarahSuami': GlobalKey(),
    'pekerjaanSuami': GlobalKey(),
    'nikSuami': GlobalKey(),
    'pendidikanSuami': GlobalKey(),
    'tanggalLahirSuami': GlobalKey(),
    // Data Lain
    'alamat': GlobalKey(),
    'noHp': GlobalKey(),
  };

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
    'D3',
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

  // Validator standar untuk wajib diisi
  String? _requiredValidator(dynamic val) {
    if (val is String) {
      return val.isEmpty ? 'Wajib diisi' : null;
    }
    return val == null ? 'Wajib diisi' : null;
  }

  // **Perbaikan B: Fungsi Validator wrapper**
  String? _wrappedValidator(
    String fieldName,
    dynamic value,
    String? Function(dynamic) validator,
  ) {
    final error = validator(value);

    // Jika ada error DAN belum ada field error yang dicatat, catat kunci ini.
    if (error != null && _firstErrorFieldKey == null) {
      _firstErrorFieldKey = _fieldKeys[fieldName];
    }
    return error;
  }

  String? _validateNIK(dynamic val) {
    if (val == null || val.isEmpty) return 'Wajib diisi';
    if (!RegExp(r'^\d{16}$').hasMatch(val)) return 'Harus 16 digit angka';
    return null;
  }

  String? _validateKK(dynamic val) {
    if (val == null || val.isEmpty) return null;
    if (!RegExp(r'^\d{16}$').hasMatch(val)) return 'Harus 16 digit angka';
    return null;
  }

  String? _validateHP(dynamic val) {
    if (val == null || val.isEmpty) return 'Wajib diisi';
    if (!RegExp(r'^\d{10,15}$').hasMatch(val)) return 'Nomor HP tidak valid';
    return null;
  }

  @override
  void initState() {
    context.read<SubmitBumilCubit>().setInitial();
    _nikIbuController.text = widget.nikIbu;
    super.initState();
  }

  void _submitForm() {
    // 1. Reset kunci error sebelum validasi
    _firstErrorFieldKey = null;

    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Periksa field yang belum valid 👆'),
          backgroundColor: Colors.red,
        ),
      );

      // **Perbaikan C: Scroll ke GlobalKey yang dicatat**
      if (_firstErrorFieldKey?.currentContext != null) {
        Scrollable.ensureVisible(
          _firstErrorFieldKey!.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          alignment: 0.1,
        );
      }
      return;
    }

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
      idBumil: '',
      idBidan: '',
      createdAt: DateTime.now(),
    );

    context.read<SubmitBumilCubit>().submitBumil(bumil);
  }

  @override
  void dispose() {
    _namaIbuController.dispose();
    _namaSuamiController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    _jobIbuController.dispose();
    _jobSuamiController.dispose();
    _nikIbuController.dispose();
    _nikSuamiController.dispose();
    _kkIbuController.dispose();
    _kkSuamiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title: 'Tambah Data Bumil'),
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
                    key: _fieldKeys['namaIbu'], // <-- Key ditambahkan
                    label: 'Nama Ibu',
                    icon: Icons.person,
                    controller: _namaIbuController,
                    textCapitalization: TextCapitalization.words,
                    validator: (val) => _wrappedValidator(
                      'namaIbu',
                      val,
                      _requiredValidator,
                    ), // <-- Validator di-wrap
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    key: _fieldKeys['agamaIbu'], // <-- Key ditambahkan
                    label: 'Agama Ibu',
                    icon: Icons.account_balance,
                    items: _agamaList,
                    value: _selectedAgamaIbu,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedAgamaIbu = newValue;
                      });
                    },
                    validator: (val) => _wrappedValidator(
                      'agamaIbu',
                      val,
                      _requiredValidator,
                    ), // <-- Validator di-wrap
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    key: _fieldKeys['golDarahIbu'], // <-- Key ditambahkan
                    label: 'Golongan Darah Ibu',
                    icon: Icons.bloodtype,
                    items: _golDarahList,
                    value: _selectedGolIbu,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGolIbu = newValue;
                      });
                    },
                    validator: (val) => _wrappedValidator(
                      'golDarahIbu',
                      val,
                      _requiredValidator,
                    ), // <-- Validator di-wrap
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    key: _fieldKeys['pekerjaanIbu'], // <-- Key ditambahkan
                    label: 'Pekerjaan Ibu',
                    icon: Icons.work,
                    controller: _jobIbuController,
                    validator: (val) => _wrappedValidator(
                      'pekerjaanIbu',
                      val,
                      _requiredValidator,
                    ), // <-- Validator di-wrap
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    key: _fieldKeys['nikIbu'], // <-- Key ditambahkan
                    label: 'NIK Ibu',
                    icon: Icons.badge,
                    controller: _nikIbuController,
                    isNumber: true,
                    maxLength: 16,
                    validator: (val) => _wrappedValidator(
                      'nikIbu',
                      val,
                      _validateNIK,
                    ), // <-- Validator di-wrap
                  ),
                  const SizedBox(height: 12),
                  // KK Ibu tidak wajib
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
                    key: _fieldKeys['pendidikanIbu'], // <-- Key ditambahkan
                    label: 'Pendidikan Ibu',
                    icon: Icons.school,
                    items: _pendidikanList,
                    value: _selectedPendidikanIbu,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPendidikanIbu = newValue;
                      });
                    },
                    validator: (val) => _wrappedValidator(
                      'pendidikanIbu',
                      val,
                      _requiredValidator,
                    ), // <-- Validator di-wrap
                  ),
                  const SizedBox(height: 12),
                  DatePickerFormField(
                    key: _fieldKeys['tanggalLahirIbu'], // <-- Key ditambahkan
                    labelText: 'Tanggal Lahir Ibu',
                    prefixIcon: Icons.calendar_today,
                    initialValue: _birthdateIbu,
                    initialDate: DateTime(DateTime.now().year - 20),
                    context: context,
                    onDateSelected: (date) {
                      setState(() {
                        _birthdateIbu = date;
                      });
                    },
                    validator: (val) => _wrappedValidator(
                      'tanggalLahirIbu',
                      val,
                      _requiredValidator,
                    ), // <-- Validator di-wrap
                  ),

                  const SizedBox(height: 16),
                  _buildSectionTitle('Data Suami'),
                  CustomTextField(
                    key: _fieldKeys['namaSuami'], // <-- Key ditambahkan
                    label: 'Nama Suami',
                    icon: Icons.person,
                    controller: _namaSuamiController,
                    textCapitalization: TextCapitalization.words,
                    validator: (val) => _wrappedValidator(
                      'namaSuami',
                      val,
                      _requiredValidator,
                    ), // <-- Validator di-wrap
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    key: _fieldKeys['agamaSuami'], // <-- Key ditambahkan
                    label: 'Agama Suami',
                    icon: Icons.account_balance,
                    items: _agamaList,
                    value: _selectedAgamaSuami,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedAgamaSuami = newValue;
                      });
                    },
                    validator: (val) => _wrappedValidator(
                      'agamaSuami',
                      val,
                      _requiredValidator,
                    ), // <-- Validator di-wrap
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    key: _fieldKeys['golDarahSuami'], // <-- Key ditambahkan
                    label: 'Golongan Darah Suami',
                    icon: Icons.bloodtype,
                    items: _golDarahList,
                    value: _selectedGolSuami,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGolSuami = newValue;
                      });
                    },
                    validator: (val) => _wrappedValidator(
                      'golDarahSuami',
                      val,
                      _requiredValidator,
                    ), // <-- Validator di-wrap
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    key: _fieldKeys['pekerjaanSuami'], // <-- Key ditambahkan
                    label: 'Pekerjaan Suami',
                    icon: Icons.work,
                    controller: _jobSuamiController,
                    validator: (val) => _wrappedValidator(
                      'pekerjaanSuami',
                      val,
                      _requiredValidator,
                    ), // <-- Validator di-wrap
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    key: _fieldKeys['nikSuami'], // <-- Key ditambahkan
                    label: 'NIK Suami',
                    icon: Icons.badge,
                    controller: _nikSuamiController,
                    isNumber: true,
                    maxLength: 16,
                    validator: (val) => _wrappedValidator(
                      'nikSuami',
                      val,
                      _validateNIK,
                    ), // <-- Validator di-wrap
                  ),
                  const SizedBox(height: 12),
                  // KK Suami tidak wajib
                  CustomTextField(
                    label: 'KK Suami',
                    icon: Icons.credit_card,
                    controller: _kkSuamiController,
                    isNumber: true,
                    maxLength: 16,
                    validator: _validateKK,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        setState(() {
                          _kkSuamiController.text = _kkIbuController.text;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No KK Suami sama dengan No KK Ibu'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    key: _fieldKeys['pendidikanSuami'], // <-- Key ditambahkan
                    label: 'Pendidikan Suami',
                    icon: Icons.school,
                    items: _pendidikanList,
                    value: _selectedPendidikanSuami,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPendidikanSuami = newValue;
                      });
                    },
                    validator: (val) => _wrappedValidator(
                      'pendidikanSuami',
                      val,
                      _requiredValidator,
                    ), // <-- Validator di-wrap
                  ),
                  const SizedBox(height: 12),
                  DatePickerFormField(
                    key: _fieldKeys['tanggalLahirSuami'], // <-- Key ditambahkan
                    labelText: 'Tanggal Lahir Suami',
                    prefixIcon: Icons.calendar_today,
                    initialValue: _birthdateSuami,
                    initialDate: DateTime(DateTime.now().year - 20),
                    context: context,
                    onDateSelected: (date) {
                      setState(() {
                        _birthdateSuami = date;
                      });
                    },
                    validator: (val) => _wrappedValidator(
                      'tanggalLahirSuami',
                      val,
                      _requiredValidator,
                    ), // <-- Validator di-wrap
                  ),

                  const SizedBox(height: 16),
                  _buildSectionTitle('Data Lain'),
                  CustomTextField(
                    key: _fieldKeys['alamat'], // <-- Key ditambahkan
                    label: 'Alamat',
                    icon: Icons.home,
                    controller: _alamatController,
                    validator: (val) => _wrappedValidator(
                      'alamat',
                      val,
                      _requiredValidator,
                    ), // <-- Validator di-wrap
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    key: _fieldKeys['noHp'], // <-- Key ditambahkan
                    label: 'No HP',
                    icon: Icons.phone,
                    controller: _noHpController,
                    keyboardType: TextInputType.phone,
                    validator: (val) => _wrappedValidator(
                      'noHp',
                      val,
                      _validateHP,
                    ), // <-- Validator di-wrap
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: BlocConsumer<SubmitBumilCubit, SubmitBumilState>(
                      listener: (context, state) {
                        if (state.isSuccess && state.bumilId != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data Bumil berhasil disimpan'),
                            ),
                          );
                          Navigator.pushReplacementNamed(
                            context,
                            AppRouter.addRiwayat,
                            arguments: {'state': 'instantUpdate'},
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
                        return Button(
                          isSubmitting: isSubmitting,
                          onPressed: _submitForm,
                          label: 'Simpan',
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
