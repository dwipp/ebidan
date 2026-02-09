import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/common/exceptions/string.dart';
import 'package:ebidan/data/models/ktp_model.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/date_picker_field.dart';
import 'package:ebidan/presentation/widgets/dropdown_field.dart';
import 'package:ebidan/presentation/widgets/ktp_camera.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/submit_bumil_cubit.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import FormValidator
import 'package:ebidan/common/utility/form_validator.dart';

class AddBumilScreen extends StatefulWidget {
  final bool isFromRegistration;
  AddBumilScreen({super.key, required this.isFromRegistration});

  @override
  State<AddBumilScreen> createState() => _AddBumilState();
}

class _AddBumilState extends State<AddBumilScreen> {
  final _formKey = GlobalKey<FormState>();

  // Definisikan GlobalKey untuk setiap field wajib
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

  // **PERUBAHAN 1: Deklarasi FormValidator**
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

  KtpModel? _ktpIbu;
  KtpModel? _ktpSuami;

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

  // Validator standar untuk string/text (val.isEmpty)
  String? _requiredStringValidator(dynamic val) =>
      val == null || val.isEmpty ? 'Wajib diisi' : null;

  // Validator standar untuk objek/dropdown/datepicker (val == null)
  String? _requiredObjectValidator(dynamic val) =>
      val == null ? 'Wajib dipilih' : null;

