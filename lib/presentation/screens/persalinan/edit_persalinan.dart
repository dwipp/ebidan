import 'package:ebidan/data/models/kehamilan_model.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/date_picker_field.dart';
import 'package:ebidan/presentation/widgets/dropdown_field.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
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

class EditPersalinanScreen extends StatefulWidget {
  const EditPersalinanScreen({super.key});

  @override
  State<EditPersalinanScreen> createState() => _EditPersalinanState();
}

class _EditPersalinanState extends State<EditPersalinanScreen> {
  final _formKey = GlobalKey<FormState>();

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

  @override
  void initState() {
    super.initState();
    context.read<SubmitPersalinanCubit>().setInitial();
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
    print('submit');
    if (!_formKey.currentState!.validate()) return;
    if (persalinan == null) return;
    // _formKey.currentState!.save();
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

    // context.read<AddPersalinanCubit>().addPersalinan(
    //   persalinanList,
    //   bumilId: bumil!.idBumil,
    //   kehamilanId: bumil!.latestKehamilanId!,
    //   resti: bumil!.latestKehamilanResti!.join(", "),
    // );
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
      appBar: PageHeader(title: 'Perbaharui Data Persalinan'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.sectionTitle('Detail Persalinan'),
              DateTimePickerField(
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
                      // data.umurKehamilanController.text = usia;
                      _umurKehamilanController.text = usia;
                    });
                  }
                },
                validator: (val) => val == null ? 'Wajib diisi' : null,
                context: context,
              ),
              DropdownField(
                label: 'Status Bayi',
                icon: Icons.child_care,
                items: statusBayiList,
                value: _statusBayi,
                onChanged: (newValue) {
                  setState(() {
                    _statusBayi = newValue ?? '';
                  });
                },
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib dipilih' : null,
              ),
              CustomTextField(
                controller: _beratBayiController,
                label: 'Berat Lahir',
                icon: Icons.monitor_weight,
                isNumber: true,
                suffixText: 'gram',
                disable: _statusBayi == "Abortus",
                validator: (val) {
                  if (_statusBayi != "Abortus") {
                    if (val == null || val.isEmpty) {
                      return 'Wajib diisi';
                    }
                  }
                  return null;
                },
              ),
              CustomTextField(
                controller: _lingkarKepalaController,
                label: 'Lingkar Kepala',
                icon: Icons.circle_outlined,
                isNumber: true,
                suffixText: 'cm',
                disable: _statusBayi == "Abortus",
                validator: (val) {
                  if (_statusBayi != "Abortus") {
                    if (val == null || val.isEmpty) {
                      return 'Wajib diisi';
                    }
                  }
                  return null;
                },
              ),
              CustomTextField(
                controller: _panjangBadanController,
                label: 'Panjang Badan',
                icon: Icons.straighten,
                isNumber: true,
                suffixText: 'cm',
                disable: _statusBayi == "Abortus",
                validator: (val) {
                  if (_statusBayi != "Abortus") {
                    if (val == null || val.isEmpty) {
                      return 'Wajib diisi';
                    }
                  }
                  return null;
                },
              ),
              CustomTextField(
                label: 'Umur Kehamilan',
                icon: Icons.date_range,
                isNumber: true,
                readOnly: true,
                controller: _umurKehamilanController,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Utils.sectionTitle('Kondisi Persalinan'),
              DropdownField(
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
                    if (val == null || val.isEmpty) {
                      return 'Wajib dipilih';
                    }
                  }
                  return null;
                },
              ),
              _buildCaraMelahirkanField(),
              _buildPenolongField(),
              DropdownField(
                label: 'Tempat Persalinan',
                icon: Icons.home,
                items: tempatList,
                value: _tempatBersalin,
                onChanged: (newValue) {
                  setState(() {
                    _tempatBersalin = newValue ?? '';
                  });
                },
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib dipilih' : null,
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
                          Utils.showSnackBar(
                            context,
                            content: 'Data persalinan berhasil disimpan',
                            isSuccess: true,
                          );
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRouter.homepage,
                            (route) => false,
                          );
                        } else if (state is AddPersalinanFailure) {
                          Utils.showSnackBar(
                            context,
                            content: 'Gagal: ${state.message}',
                            isSuccess: true,
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
          validator: null, // dropdown tidak wajib
        ),
        if (isLainnya) const SizedBox(height: 8),
        if (isLainnya)
          CustomTextField(
            label: 'Penolong Lainnya',
            icon: Icons.person_outline,
            controller: _penolongLainnyaController,
            validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
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
          label: 'Cara Persalinan',
          icon: Icons.pregnant_woman,
          items: _statusBayi != "Abortus" ? _caraLahirList : _caraAbortusList,
          value: _caraBersalin,
          onChanged: (newValue) {
            setState(() {
              _caraBersalin = newValue;
            });
          },
          validator: (val) =>
              val == null || val.isEmpty ? 'Wajib dipilih' : null,
        ),
        if (isLainnya) const SizedBox(height: 8),
        if (isLainnya)
          CustomTextField(
            label: 'Cara Persalinan Lainnya',
            icon: Icons.pregnant_woman,
            controller: _caraLainnyaController,
            validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
          ),
      ],
    );
  }
}
