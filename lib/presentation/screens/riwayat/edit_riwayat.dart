import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/data/models/riwayat_model.dart';
import 'package:ebidan/presentation/widgets/date_picker_field.dart';
import 'package:ebidan/presentation/widgets/dropdown_field.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/riwayat/cubit/submit_riwayat_cubit.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/state_management/riwayat/cubit/selected_riwayat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditRiwayatBumilScreen extends StatefulWidget {
  final String state;
  const EditRiwayatBumilScreen({super.key, required this.state});

  @override
  State<EditRiwayatBumilScreen> createState() => _EditRiwayatBumilState();
}

class _EditRiwayatBumilState extends State<EditRiwayatBumilScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _statusBayi;
  final List<String> statusBayiList = ['Hidup', 'Mati', 'Abortus'];

  String? _statusKehamilan;
  final List<String> statusKehamilanList = ['Aterm', 'Preterm', 'Postterm'];

  String? _penolong;
  final List<String> penolongList = [
    'Bidan',
    'Dokter',
    'Dukun Kampung',
    'Lainnya',
  ];

  String? _tempat;
  final List<String> tempatList = [
    'Rumah Sakit',
    'Poskesdes',
    'Polindes',
    'Rumah',
    'Jalan',
  ];

  String? _statusLahir;
  final List<String> statusLahirList = [
    'Spontan Belakang Kepala',
    'Section Caesarea (SC)',
  ];
  DateTime? _tglLahir;
  late TextEditingController _beratBayiController;
  late TextEditingController _komplikasiController;
  late TextEditingController _panjangBayiController;
  late TextEditingController _penolongLainnyaController;

  Bumil? bumil;
  Riwayat? riwayat;

  @override
  void initState() {
    context.read<SubmitRiwayatCubit>().setInitial();
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
      if (penolongList.contains(_penolong)) {
        _penolongLainnyaController.text = '';
      } else {
        _penolongLainnyaController.text = _penolong!;
        _penolong = 'Lainnya';
      }
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
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
      appBar: PageHeader(title: 'Perbaharui Riwayat'),
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
                label: 'Berat Bayi',
                icon: Icons.monitor_weight,
                controller: _beratBayiController,
                isNumber: true,
                suffixText: 'gram',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Panjang Bayi',
                icon: Icons.straighten,
                controller: _panjangBayiController,
                isNumber: true,
                suffixText: 'cm',
              ),
              const SizedBox(height: 12),
              DropdownField(
                label: 'Status Bayi',
                icon: Icons.child_care,
                items: statusBayiList,
                value: _statusBayi,
                onChanged: (newValue) {
                  setState(() {
                    _statusBayi = newValue;
                  });
                },
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Persalinan'),
              DatePickerFormField(
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
              ),
              DropdownField(
                label: 'Status Lahir',
                icon: Icons.pregnant_woman,
                items: statusLahirList,
                value: _statusLahir,
                onChanged: (newValue) {
                  setState(() {
                    _statusLahir = newValue;
                  });
                },
                validator: (val) {
                  if (_statusBayi != 'Abortus') {
                    if (val == null || val.isEmpty) {
                      return 'Wajib dipilih';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownField(
                label: 'Status Kehamilan',
                icon: Icons.date_range,
                items: statusKehamilanList,
                value: _statusKehamilan,
                onChanged: (newValue) {
                  setState(() {
                    _statusKehamilan = newValue;
                  });
                },
                validator: (val) {
                  if (_statusBayi != 'Abortus') {
                    if (val == null || val.isEmpty) {
                      return 'Wajib dipilih';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownField(
                label: 'Tempat Persalinan',
                icon: Icons.home,
                items: tempatList,
                value: _tempat,
                onChanged: (newValue) {
                  setState(() {
                    _tempat = newValue;
                  });
                },
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              _buildPenolongField(),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Komplikasi',
                icon: Icons.local_hospital,
                controller: _komplikasiController,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: BlocConsumer<SubmitRiwayatCubit, SubmitiwayatState>(
                  listener: (context, state) {
                    if (state is SubmitRiwayatSuccess) {
                      Utils.showSnackBar(
                        context,
                        content: 'Riwayat berhasil disimpan',
                        isSuccess: true,
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
                      Utils.showSnackBar(
                        context,
                        content: 'Gagal: ${state.message}',
                        isSuccess: false,
                      );
                    } else if (state is AddRiwayatEmpty) {
                      Utils.showSnackBar(
                        context,
                        content: 'Data bumil disimpan tanpa riwayat kehamilan',
                        isSuccess: true,
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
}
