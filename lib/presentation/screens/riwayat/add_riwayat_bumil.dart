import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/presentation/widgets/dropdown_field.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/presentation/widgets/year_picker_field.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/riwayat/cubit/submit_riwayat_cubit.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddRiwayatBumilScreen extends StatefulWidget {
  final String state;
  const AddRiwayatBumilScreen({super.key, required this.state});

  @override
  State<AddRiwayatBumilScreen> createState() => _AddRiwayatBumilState();
}

class _AddRiwayatBumilState extends State<AddRiwayatBumilScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> riwayatList = [];

  final List<String> statusBayiList = ['Hidup', 'Mati', 'Abortus'];

  final List<String> statusKehamilanList = ['Aterm', 'Preterm', 'Postterm'];

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

  final List<String> statusLahirList = [
    'Spontan Belakang Kepala',
    'Section Caesarea (SC)',
  ];

  Bumil? bumil;

  @override
  void initState() {
    context.read<SubmitRiwayatCubit>().setInitial();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bumil = context.watch<SelectedBumilCubit>().state;
  }

  void _addRiwayat() {
    setState(() {
      riwayatList.add({
        'tahun': '',
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
    });
  }

  void _removeRiwayat(int index) {
    setState(() {
      riwayatList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title: 'Riwayat Bumil'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...riwayatList.asMap().entries.map((entry) {
                int index = entry.key;
                var data = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        YearPickerField(
                          contextField: context,
                          label: 'Tahun',
                          icon: Icons.calendar_today,
                          initialYear: data['tahun'],
                          onSaved: (year) => data['tahun'] = year,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Berat Bayi',
                          icon: Icons.monitor_weight,
                          onSaved: (val) => data['berat_bayi'] = val,
                          isNumber: true,
                          suffixText: 'gram',
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Panjang Bayi',
                          icon: Icons.straighten,
                          onSaved: (val) => data['panjang_bayi'] = val,
                          isNumber: true,
                          suffixText: 'cm',
                        ),
                        const SizedBox(height: 12),
                        _buildPenolongField(data),
                        const SizedBox(height: 12),
                        DropdownField(
                          label: 'Status Bayi',
                          icon: Icons.child_care,
                          items: statusBayiList,
                          value: data['status_bayi'].isNotEmpty
                              ? data['status_bayi']
                              : null,
                          onChanged: (newValue) {
                            setState(() {
                              data['status_bayi'] = newValue ?? '';
                            });
                          },
                          validator: (val) => val == null || val.isEmpty
                              ? 'Wajib dipilih'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownField(
                          label: 'Status Lahir',
                          icon: Icons.pregnant_woman,
                          items: statusLahirList,
                          value: data['status_lahir'].isNotEmpty
                              ? data['status_lahir']
                              : null,
                          onChanged: (newValue) {
                            setState(() {
                              data['status_lahir'] = newValue ?? '';
                            });
                          },
                          validator: (val) => val == null || val.isEmpty
                              ? 'Wajib dipilih'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownField(
                          label: 'Status Kehamilan',
                          icon: Icons.date_range,
                          items: statusKehamilanList,
                          value: data['status_term'].isNotEmpty
                              ? data['status_term']
                              : null,
                          onChanged: (newValue) {
                            setState(() {
                              data['status_term'] = newValue ?? '';
                            });
                          },
                          validator: (val) => val == null || val.isEmpty
                              ? 'Wajib dipilih'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownField(
                          label: 'Tempat Persalinan',
                          icon: Icons.home,
                          items: tempatList,
                          value: data['tempat'].isNotEmpty
                              ? data['tempat']
                              : null,
                          onChanged: (newValue) {
                            setState(() {
                              data['tempat'] = newValue ?? '';
                            });
                          },
                          validator: (val) => val == null || val.isEmpty
                              ? 'Wajib dipilih'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Komplikasi',
                          icon: Icons.local_hospital,
                          onSaved: (val) => data['komplikasi'] = val,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
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
                      label: 'Simpan',
                      loadingLabel: 'Menyimpan...',
                      icon: Icons.save,
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        _formKey.currentState!.save();

                        context.read<SubmitRiwayatCubit>().addRiwayat(
                          bumilId: bumil!.idBumil,
                          riwayatList: riwayatList,
                        );
                      },
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

  Widget _buildPenolongField(Map<String, dynamic> data) {
    // Cek apakah user memilih "Lainnya"
    bool isLainnya = data['penolong'] == 'Lainnya';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value:
              data['penolong'] != null &&
                  penolongList.contains(data['penolong'])
              ? data['penolong']
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
              data['penolong'] = newValue ?? '';
              if (newValue == 'Lainnya') {
                data['penolongLainnya'] = ''; // aktifkan field tambahan
              } else {
                data['penolongLainnya'] = null; // sembunyikan field tambahan
              }
            });
          },
          validator: null, // dropdown tidak wajib
        ),
        if (isLainnya) const SizedBox(height: 8),
        if (isLainnya)
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Penolong Lainnya',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (val) => data['penolongLainnya'] = val,
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
