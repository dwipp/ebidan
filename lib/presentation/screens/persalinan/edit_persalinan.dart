import 'package:ebidan/data/models/kehamilan_model.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/date_picker_field.dart';
import 'package:ebidan/presentation/widgets/dropdown_field.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/data/models/persalinan_model.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/state_management/kehamilan/cubit/selected_kehamilan_cubit.dart';
import 'package:ebidan/state_management/persalinan/cubit/submit_persalinan_cubit.dart';
import 'package:ebidan/state_management/persalinan/cubit/selected_persalinan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:ebidan/presentation/widgets/date_time_picker_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import FormValidator
import 'package:ebidan/common/utility/form_validator.dart';

class EditPersalinanScreen extends StatefulWidget {
  const EditPersalinanScreen({super.key});

  @override
  State<EditPersalinanScreen> createState() => _EditPersalinanState();
}

class _EditPersalinanState extends State<EditPersalinanScreen> {
  final _formKey = GlobalKey<FormState>();

  // **PERUBAHAN 1: Definisikan GlobalKey untuk setiap field wajib**
  final Map<String, GlobalKey> _fieldKeys = {
    'tglPersalinan': GlobalKey(),
    'statusBayi': GlobalKey(),
    'beratBayi': GlobalKey(),
    'lingkarKepala': GlobalKey(),
    'panjangBadan': GlobalKey(),
    'umurKehamilan': GlobalKey(),
    'sex': GlobalKey(),
    'caraBersalin': GlobalKey(),
    'caraBersalinLainnya': GlobalKey(),
    'penolong': GlobalKey(),
    'penolongLainnya': GlobalKey(),
    'tempatBersalin': GlobalKey(),
  };

  // **PERUBAHAN 2: Deklarasi FormValidator**
  late FormValidator _formValidator;

  final _beratBayiController = TextEditingController();
  final _lingkarKepalaController = TextEditingController();
  final _panjangBadanController = TextEditingController();
  final _umurKehamilanController = TextEditingController();
  final _penolongLainnyaController = TextEditingController();
  final _caraLainnyaController = TextEditingController();

  String? _statusBayi;
  String? _sex;
  String? _caraBersalin;
  String? _penolong;
  String? _tempatBersalin;

  DateTime? _tglPersalinan;
  DateTime? _createdAt;

  final List<String> statusBayiList = ['Hidup', 'Mati', 'Abortus'];

  final List<String> _caraLahirList = [
    'Spontan Belakang Kepala',
    'Section Caesarea (SC)',
    'Lainnya',
  ];

  final List<String> _caraAbortusList = ['Kuretase', 'Mandiri', 'Lainnya'];
  final List<String> penolongList = [
    'Bidan',
    'Dokter',
    'Dukun Kampung',
    'Lainnya',
  ];
  final List<String> tempatList = [
    'Rumah Sakit',
    'Poskesdes',
    'Polindes',
    'Rumah',
    'Jalan',
  ];
  final List<String> sexList = ['Laki-laki', 'Perempuan'];

  Kehamilan? kehamilan;
  Persalinan? persalinan;

  // Validator standar untuk wajib diisi
  String? _requiredValidator(dynamic val) {
    if (val is String) {
      return val.isEmpty ? 'Wajib diisi' : null;
    }
    return val == null ? 'Wajib dipilih' : null;
  }

