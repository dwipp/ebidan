import 'package:ebidan/common/constants.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/data/models/riwayat_model.dart';
import 'package:ebidan/presentation/widgets/date_picker_field.dart';
import 'package:ebidan/presentation/widgets/dropdown_field.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/riwayat/cubit/submit_riwayat_cubit.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/state_management/mode_bidan/riwayat/cubit/selected_riwayat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import FormValidator
import 'package:ebidan/common/utility/form_validator.dart';

class EditRiwayatBumilScreen extends StatefulWidget {
  final String state;
  const EditRiwayatBumilScreen({super.key, required this.state});

  @override
  State<EditRiwayatBumilScreen> createState() => _EditRiwayatBumilState();
}

class _EditRiwayatBumilState extends State<EditRiwayatBumilScreen> {
  final _formKey = GlobalKey<FormState>();

  // **PERUBAHAN 1: Definisikan GlobalKey untuk setiap field wajib**
  final Map<String, GlobalKey> _fieldKeys = {
    'beratBayi': GlobalKey(),
    'panjangBayi': GlobalKey(),
    'statusBayi': GlobalKey(),
    'tglLahir': GlobalKey(),
    'statusLahir': GlobalKey(),
    'statusKehamilan': GlobalKey(),
    'tempat': GlobalKey(),
    'penolong': GlobalKey(),
    'penolongLainnya': GlobalKey(),
  };

  // **PERUBAHAN 2: Deklarasi FormValidator**
  late FormValidator _formValidator;

  String? _statusBayi;

  String? _statusKehamilan;

  String? _penolong;

  String? _tempat;

  String? _statusLahir;
  DateTime? _tglLahir;
  late TextEditingController _beratBayiController;
  late TextEditingController _komplikasiController;
  late TextEditingController _panjangBayiController;
  late TextEditingController _penolongLainnyaController;

  Bumil? bumil;
  Riwayat? riwayat;

  // Validator standar untuk wajib diisi
  String? _requiredValidator(dynamic val) {
    if (val is String) {
      return val.isEmpty ? 'Wajib diisi' : null;
    }
    return val == null ? 'Wajib dipilih' : null;
  }

  @override
  void initState() {
    context.read<SubmitRiwayatCubit>().setInitial();
    // **PERUBAHAN 3: Inisialisasi FormValidator**
    _formValidator = FormValidator(fieldKeys: _fieldKeys);
    super.initState();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    bumil = context.watch<SelectedBumilCubit>().state;
    riwayat = context.watch<SelectedRiwayatCubit>().state;

    _tglLahir = riwayat?.tglLahir;

    _beratBayiController = TextEditingController(
      text: riwayat?.beratBayi.toString(),
    );
    _komplikasiController = TextEditingController(text: riwayat?.komplikasi);
    _panjangBayiController = TextEditingController(text: riwayat?.panjangBayi);
    _penolongLainnyaController = TextEditingController(text: '');
    _statusBayi = riwayat?.statusBayi ?? '';
    _statusKehamilan = riwayat?.statusTerm ?? '';
    _statusLahir = riwayat?.statusLahir ?? '';
    _penolong = riwayat?.penolong ?? '';
    _tempat = riwayat?.tempat ?? '';
    if (_penolong != null) {
      if (Constants.penolongList.contains(_penolong)) {
        _penolongLainnyaController.text = '';
      } else {
        _penolongLainnyaController.text = _penolong!;
        _penolong = 'Lainnya';
      }
    }
  }

  void _submitForm() {
    // **PERUBAHAN 4: Ganti validasi manual dengan validateAndScroll**
    _formValidator.reset();

    if (!_formValidator.validateAndScroll(_formKey, context)) {
      return;
    }

    if (riwayat == null && bumil == null) return;

    final newRiwayat = Riwayat(
      id: riwayat!.id,
      tglLahir: _tglLahir!,
      beratBayi: int.parse(_beratBayiController.text.trim()),
      komplikasi: _komplikasiController.text.trim(),
      panjangBayi: _panjangBayiController.text.trim(),
      penolong: _penolong == 'Lainnya'
          ? _penolongLainnyaController.text.trim()
          : _penolong!,
      statusBayi: _statusBayi!,
      statusLahir: _statusLahir!,
      statusTerm: _statusKehamilan!,
      tempat: _tempat ?? '',
    );

    context.read<SubmitRiwayatCubit>().editRiwayat(updatedRiwayat: newRiwayat);
  }

