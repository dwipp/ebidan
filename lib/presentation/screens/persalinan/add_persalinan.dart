import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/date_picker_field.dart';
import 'package:ebidan/presentation/widgets/dropdown_field.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/data/models/persalinan_model.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/persalinan/cubit/submit_persalinan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:ebidan/presentation/widgets/date_time_picker_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import FormValidator
import 'package:ebidan/common/utility/form_validator.dart';

class AddPersalinanScreen extends StatefulWidget {
  const AddPersalinanScreen({super.key});

  @override
  State<AddPersalinanScreen> createState() => _AddPersalinanState();
}

class _AddPersalinanState extends State<AddPersalinanScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Persalinan> persalinanList = [];

  // **PERUBAHAN 1: DEFINISI FIELD KEYS DINAMIS**
  // Gunakan Map<String, GlobalKey> untuk menyimpan semua key,
  // di mana key akan berformat 'namaField_index'
  final Map<String, GlobalKey> _fieldKeys = {};

  late FormValidator _formValidator;

  // Validator standar
  String? _requiredStringValidator(dynamic val) =>
      val == null || val.isEmpty ? 'Wajib diisi' : null;
  String? _requiredObjectValidator(dynamic val) =>
      val == null || (val is String && val.isEmpty) ? 'Wajib dipilih' : null;

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

  Bumil? bumil;

  @override
  void initState() {
    super.initState();
    context.read<SubmitPersalinanCubit>().setInitial();
    // Inisialisasi FormValidator dengan map keys yang kosong.
    _formValidator = FormValidator(fieldKeys: _fieldKeys);
    _addPersalinan();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bumil = context.watch<SelectedBumilCubit>().state;
  }

  // **PERUBAHAN 2: LOGIKA DINAMIS GLOBAL KEY**
  void _updateKeys(int index, String fieldName) {
    final keyName = '${fieldName}_$index';
    if (!_fieldKeys.containsKey(keyName)) {
      _fieldKeys[keyName] = GlobalKey();
    }
  }

  void _addPersalinan() {
    // Inisialisasi data dan Global Keys untuk indeks baru
    setState(() {
      persalinanList.add(Persalinan.empty());
      final newIndex = persalinanList.length - 1;

      // Update keys untuk field yang ada
      _updateKeys(newIndex, 'tglPersalinan');
      _updateKeys(newIndex, 'statusBayi');
      _updateKeys(newIndex, 'beratLahir');
      _updateKeys(newIndex, 'lingkarKepala');
      _updateKeys(newIndex, 'panjangBadan');
      _updateKeys(newIndex, 'umurKehamilan');
      _updateKeys(newIndex, 'sex');
      _updateKeys(newIndex, 'cara');
      _updateKeys(newIndex, 'penolong');
      _updateKeys(newIndex, 'tempat');
      // Tidak perlu key untuk penolong_lainnya atau cara_lainnya
      // karena mereka menggunakan data.penolong/data.cara yang sama.
    });
  }

  void _removePersalinan(int index) {
    setState(() {
      persalinanList.removeAt(index);

      // Hapus keys lama dan reset fieldKeys
      _fieldKeys.clear();

      // Regenerasi semua keys untuk memastikan indeksnya benar
      for (int i = 0; i < persalinanList.length; i++) {
        _updateKeys(i, 'tglPersalinan');
        _updateKeys(i, 'statusBayi');
        _updateKeys(i, 'beratLahir');
        _updateKeys(i, 'lingkarKepala');
        _updateKeys(i, 'panjangBadan');
        _updateKeys(i, 'umurKehamilan');
        _updateKeys(i, 'sex');
        _updateKeys(i, 'cara');
        _updateKeys(i, 'penolong');
        _updateKeys(i, 'tempat');
      }
    });
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
    tanggalPersalinan ??= DateTime.now();

    if (tanggalPersalinan.isBefore(hpht)) {
      return '0 minggu 0 hari'; // Handle error case gracefully
    }

    final duration = tanggalPersalinan.difference(hpht);
    final minggu = duration.inDays ~/ 7;
    final hari = duration.inDays % 7;

    return '$minggu minggu $hari hari';
  }

  Future<void> _submitData() async {
    // **PERUBAHAN 3: GANTI VALIDASI MANUAL DENGAN VALIDATE AND SCROLL**
    _formValidator.reset();

    // Panggil validateAndScroll
    if (!_formValidator.validateAndScroll(_formKey, context)) {
      // FormValidator sudah menangani scroll dan snackbar error
      return;
    }

    _formKey.currentState!.save();

    context.read<SubmitPersalinanCubit>().addPersalinan(
      persalinanList,
      bumilId: bumil!.idBumil,
      kehamilanId: bumil!.latestKehamilanId!,
      resti: bumil!.latestKehamilanResti!.join(", "),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title: Text('Data Persalinan')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...persalinanList.asMap().entries.map((entry) {
                int index = entry.key;
                Persalinan data = entry.value;

                // Getter untuk GlobalKey dinamis
                GlobalKey? getKey(String fieldName) =>
                    _fieldKeys['${fieldName}_$index'];

                // Setter untuk wrapValidator dengan fieldName dinamis
                String? wrap(
                  String fieldName,
                  dynamic val,
                  FieldValidator validator,
                ) {
                  return _formValidator.wrapValidator(
                    '${fieldName}_$index',
                    val,
                    validator,
                  );
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Utils.sectionTitle('Detail Persalinan ${index + 1}'),
                        DateTimePickerField(
                          // **Key Dinamis**
                          key: getKey('tglPersalinan'),
                          labelText: 'Tanggal Persalinan',
                          prefixIcon: Icons.calendar_today,
                          onSaved: (dateTime) {
                            data.tglPersalinan = dateTime;
                          },
                          onDateSelected: (dateTime) {
                            if (bumil?.latestKehamilanHpht != null) {
                              setState(() {
                                final usia = hitungUsiaKehamilan(
                                  hpht: bumil!.latestKehamilanHpht!,
                                  tanggalPersalinan: dateTime,
                                );
                                data.umurKehamilanController.text = usia;
                              });
                            }
                          },
                          // **Wrap Validator**
                          validator: (val) => wrap(
                            'tglPersalinan',
                            val,
                            _requiredObjectValidator,
                          ),
                          context: context,
                        ),
                        DropdownField(
                          // **Key Dinamis**
                          key: getKey('statusBayi'),
                          label: 'Status Bayi',
                          icon: Icons.child_care,
                          items: statusBayiList,
                          value: data.statusBayi,
                          onChanged: (newValue) {
                            setState(() {
                              data.statusBayi = newValue ?? '';
                            });
                          },
                          // **Wrap Validator**
                          validator: (val) =>
                              wrap('statusBayi', val, _requiredObjectValidator),
                        ),
                        CustomTextField(
                          // **Key Dinamis**
                          key: getKey('beratLahir'),
                          label: 'Berat Lahir',
                          icon: Icons.monitor_weight,
                          onSaved: (val) => data.beratLahir = val,
                          isNumber: true,
                          suffixText: 'gram',
                          disable: data.statusBayi == "Abortus",
                          // **Wrap Validator Kondisional**
                          validator: (val) {
                            if (data.statusBayi != "Abortus") {
                              return wrap(
                                'beratLahir',
                                val,
                                _requiredStringValidator,
                              );
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          // **Key Dinamis**
                          key: getKey('lingkarKepala'),
                          label: 'Lingkar Kepala',
                          icon: Icons.circle_outlined,
                          onSaved: (val) => data.lingkarKepala = val,
                          isNumber: true,
                          suffixText: 'cm',
                          disable: data.statusBayi == "Abortus",
                          // **Wrap Validator Kondisional**
                          validator: (val) {
                            if (data.statusBayi != "Abortus") {
                              return wrap(
                                'lingkarKepala',
                                val,
                                _requiredStringValidator,
                              );
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          // **Key Dinamis**
                          key: getKey('panjangBadan'),
                          label: 'Panjang Badan',
                          icon: Icons.straighten,
                          onSaved: (val) => data.panjangBadan = val,
                          isNumber: true,
                          suffixText: 'cm',
                          disable: data.statusBayi == "Abortus",
                          // **Wrap Validator Kondisional**
                          validator: (val) {
                            if (data.statusBayi != "Abortus") {
                              return wrap(
                                'panjangBadan',
                                val,
                                _requiredStringValidator,
                              );
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          // **Key Dinamis**
                          key: getKey('umurKehamilan'),
                          label: 'Umur Kehamilan',
                          icon: Icons.date_range,
                          onSaved: (val) => data.umurKehamilan = val,
                          isNumber: true,
                          readOnly: true,
                          controller: data.umurKehamilanController,
                          // **Wrap Validator**
                          validator: (val) => wrap(
                            'umurKehamilan',
                            val,
                            _requiredStringValidator,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Utils.sectionTitle('Kondisi Persalinan'),
                        DropdownField(
                          // **Key Dinamis**
                          key: getKey('sex'),
                          label: 'Jenis Kelamin',
                          icon: Icons.transgender,
                          items: sexList,
                          value: data.sex,
                          onChanged: (newValue) {
                            setState(() {
                              data.sex = newValue ?? '';
                            });
                          },
                          enabled: data.statusBayi != "Abortus",
                          // **Wrap Validator Kondisional**
                          validator: (val) {
                            if (data.statusBayi != "Abortus") {
                              return wrap('sex', val, _requiredObjectValidator);
                            }
                            return null;
                          },
                        ),
                        // Field dengan sub-field 'Lainnya' harus memanggil wrapValidator di dropdown utamanya.
                        _buildCaraMelahirkanField(data, index),
                        _buildPenolongField(data, index),
                        DropdownField(
                          // **Key Dinamis**
                          key: getKey('tempat'),
                          label: 'Tempat Persalinan',
                          icon: Icons.home,
                          items: tempatList,
                          value: data.tempat,
                          onChanged: (newValue) {
                            setState(() {
                              data.tempat = newValue ?? '';
                            });
                          },
                          // **Wrap Validator**
                          validator: (val) =>
                              wrap('tempat', val, _requiredObjectValidator),
                        ),
                        DatePickerFormField(
                          labelText: 'Tanggal Pembuatan Data (Auto)',
                          prefixIcon: Icons.calendar_view_day,
                          initialValue: data.createdAt,
                          context: context,
                          onDateSelected: (date) {
                            setState(() => data.createdAt = date);
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: context.themeColors.error,
                            ),
                            onPressed: () => _removePersalinan(index),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(
                width: double.infinity,
                child: Button(
                  isSubmitting: false,
                  onPressed: _addPersalinan,
                  label: 'Tambah Persalinan (kembar)',
                  icon: Icons.add,
                  secondaryButton: true,
                ),
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
                          label: 'Simpan',
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

  // Penolong Field dengan integrasi Validator
  Widget _buildPenolongField(Persalinan data, int index) {
    bool isLainnya = data.penolong == 'Lainnya';
    GlobalKey? getKey(String fieldName) => _fieldKeys['${fieldName}_$index'];
    String? wrap(String fieldName, dynamic val, FieldValidator validator) {
      return _formValidator.wrapValidator(
        '${fieldName}_$index',
        val,
        validator,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownField(
          key: getKey('penolong'),
          label: 'Penolong',
          icon: Icons.person,
          items: penolongList,
          value: data.penolong != null && penolongList.contains(data.penolong)
              ? data.penolong
              : null,
          onChanged: (newValue) {
            setState(() {
              data.penolong = newValue;
            });
          },
          // Wrap Validator untuk dropdown utama
          validator: (val) => wrap('penolong', val, _requiredObjectValidator),
        ),
        if (isLainnya) const SizedBox(height: 8),
        if (isLainnya)
          CustomTextField(
            // Tidak perlu GlobalKey baru, cukup gunakan validator yang menargetkan penolong
            label: 'Penolong Lainnya',
            icon: Icons.person_outline,
            onSaved: (val) => data.penolong = val,
            // Validator untuk field Lainnya.
            // Note: Field ini TIDAK menggunakan GlobalKey, sehingga tidak bisa di-scroll-ke.
            // Namun, karena ia hanya muncul saat dropdown "Penolong" valid,
            // kita harus memastikan field ini valid saat disave.
            validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
          ),
      ],
    );
  }

  // Cara Melahirkan Field dengan integrasi Validator
  Widget _buildCaraMelahirkanField(Persalinan data, int index) {
    bool isLainnya = data.cara == 'Lainnya';
    GlobalKey? getKey(String fieldName) => _fieldKeys['${fieldName}_$index'];
    String? wrap(String fieldName, dynamic val, FieldValidator validator) {
      return _formValidator.wrapValidator(
        '${fieldName}_$index',
        val,
        validator,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownField(
          key: getKey('cara'),
          label: 'Cara Persalinan',
          icon: Icons.pregnant_woman,
          items: data.statusBayi != "Abortus"
              ? _caraLahirList
              : _caraAbortusList,
          value: data.cara,
          onChanged: (newValue) {
            setState(() {
              data.cara = newValue;
            });
          },
          // Wrap Validator untuk dropdown utama
          validator: (val) => wrap('cara', val, _requiredObjectValidator),
        ),
        if (isLainnya) const SizedBox(height: 8),
        if (isLainnya)
          CustomTextField(
            // Tidak perlu GlobalKey baru, cukup gunakan validator yang menargetkan cara
            label: 'Cara Persalinan Lainnya',
            icon: Icons.pregnant_woman,
            onSaved: (val) => data.cara = val,
            // Validator untuk field Lainnya.
            validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
          ),
      ],
    );
  }
}