  @override
  void initState() {
    super.initState();
    context.read<SubmitPersalinanCubit>().setInitial();
    // **PERUBAHAN 3: Inisialisasi FormValidator**
    _formValidator = FormValidator(fieldKeys: _fieldKeys);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    kehamilan = context.watch<SelectedKehamilanCubit>().state;
    persalinan = context.watch<SelectedPersalinanCubit>().state;

    if (persalinan != null) {
      _tglPersalinan = persalinan!.tglPersalinan;
      _createdAt = persalinan!.createdAt;
      _statusBayi = persalinan!.statusBayi;
      _sex = persalinan!.sex;
      _caraBersalin = persalinan!.cara;
      _penolong = persalinan!.penolong;
      _tempatBersalin = persalinan!.tempat;
      _beratBayiController.text = persalinan!.beratLahir ?? '';
      _lingkarKepalaController.text = persalinan!.lingkarKepala ?? '';
      _panjangBadanController.text = persalinan!.panjangBadan ?? '';
      _umurKehamilanController.text = persalinan!.umurKehamilan ?? '';
      if (_penolong != null) {
        if (penolongList.contains(_penolong)) {
          _penolongLainnyaController.text = '';
        } else {
          _penolongLainnyaController.text = _penolong!;
          _penolong = 'Lainnya';
        }
      }
      if (_caraBersalin != null) {
        if (_statusBayi == 'Abortus') {
          if (_caraAbortusList.contains(_caraBersalin)) {
            _caraLainnyaController.text = '';
          } else {
            _caraLainnyaController.text = _caraBersalin!;
            _caraBersalin = 'Lainnya';
          }
        } else {
          if (_caraLahirList.contains(_caraBersalin)) {
            _caraLainnyaController.text = '';
          } else {
            _caraLainnyaController.text = _caraBersalin!;
            _caraBersalin = 'Lainnya';
          }
        }
      }
    }
  }

  String getStatusKehamilan(int usiaMinggu) {
    if (usiaMinggu < 37) {
      return "Preterm";
    } else if (usiaMinggu >= 37 && usiaMinggu <= 41) {
      return "Aterm";
    } else if (usiaMinggu >= 42) {
      return "Postterm";
    } else {
      return "-";
    }
  }

  String hitungUsiaKehamilan({
    required DateTime hpht,
    DateTime? tanggalPersalinan,
  }) {
    // default: hari ini
    tanggalPersalinan ??= DateTime.now();

    if (tanggalPersalinan.isBefore(hpht)) {
      throw ArgumentError("Tanggal acuan tidak boleh sebelum HPHT");
    }

    final duration = tanggalPersalinan.difference(hpht);
    final minggu = duration.inDays ~/ 7;
    final hari = duration.inDays % 7;
    if (hari == 0) {
      return '$minggu minggu';
    }
    return '$minggu minggu $hari hari';
  }

  Future<void> _submitData() async {
    // **PERUBAHAN 4: Ganti validasi manual dengan validateAndScroll**
    _formValidator.reset();

    if (!_formValidator.validateAndScroll(_formKey, context)) {
      return;
    }

    if (persalinan == null) return;
    final updatedPersalinan = Persalinan(
      id: persalinan!.id,
      beratLahir: _beratBayiController.text.trim(),
      cara: _caraBersalin == 'Lainnya'
          ? _caraLainnyaController.text.trim()
          : _caraBersalin!,
      createdAt: persalinan!.createdAt,
      lingkarKepala: _lingkarKepalaController.text.trim(),
      panjangBadan: _panjangBadanController.text.trim(),
      penolong: _penolong == 'Lainnya'
          ? _penolongLainnyaController.text.trim()
          : _penolong!,
      sex: _sex,
      statusBayi: _statusBayi,
      tempat: _tempatBersalin,
      tglPersalinan: _tglPersalinan,
      umurKehamilan: _umurKehamilanController.text.trim(),
    );
    context.read<SubmitPersalinanCubit>().editPersalinan(
      updatedPersalinan: updatedPersalinan,
    );
  }