  @override
  void dispose() {
    _beratBayiController.dispose();
    _komplikasiController.dispose();
    _panjangBayiController.dispose();
    _penolongLainnyaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title: Text('Perbaharui Riwayat')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informasi Bayi'),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['beratBayi'], // Tambahkan key
                label: 'Berat Bayi',
                icon: Icons.monitor_weight,
                controller: _beratBayiController,
                isNumber: true,
                suffixText: 'gram',
                // **PERUBAHAN 5: Wrap validator**
                validator: (val) => _formValidator.wrapValidator(
                  'beratBayi',
                  val,
                  _requiredValidator,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['panjangBayi'], // Tambahkan key
                label: 'Panjang Bayi',
                icon: Icons.straighten,
                controller: _panjangBayiController,
                isNumber: true,
                suffixText: 'cm',
                // **Wrap validator**
                validator: (val) => _formValidator.wrapValidator(
                  'panjangBayi',
                  val,
                  _requiredValidator,
                ),
              ),
              const SizedBox(height: 12),
              DropdownField(
                key: _fieldKeys['statusBayi'], // Tambahkan key
                label: 'Status Bayi',
                icon: Icons.child_care,
                items: Constants.statusBayiList,
                value: _statusBayi,
                onChanged: (newValue) {
                  setState(() {
                    _statusBayi = newValue;
                  });
                },
                // **Wrap validator**
                validator: (val) => _formValidator.wrapValidator(
                  'statusBayi',
                  val,
                  _requiredValidator,
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Persalinan'),
              DatePickerFormField(
                key: _fieldKeys['tglLahir'], // Tambahkan key
                labelText: 'Tanggal Lahir',
                prefixIcon: Icons.calendar_today,
                initialValue: _tglLahir,
                initialDate: _tglLahir,
                context: context,
                onDateSelected: (date) {
                  setState(() {
                    _tglLahir = date;
                  });
                },
                // **Wrap validator**
                validator: (val) => _formValidator.wrapValidator(
                  'tglLahir',
                  val,
                  _requiredValidator,
                ),
              ),
              DropdownField(
                key: _fieldKeys['statusLahir'], // Tambahkan key
                label: 'Status Lahir',
                icon: Icons.pregnant_woman,
                items: Constants.caraLahirList,
                value: _statusLahir,
                onChanged: (newValue) {
                  setState(() {
                    _statusLahir = newValue;
                  });
                },
                validator: (val) {
                  if (_statusBayi != "Abortus") {
                    return _formValidator.wrapValidator(
                      'statusLahir',
                      val,
                      _requiredValidator,
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownField(
                key: _fieldKeys['statusKehamilan'], // Tambahkan key
                label: 'Status Kehamilan',
                icon: Icons.date_range,
                items: Constants.statusKehamilanList,
                value: _statusKehamilan,
                onChanged: (newValue) {
                  setState(() {
                    _statusKehamilan = newValue;
                  });
                },
                validator: (val) {
                  if (_statusBayi != "Abortus") {
                    return _formValidator.wrapValidator(
                      'statusKehamilan',
                      val,
                      _requiredValidator,
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownField(
                key: _fieldKeys['tempat'], // Tambahkan key
                label: 'Tempat Persalinan',
                icon: Icons.home,
                items: Constants.tempatList,
                value: _tempat,
                onChanged: (newValue) {
                  setState(() {
                    _tempat = newValue;
                  });
                },
                // **Wrap validator**
                validator: (val) => _formValidator.wrapValidator(
                  'tempat',
                  val,
                  _requiredValidator,
                ),
              ),
              const SizedBox(height: 12),
              _buildPenolongField(),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Komplikasi',
                icon: Icons.local_hospital,
                controller: _komplikasiController,
                isMultiline: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: BlocConsumer<SubmitRiwayatCubit, SubmitiwayatState>(
                  listener: (context, state) {
                    if (state is SubmitRiwayatSuccess) {
                      Snackbar.show(
                        context,
                        message: 'Riwayat berhasil disimpan',
                        type: SnackbarType.success,
                      );

                      if (widget.state == 'lateUpdate') {
                        Navigator.pop(context, state.listRiwayat);
                      } else {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRouter.addKehamilan,
                        );
                      }
                    } else if (state is SubmitRiwayatFailure) {
                      Snackbar.show(
                        context,
                        message: 'Gagal: ${state.message}',
                        type: SnackbarType.error,
                      );
                    } else if (state is AddRiwayatEmpty) {
                      Snackbar.show(
                        context,
                        message: 'Data bumil disimpan tanpa riwayat kehamilan',
                        type: SnackbarType.general,
                      );
                      if (widget.state == 'lateUpdate') {
                        Navigator.pop(context, null);
                      } else {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRouter.addKehamilan,
                        );
                      }
                    }
                  },
                  builder: (context, state) {
                    var isSubmitting = false;
                    if (state is SubmitRiwayatLoading) {
                      isSubmitting = true;
                    }
                    return Button(
                      isSubmitting: isSubmitting,
                      label: 'Perhabarui',
                      loadingLabel: 'Menyimpan...',
                      icon: Icons.save,
                      onPressed: _submitForm,
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
          value: _penolong != null && Constants.penolongList.contains(_penolong)
              ? _penolong
              : null, // hanya value yang ada di list
          decoration: const InputDecoration(
            labelText: 'Penolong',
            prefixIcon: Icon(Icons.person),
          ),
          items: Constants.penolongList.map((String value) {
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
            validator: (val) => _formValidator.wrapValidator(
              'penolong',
              val,
              _requiredValidator,
            ),
          ),
      ],
    );
  }
}