  String? _validateNIK(dynamic val) {
    if (val == null || val.isEmpty) return null;
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
    // _nikIbuController.text = _nikIbu;
    populateIbuDataFromKTP();
    _kkIbuController.addListener(() {
      final text = _kkIbuController.text;
      if (_kkSuamiController.text != text) {
        _kkSuamiController.value = _kkSuamiController.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
    // **PERUBAHAN 3: Inisialisasi FormValidator**
    _formValidator = FormValidator(fieldKeys: _fieldKeys);
    super.initState();
  }

  String buildFullAddress({
    String? address,
    String? rt,
    String? rw,
    String? subDistrict,
    String? district,
    String? city,
    String? province,
  }) {
    final parts = <String>[];

    void add(String? value) {
      if (value != null && value.trim().isNotEmpty) {
        parts.add(value.trim());
      }
    }

    add(address);
    if (rt != null || rw != null) {
      final rtRw = [
        if (rt != null && rt.trim().isNotEmpty) 'RT ${rt.trim()}',
        if (rw != null && rw.trim().isNotEmpty) 'RW ${rw.trim()}',
      ].join('/');
      if (rtRw.isNotEmpty) parts.add(rtRw);
    }
    add(subDistrict);
    add(district);
    add(city);
    add(province);

    return parts.join(', ').capitalizeWords();
  }

  void populateIbuDataFromKTP() {
    if (_ktpIbu != null) {
      _namaIbuController.text = (_ktpIbu!.name ?? '').capitalizeWords();

      _alamatController.text = buildFullAddress(
        address: _ktpIbu!.address,
        city: _ktpIbu!.city,
        district: _ktpIbu!.district,
        province: _ktpIbu!.province,
        rt: _ktpIbu!.rt,
        rw: _ktpIbu!.rw,
        subDistrict: _ktpIbu!.subDistrict,
      );
      _jobIbuController.text = (_ktpIbu!.occupation ?? '').capitalizeWords();
      _birthdateIbu = Utils.parseDateKTP(_ktpIbu!.birthDay);
      _selectedAgamaIbu = matchAgama(_ktpIbu!.religion ?? '', _agamaList);
    }
  }

  void populateSuamiDataFromKTP() {
    if (_ktpSuami != null) {
      _nikSuamiController.text = (_ktpSuami!.nik ?? '').capitalizeWords();
      _namaSuamiController.text = (_ktpSuami!.name ?? '').capitalizeWords();
      _jobSuamiController.text = (_ktpSuami!.occupation ?? '')
          .capitalizeWords();
      _birthdateSuami = Utils.parseDateKTP(_ktpSuami!.birthDay);
      _selectedAgamaSuami = matchAgama(_ktpSuami!.religion ?? '', _agamaList);
    }
  }

  String? matchAgama(String agama, List<String> agamaList) {
    final normalized = agama.trim().toLowerCase();
    for (final item in agamaList) {
      if (item.toLowerCase() == normalized) {
        return item; // return sesuai versi list
      }
    }
    return null;
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
      appBar: PageHeader(
        title: Text('Tambah Data Bumil'),
        hideBackButton: widget.isFromRegistration,
        leftButton: !widget.isFromRegistration
            ? null
            : TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'skip',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
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
                  CustomTextField(
                    key: _fieldKeys['nikIbu'],
                    label: 'NIK Ibu',
                    icon: Icons.badge,
                    controller: _nikIbuController,
                    isNumber: true,
                    maxLength: 16,
                    suffixIcon: IconButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KtpCameraScreen(
                              onCaptured: (KtpModel ktp) async {
                                _ktpIbu = ktp;
                                setState(() {
                                  _nikIbuController.text = ktp.nik ?? '';
                                  populateIbuDataFromKTP();
                                });
                              },
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.camera_alt_outlined),
                    ),
                    // **Ganti panggilan validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'nikIbu',
                      val,
                      _validateNIK,
                    ),
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
                  CustomTextField(
                    key: _fieldKeys['namaIbu'],
                    label: 'Nama Ibu',
                    icon: Icons.person,
                    controller: _namaIbuController,
                    textCapitalization: TextCapitalization.words,
                    // **PERUBAHAN 5: Ganti panggilan validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'namaIbu',
                      val,
                      _requiredStringValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    key: _fieldKeys['agamaIbu'],
                    label: 'Agama Ibu',
                    icon: Icons.account_balance,
                    items: _agamaList,
                    value: _selectedAgamaIbu,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedAgamaIbu = newValue;
                      });
                    },
                    // **Ganti panggilan validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'agamaIbu',
                      val,
                      _requiredObjectValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    key: _fieldKeys['golDarahIbu'],
                    label: 'Golongan Darah Ibu',
                    icon: Icons.bloodtype,
                    items: _golDarahList,
                    value: _selectedGolIbu,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGolIbu = newValue;
                      });
                    },
                    // **Ganti panggilan validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'golDarahIbu',
                      val,
                      _requiredObjectValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    key: _fieldKeys['pekerjaanIbu'],
                    label: 'Pekerjaan Ibu',
                    icon: Icons.work,
                    controller: _jobIbuController,
                    // **Ganti panggilan validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'pekerjaanIbu',
                      val,
                      _requiredStringValidator,
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownField(
                    key: _fieldKeys['pendidikanIbu'],
                    label: 'Pendidikan Ibu',
                    icon: Icons.school,
                    items: _pendidikanList,
                    value: _selectedPendidikanIbu,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPendidikanIbu = newValue;
                      });
                    },
                    // **Ganti panggilan validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'pendidikanIbu',
                      val,
                      _requiredObjectValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DatePickerFormField(
                    key: _fieldKeys['tanggalLahirIbu'],
                    labelText: 'Tanggal Lahir Ibu',
                    prefixIcon: Icons.calendar_today,
                    value: _birthdateIbu,
                    initialDate: DateTime(DateTime.now().year - 20),
                    context: context,
                    onDateSelected: (date) {
                      setState(() {
                        print('tgl lahir asli: $date');
                        _birthdateIbu = date;
                      });
                    },
                    // **Ganti panggilan validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'tanggalLahirIbu',
                      val,
                      _requiredObjectValidator,
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionTitle('Data Suami'),
                  CustomTextField(
                    key: _fieldKeys['nikSuami'],
                    label: 'NIK Suami',
                    icon: Icons.badge,
                    controller: _nikSuamiController,
                    isNumber: true,
                    maxLength: 16,
                    suffixIcon: IconButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KtpCameraScreen(
                              onCaptured: (KtpModel ktp) async {
                                _ktpSuami = ktp;
                                setState(() {
                                  populateSuamiDataFromKTP();
                                });
                              },
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.camera_alt_outlined),
                    ),
                    // **Ganti panggilan validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'nikSuami',
                      val,
                      _validateNIK,
                    ),
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
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    key: _fieldKeys['namaSuami'],
                    label: 'Nama Suami',
                    icon: Icons.person,
                    controller: _namaSuamiController,
                    textCapitalization: TextCapitalization.words,
                    // **Ganti panggilan validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'namaSuami',
                      val,
                      _requiredStringValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    key: _fieldKeys['agamaSuami'],
                    label: 'Agama Suami',
                    icon: Icons.account_balance,
                    items: _agamaList,
                    value: _selectedAgamaSuami,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedAgamaSuami = newValue;
                      });
                    },
                    // **Ganti panggilan validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'agamaSuami',
                      val,
                      _requiredObjectValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownField(
                    key: _fieldKeys['golDarahSuami'],
                    label: 'Golongan Darah Suami',
                    icon: Icons.bloodtype,
                    items: _golDarahList,
                    value: _selectedGolSuami,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGolSuami = newValue;
                      });
                    },
                    // **Ganti panggilan validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'golDarahSuami',
                      val,
                      _requiredObjectValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    key: _fieldKeys['pekerjaanSuami'],
                    label: 'Pekerjaan Suami',
                    icon: Icons.work,
                    controller: _jobSuamiController,
                    // **Ganti panggilan validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'pekerjaanSuami',
                      val,
                      _requiredStringValidator,
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownField(
                    key: _fieldKeys['pendidikanSuami'],
                    label: 'Pendidikan Suami',
                    icon: Icons.school,
                    items: _pendidikanList,
                    value: _selectedPendidikanSuami,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPendidikanSuami = newValue;
                      });
                    },
                    // **Ganti panggilan validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'pendidikanSuami',
                      val,
                      _requiredObjectValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DatePickerFormField(
                    key: _fieldKeys['tanggalLahirSuami'],
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
                    // **Ganti panggilan validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'tanggalLahirSuami',
                      val,
                      _requiredObjectValidator,
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionTitle('Data Lain'),
                  CustomTextField(
                    key: _fieldKeys['alamat'],
                    label: 'Alamat',
                    icon: Icons.home,
                    isMultiline: true,
                    controller: _alamatController,
                    // **Ganti panggilan validator**
                    validator: (val) => _formValidator.wrapValidator(
                      'alamat',
                      val,
                      _requiredStringValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    key: _fieldKeys['noHp'],
                    label: 'No HP',
                    icon: Icons.phone,
                    controller: _noHpController,
                    keyboardType: TextInputType.phone,
                    // **Ganti panggilan validator**
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
                            message: 'Data Bumil berhasil disimpan',
                            type: SnackbarType.success,
                          );
                          Navigator.pushReplacementNamed(
                            context,
                            AppRouter.addRiwayat,
                            arguments: {'state': 'instantUpdate'},
                          );
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