  @override
  void dispose() {
    _beratBayiController.dispose();
    _lingkarKepalaController.dispose();
    _panjangBadanController.dispose();
    _umurKehamilanController.dispose();
    _penolongLainnyaController.dispose();
    _caraLainnyaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title: Text('Perbaharui Data Persalinan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.sectionTitle('Detail Persalinan'),
              DateTimePickerField(
                key: _fieldKeys['tglPersalinan'], // Tambahkan key
                labelText: 'Tanggal Persalinan',
                prefixIcon: Icons.calendar_today,
                initialValue: _tglPersalinan,
                onSaved: (dateTime) {
                  _tglPersalinan = dateTime;
                },
                onDateSelected: (dateTime) {
                  if (kehamilan!.hpht != null) {
                    setState(() {
                      final usia = hitungUsiaKehamilan(
                        hpht: kehamilan!.hpht!,
                        tanggalPersalinan: dateTime,
                      );
                      _umurKehamilanController.text = usia;
                    });
                  }
                },
                // **PERUBAHAN 5: Wrap validator**
                validator: (val) => _formValidator.wrapValidator(
                  'tglPersalinan',
                  val,
                  _requiredValidator,
                ),
                context: context,
              ),
              DropdownField(
                key: _fieldKeys['statusBayi'], // Tambahkan key
                label: 'Status Bayi',
                icon: Icons.child_care,
                items: statusBayiList,
                value: _statusBayi,
                onChanged: (newValue) {
                  setState(() {
                    _statusBayi = newValue ?? '';
                  });
                },
                // **Wrap validator**
                validator: (val) => _formValidator.wrapValidator(
                  'statusBayi',
                  val,
                  _requiredValidator,
                ),
              ),
              CustomTextField(
                key: _fieldKeys['beratBayi'], // Tambahkan key
                controller: _beratBayiController,
                label: 'Berat Lahir',
                icon: Icons.monitor_weight,
                isNumber: true,
                suffixText: 'gram',
                disable: _statusBayi == "Abortus",
                validator: (val) {
                  if (_statusBayi != "Abortus") {
                    return _formValidator.wrapValidator(
                      'beratBayi',
                      val,
                      _requiredValidator,
                    );
                  }
                  return null;
                },
              ),
              CustomTextField(
                key: _fieldKeys['lingkarKepala'], // Tambahkan key
                controller: _lingkarKepalaController,
                label: 'Lingkar Kepala',
                icon: Icons.circle_outlined,
                isNumber: true,
                suffixText: 'cm',
                disable: _statusBayi == "Abortus",
                validator: (val) {
                  if (_statusBayi != "Abortus") {
                    return _formValidator.wrapValidator(
                      'lingkarKepala',
                      val,
                      _requiredValidator,
                    );
                  }
                  return null;
                },
              ),
              CustomTextField(
                key: _fieldKeys['panjangBadan'], // Tambahkan key
                controller: _panjangBadanController,
                label: 'Panjang Badan',
                icon: Icons.straighten,
                isNumber: true,
                suffixText: 'cm',
                disable: _statusBayi == "Abortus",
                validator: (val) {
                  if (_statusBayi != "Abortus") {
                    return _formValidator.wrapValidator(
                      'panjangBadan',
                      val,
                      _requiredValidator,
                    );
                  }
                  return null;
                },
              ),
              CustomTextField(
                key: _fieldKeys['umurKehamilan'], // Tambahkan key
                label: 'Umur Kehamilan',
                icon: Icons.date_range,
                isNumber: true,
                readOnly: true,
                controller: _umurKehamilanController,
                // **Wrap validator**
                validator: (val) => _formValidator.wrapValidator(
                  'umurKehamilan',
                  val,
                  _requiredValidator,
                ),
              ),
              const SizedBox(height: 16),
              Utils.sectionTitle('Kondisi Persalinan'),
              DropdownField(
                key: _fieldKeys['sex'], // Tambahkan key
                label: 'Jenis Kelamin',
                icon: Icons.transgender,
                items: sexList,
                value: _sex,
                onChanged: (newValue) {
                  setState(() {
                    _sex = newValue ?? '';
                  });
                },
                enabled: _statusBayi != "Abortus",
                validator: (val) {
                  if (_statusBayi != "Abortus") {
                    return _formValidator.wrapValidator(
                      'sex',
                      val,
                      _requiredValidator,
                    );
                  }
                  return null;
                },
              ),
              _buildCaraMelahirkanField(),
              _buildPenolongField(),
              DropdownField(
                key: _fieldKeys['tempatBersalin'], // Tambahkan key
                label: 'Tempat Persalinan',
                icon: Icons.home,
                items: tempatList,
                value: _tempatBersalin,
                onChanged: (newValue) {
                  setState(() {
                    _tempatBersalin = newValue ?? '';
                  });
                },
                // **Wrap validator**
                validator: (val) => _formValidator.wrapValidator(
                  'tempatBersalin',
                  val,
                  _requiredValidator,
                ),
              ),
              DatePickerFormField(
                labelText: 'Tanggal Pembuatan Data',
                prefixIcon: Icons.calendar_view_day,
                initialValue: _createdAt,
                context: context,
                readOnly: true,
                onDateSelected: (date) {
                  setState(() => _createdAt = date);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child:
                    BlocConsumer<SubmitPersalinanCubit, SubmitPersalinanState>(
                      listener: (context, state) {
                        if (state is AddPersalinanSuccess) {
                          Snackbar.show(
                            context,
                            message: 'Data persalinan berhasil disimpan',
                            type: SnackbarType.success,
                          );
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRouter.homepage,
                            (route) => false,
                          );
                        } else if (state is AddPersalinanFailure) {
                          Snackbar.show(
                            context,
                            message: 'Gagal: ${state.message}',
                            type: SnackbarType.error,
                          );
                        }
                      },
                      builder: (context, state) {
                        var isSubmitting = false;
                        if (state is AddPersalinanLoading) {
                          isSubmitting = true;
                        }
                        return Button(
                          isSubmitting: isSubmitting,
                          onPressed: _submitData,
                          label: 'Perbaharui',
                          icon: Icons.save,
                          loadingLabel: 'Menyimpan...',
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPenolongField() {
    // Cek apakah user memilih "Lainnya"
    bool isLainnya = _penolong == 'Lainnya';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          key: _fieldKeys['penolong'], // Tambahkan key
          value: _penolong != null && penolongList.contains(_penolong)
              ? _penolong
              : null, // hanya value yang ada di list
          decoration: const InputDecoration(
            labelText: 'Penolong',
            prefixIcon: Icon(Icons.person),
          ),
          items: penolongList.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _penolong = newValue ?? '';
              if (newValue != 'Lainnya') {
                // _penolongLainnyaController.text = ''; // sembunyikan field tambahan
              }
            });
          },
          // validator: (val) {
          //   if (_penolong == null || _penolong!.isEmpty) {
          //     return 'Wajib dipilih';
          //   }
          //   return null;
          // },
          validator: (val) =>
              _formValidator.wrapValidator('penolong', val, _requiredValidator),
        ),
        if (isLainnya) const SizedBox(height: 8),
        if (isLainnya)
          CustomTextField(
            key: _fieldKeys['penolongLainnya'], // Tambahkan key
            label: 'Penolong Lainnya',
            icon: Icons.person_outline,
            controller: _penolongLainnyaController,
            // validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
            validator: (val) => _formValidator.wrapValidator(
              'penolongLainnya',
              val,
              _requiredValidator,
            ),
          ),
      ],
    );
  }

  Widget _buildCaraMelahirkanField() {
    bool isLainnya = _caraBersalin == 'Lainnya';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownField(
          key: _fieldKeys['caraBersalin'], // Tambahkan key
          label: 'Cara Persalinan',
          icon: Icons.pregnant_woman,
          items: _statusBayi != "Abortus" ? _caraLahirList : _caraAbortusList,
          value: _caraBersalin,
          onChanged: (newValue) {
            setState(() {
              _caraBersalin = newValue;
            });
          },
          // **Wrap validator**
          validator: (val) => _formValidator.wrapValidator(
            'caraBersalin',
            val,
            _requiredValidator,
          ),
        ),
        if (isLainnya) const SizedBox(height: 8),
        if (isLainnya)
          CustomTextField(
            key: _fieldKeys['caraBersalinLainnya'], // Tambahkan key
            label: 'Cara Persalinan Lainnya',
            icon: Icons.pregnant_woman,
            controller: _caraLainnyaController,
            // validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
            validator: (val) => _formValidator.wrapValidator(
              'caraBersalinLainnya',
              val,
              _requiredValidator,
            ),
          ),
      ],
    );
  }
}
