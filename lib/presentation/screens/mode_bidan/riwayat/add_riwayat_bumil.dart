import 'package:ebidan/common/constants.dart';
import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/presentation/widgets/date_picker_field.dart';
import 'package:ebidan/presentation/widgets/dropdown_field.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/riwayat/cubit/submit_riwayat_cubit.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import FormValidator
import 'package:ebidan/common/utility/form_validator.dart';

class AddRiwayatBumilScreen extends StatefulWidget {
  final String state;
  const AddRiwayatBumilScreen({super.key, required this.state});

  @override
  State<AddRiwayatBumilScreen> createState() => _AddRiwayatBumilState();
}

class _AddRiwayatBumilState extends State<AddRiwayatBumilScreen> {
  final _formKey = GlobalKey<FormState>();

  // **PERUBAHAN 1: DEFINISI FIELD KEYS DINAMIS**
  final Map<String, GlobalKey> _fieldKeys = {};
  late FormValidator _formValidator;

  // Validator standar
  String? _requiredObjectValidator(dynamic val) =>
      val == null || (val is String && val.isEmpty) ? 'Wajib dipilih' : null;

  List<Map<String, dynamic>> riwayatList = [];

  Bumil? bumil;

  @override
  void initState() {
    context.read<SubmitRiwayatCubit>().setInitial();
    // Inisialisasi FormValidator
    _formValidator = FormValidator(fieldKeys: _fieldKeys);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bumil = context.watch<SelectedBumilCubit>().state;
  }

  // **PERUBAHAN 2: LOGIKA DINAMIS GLOBAL KEY**
  void _updateKeys(int index) {
    // Daftarkan semua field wajib
    const requiredFields = [
      'tgl_lahir',
      'status_bayi',
      'status_lahir',
      'status_term',
      'tempat',
      'penolong',
    ];

    for (var fieldName in requiredFields) {
      final keyName = '${fieldName}_$index';
      if (!_fieldKeys.containsKey(keyName)) {
        _fieldKeys[keyName] = GlobalKey();
      }
    }
  }

  void _addRiwayat() {
    setState(() {
      riwayatList.add({
        'tgl_lahir': DateTime(DateTime.now().year - 1),
        'berat_bayi': '',
        'komplikasi': '',
        'panjang_bayi': '',
        'penolong': '',
        'penolongLainnya': '',
        'status_bayi': '',
        'status_lahir': '',
        'status_term': '',
        'tempat': '',
      });
      // Update keys untuk riwayat yang baru ditambahkan
      _updateKeys(riwayatList.length - 1);
    });
  }

  void _removeRiwayat(int index) {
    setState(() {
      riwayatList.removeAt(index);

      // Hapus semua keys lama
      _fieldKeys.clear();

      // Regenerasi semua keys untuk memastikan indeksnya benar
      for (int i = 0; i < riwayatList.length; i++) {
        _updateKeys(i);
      }
    });
  }

