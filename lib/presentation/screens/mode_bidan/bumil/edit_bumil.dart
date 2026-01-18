import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/date_picker_field.dart';
import 'package:ebidan/presentation/widgets/dropdown_field.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/submit_bumil_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import FormValidator
import 'package:ebidan/common/utility/form_validator.dart';

class EditBumilScreen extends StatefulWidget {
  final Bumil bumil;
  const EditBumilScreen({Key? key, required this.bumil}) : super(key: key);

  @override
  State<EditBumilScreen> createState() => _EditBumilState();
}

class _EditBumilState extends State<EditBumilScreen> {
  final _formKey = GlobalKey<FormState>();

  // **PERUBAHAN 1: Definisikan GlobalKey untuk setiap field wajib**
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

  // **PERUBAHAN 2: Deklarasi FormValidator**
  late FormValidator _formValidator;

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

  // **Definisi validator sederhana untuk di-wrap**
  String? _requiredValidator(dynamic val) {
    if (val is String) {
      return val.isEmpty ? 'Wajib diisi' : null;
    }
    return val == null ? 'Wajib diisi' : null;
  }

  String? _validateNIK(dynamic val) {
    if (val == null || val.isEmpty) return 'Wajib diisi';
    if (!RegExp(r'^\d{16}$').hasMatch(val)) return 'Harus 16 digit angka';
    return null;
  }