  Future<void> _submitData() async {
    // **PERUBAHAN 3: GANTI VALIDASI MANUAL DENGAN VALIDATE AND SCROLL**
    _formValidator.reset();

    if (!_formValidator.validateAndScroll(_formKey, context)) {
      return;
    }

    _formKey.currentState!.save();

    context.read<SubmitRiwayatCubit>().addRiwayat(
      bumilId: bumil!.idBumil,
      riwayatList: riwayatList,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(
        title: Text('Riwayat Kehamilan'),
        hideBackButton: widget.state == 'instantUpdate',
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...riwayatList.asMap().entries.map((entry) {
                int index = entry.key;
                var data = entry.value;

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
                        Utils.sectionTitle('Riwayat Kehamilan ${index + 1}'),
                        DatePickerFormField(
                          key: getKey('tgl_lahir'), // **Key Dinamis**
                          labelText: 'Tanggal Lahir',
                          prefixIcon: Icons.calendar_today,
                          value: data['tgl_lahir'],
                          initialDate: DateTime(DateTime.now().year - 1),
                          context: context,
                          onDateSelected: (date) {
                            setState(() {
                              data['tgl_lahir'] = date;
                            });
                          },
                          // **Wrap Validator**
                          validator: (val) =>
                              wrap('tgl_lahir', val, _requiredObjectValidator),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Berat Bayi',
                          icon: Icons.monitor_weight,
                          onSaved: (val) => data['berat_bayi'] = val,
                          isNumber: true,
                          suffixText: 'gram',
                          // Tidak wajib diisi
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Panjang Bayi',
                          icon: Icons.straighten,
                          onSaved: (val) => data['panjang_bayi'] = val,
                          isNumber: true,
                          suffixText: 'cm',
                          // Tidak wajib diisi
                        ),
                        const SizedBox(height: 12),
                        _buildPenolongField(
                          data,
                          index,
                        ), // Field dengan sub-field
                        const SizedBox(height: 12),
                        DropdownField(
                          key: getKey('status_bayi'), // **Key Dinamis**
                          label: 'Status Bayi',
                          icon: Icons.child_care,
                          items: Constants.statusBayiList,
                          value: data['status_bayi'].isNotEmpty
                              ? data['status_bayi']
                              : null,
                          onChanged: (newValue) {
                            setState(() {
                              data['status_bayi'] = newValue ?? '';
                            });
                          },
                          // **Wrap Validator**
                          validator: (val) => wrap(
                            'status_bayi',
                            val,
                            _requiredObjectValidator,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownField(
                          key: getKey('status_lahir'), // **Key Dinamis**
                          label: 'Status Lahir',
                          icon: Icons.pregnant_woman,
                          items: Constants.caraLahirList,
                          value: data['status_lahir'].isNotEmpty
                              ? data['status_lahir']
                              : null,
                          onChanged: (newValue) {
                            setState(() {
                              data['status_lahir'] = newValue ?? '';
                            });
                          },
                          // **Wrap Validator Kondisional**
                          validator: (val) {
                            if (data['status_bayi'] != 'Abortus') {
                              return wrap(
                                'status_lahir',
                                val,
                                _requiredObjectValidator,
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownField(
                          key: getKey('status_term'), // **Key Dinamis**
                          label: 'Status Kehamilan',
                          icon: Icons.date_range,
                          items: Constants.statusKehamilanList,
                          value: data['status_term'].isNotEmpty
                              ? data['status_term']
                              : null,
                          onChanged: (newValue) {
                            setState(() {
                              data['status_term'] = newValue ?? '';
                            });
                          },
                          // **Wrap Validator Kondisional**
                          validator: (val) {
                            if (data['status_bayi'] != 'Abortus') {
                              return wrap(
                                'status_term',
                                val,
                                _requiredObjectValidator,
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownField(
                          key: getKey('tempat'), // **Key Dinamis**
                          label: 'Tempat Persalinan',
                          icon: Icons.home,
                          items: Constants.tempatList,
                          value: data['tempat'].isNotEmpty
                              ? data['tempat']
                              : null,
                          onChanged: (newValue) {
                            setState(() {
                              data['tempat'] = newValue ?? '';
                            });
                          },
                          // **Wrap Validator**
                          validator: (val) =>
                              wrap('tempat', val, _requiredObjectValidator),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Komplikasi',
                          icon: Icons.local_hospital,
                          isMultiline: true,
                          onSaved: (val) => data['komplikasi'] = val,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: context.themeColors.error,
                            ),
                            onPressed: () => _removeRiwayat(index),
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
                  onPressed: _addRiwayat,
                  icon: Icons.add,
                  label: 'Tambah Riwayat',
                  loadingLabel: '',
                  secondaryButton: true,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: BlocConsumer<SubmitRiwayatCubit, SubmitiwayatState>(
                  listener: (context, state) {
                    if (state is SubmitRiwayatSuccess) {
                      if (riwayatList.isNotEmpty) {
                        Snackbar.show(
                          context,
                          message: 'Riwayat berhasil disimpan',
                          type: SnackbarType.success,
                        );
                      }

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
                        message: state.message,
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
                      label: riwayatList.isEmpty ? 'Tanpa Riwayat' : 'Simpan',
                      loadingLabel: 'Menyimpan...',
                      icon: Icons.save,
                      onPressed: _submitData,
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

  Widget _buildPenolongField(Map<String, dynamic> data, int index) {
    // Cek apakah user memilih "Lainnya"
    bool isLainnya = data['penolong'] == 'Lainnya';
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
        DropdownButtonFormField<String>(
          key: getKey('penolong'), // **Key Dinamis**
          value:
              data['penolong'] != null &&
                  Constants.penolongList.contains(data['penolong'])
              ? data['penolong']
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
              data['penolong'] = newValue ?? '';
              if (newValue != 'Lainnya') {
                data['penolongLainnya'] = null; // sembunyikan field tambahan
              }
            });
          },
          // **Wrap Validator** untuk dropdown utama
          validator: (val) => wrap('penolong', val, _requiredObjectValidator),
        ),
        if (isLainnya) const SizedBox(height: 8),
        if (isLainnya)
          TextFormField(
            // Field 'Lainnya' tidak perlu GlobalKey dinamis baru karena terikat pada penolong.
            decoration: const InputDecoration(
              labelText: 'Penolong Lainnya',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (val) => data['penolong'] = val, // Simpan di 'penolong'
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Wajib diisi';
              }
              return null;
            },
          ),
      ],
    );
  }
}