  String? _validateKK(String? val) {
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
  void initState() {
    // **PERUBAHAN 3: Inisialisasi FormValidator**
    _formValidator = FormValidator(fieldKeys: _fieldKeys);

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
    // **PERUBAHAN 4: Ganti validasi manual dengan validateAndScroll**
    _formValidator.reset();

    if (!_formValidator.validateAndScroll(_formKey, context)) {
      // FormValidator sudah menangani scroll dan snackbar.
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
      idBumil: widget.bumil.idBumil,
      idBidan: widget.bumil.idBidan,
      createdAt: widget.bumil.createdAt,
    );

    context.read<SubmitBumilCubit>().submitBumil(bumil);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title: Text('Perbaharui Data Bumil')),
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
                    key: _fieldKeys['namaIbu'], // Tambahkan key
                    label: 'Nama Ibu',
                    icon: Icons.person,
                    controller: _namaIbuController,
                    textCapitalization: TextCapitalization.words,
                    // **PERUBAHAN 5: Wrap validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'namaIbu',
                      val,
                      _requiredValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    key: _fieldKeys['agamaIbu'], // Tambahkan key
                    label: 'Agama Ibu',
                    icon: Icons.account_balance,
                    items: _agamaList,
                    value: _selectedAgamaIbu,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedAgamaIbu = newValue;
                      });
                    },
                    // **Wrap validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'agamaIbu',
                      val,
                      _requiredValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    key: _fieldKeys['golDarahIbu'], // Tambahkan key
                    label: 'Golongan Darah Ibu',
                    icon: Icons.bloodtype,
                    items: _golDarahList,
                    value: _selectedGolIbu,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGolIbu = newValue;
                      });
                    },
                    // Golongan darah tidak wajib, jadi tidak perlu validator
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    key: _fieldKeys['pekerjaanIbu'], // Tambahkan key
                    label: 'Pekerjaan Ibu',
                    icon: Icons.work,
                    controller: _jobIbuController,
                    // **Wrap validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'pekerjaanIbu',
                      val,
                      _requiredValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    key: _fieldKeys['nikIbu'], // Tambahkan key
                    label: 'NIK Ibu',
                    icon: Icons.badge,
                    controller: _nikIbuController,
                    isNumber: true,
                    maxLength: 16,
                    // **Wrap validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'nikIbu',
                      val,
                      _validateNIK,
                    ),
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
                    key: _fieldKeys['pendidikanIbu'], // Tambahkan key
                    label: 'Pendidikan Ibu',
                    icon: Icons.school,
                    items: _pendidikanList,
                    value: _selectedPendidikanIbu,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPendidikanIbu = newValue;
                      });
                    },
                    // **Wrap validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'pendidikanIbu',
                      val,
                      _requiredValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DatePickerFormField(
                    key: _fieldKeys['tanggalLahirIbu'], // Tambahkan key
                    labelText: 'Tanggal Lahir Ibu',
                    prefixIcon: Icons.calendar_today,
                    value: _birthdateIbu,
                    initialDate: DateTime(DateTime.now().year - 20),
                    context: context,
                    onDateSelected: (date) {
                      setState(() {
                        _birthdateIbu = date;
                      });
                    },
                    // **Wrap validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'tanggalLahirIbu',
                      val,
                      _requiredValidator,
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionTitle('Data Suami'),
                  CustomTextField(
                    key: _fieldKeys['namaSuami'], // Tambahkan key
                    label: 'Nama Suami',
                    icon: Icons.person,
                    controller: _namaSuamiController,
                    textCapitalization: TextCapitalization.words,
                    // **Wrap validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'namaSuami',
                      val,
                      _requiredValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    key: _fieldKeys['agamaSuami'], // Tambahkan key
                    label: 'Agama Suami',
                    icon: Icons.account_balance,
                    items: _agamaList,
                    value: _selectedAgamaSuami,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedAgamaSuami = newValue;
                      });
                    },
                    // **Wrap validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'agamaSuami',
                      val,
                      _requiredValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    key: _fieldKeys['golDarahSuami'], // Tambahkan key
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
                    key: _fieldKeys['pekerjaanSuami'], // Tambahkan key
                    label: 'Pekerjaan Suami',
                    icon: Icons.work,
                    controller: _jobSuamiController,
                    // **Wrap validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'pekerjaanSuami',
                      val,
                      _requiredValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    key: _fieldKeys['nikSuami'], // Tambahkan key
                    label: 'NIK Suami',
                    icon: Icons.badge,
                    controller: _nikSuamiController,
                    isNumber: true,
                    maxLength: 16,
                    // **Wrap validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'nikSuami',
                      val,
                      _validateNIK,
                    ),
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
                    key: _fieldKeys['pendidikanSuami'], // Tambahkan key
                    label: 'Pendidikan Suami',
                    icon: Icons.school,
                    items: _pendidikanList,
                    value: _selectedPendidikanSuami,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPendidikanSuami = newValue;
                      });
                    },
                    // **Wrap validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'pendidikanSuami',
                      val,
                      _requiredValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DatePickerFormField(
                    key: _fieldKeys['tanggalLahirSuami'], // Tambahkan key
                    labelText: 'Tanggal Lahir Suami',
                    prefixIcon: Icons.calendar_today,
                    value: _birthdateSuami,
                    initialDate: DateTime(DateTime.now().year - 20),
                    context: context,
                    onDateSelected: (date) {
                      setState(() {
                        _birthdateSuami = date;
                      });
                    },
                    // **Wrap validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'tanggalLahirSuami',
                      val,
                      _requiredValidator,
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionTitle('Data Lain'),
                  CustomTextField(
                    key: _fieldKeys['alamat'], // Tambahkan key
                    label: 'Alamat',
                    icon: Icons.home,
                    controller: _alamatController,
                    // **Wrap validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'alamat',
                      val,
                      _requiredValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    key: _fieldKeys['noHp'], // Tambahkan key
                    label: 'No HP',
                    icon: Icons.phone,
                    controller: _noHpController,
                    keyboardType: TextInputType.phone,
                    // **Wrap validator**
                    validator: (val) =>
                        _formValidator.wrapValidator('noHp', val, _validateHP),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: BlocConsumer<SubmitBumilCubit, SubmitBumilState>(
                      listener: (context, state) {
                        if (state.isSuccess && state.bumilId != null) {
                          Snackbar.show(
                            context,
                            message: 'Data Bumil berhasil diperbaharui',
                            type: SnackbarType.success,
                          );
                          Navigator.pop(context);
                        }
                        if (state.error != null) {
                          Snackbar.show(
                            context,
                            message: 'Gagal menyimpan data: ${state.error}',
                            type: SnackbarType.error,
                          );
                        }
                      },
                      builder: (context, state) {
                        final isSubmitting = state.isSubmitting;
                        return Button(
                          isSubmitting: isSubmitting,
                          onPressed: _submitForm,
                          label: 'Perbaharui',
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
