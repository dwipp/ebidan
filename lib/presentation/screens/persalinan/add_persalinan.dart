import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/date_picker_field.dart';
import 'package:ebidan/presentation/widgets/dropdown_field.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/data/models/persalinan_model.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/state_management/persalinan/cubit/add_persalinan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:ebidan/presentation/widgets/date_time_picker_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddPersalinanScreen extends StatefulWidget {
  final String kehamilanId;
  final DateTime? hpht;
  final String bumilId;
  final List<String> resti;
  const AddPersalinanScreen({
    super.key,
    required this.bumilId,
    required this.kehamilanId,
    required this.resti,
    this.hpht,
  });

  @override
  State<AddPersalinanScreen> createState() => _AddPersalinanState();
}

class _AddPersalinanState extends State<AddPersalinanScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Persalinan> persalinanList = [];

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

  @override
  void initState() {
    super.initState();
    context.read<AddPersalinanCubit>().setInitial();
    _addPersalinan();
  }

  void _addPersalinan() {
    setState(() {
      persalinanList.add(Persalinan.empty());
    });
  }

  void _removePersalinan(int index) {
    setState(() {
      persalinanList.removeAt(index);
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

  static int hitungUsiaKehamilan({
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
    // final hari = duration.inDays % 7;

    // return {
    //   'minggu': minggu,
    //   'hari': hari,
    // };

    return minggu;
  }

  Future<void> _submitData() async {
    print('submit');
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    context.read<AddPersalinanCubit>().addPersalinan(
      persalinanList,
      bumilId: widget.bumilId,
      kehamilanId: widget.kehamilanId,
      resti: widget.resti.join(", "),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title: 'Data Persalinan'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...persalinanList.asMap().entries.map((entry) {
                int index = entry.key;
                Persalinan data = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Utils.sectionTitle('Detail Kelahiran'),
                        DateTimePickerField(
                          labelText: 'Tanggal Persalinan',
                          prefixIcon: Icons.calendar_today,
                          onSaved: (dateTime) {
                            data.tglPersalinan = dateTime;
                          },
                          onDateSelected: (dateTime) {
                            if (widget.hpht != null) {
                              setState(() {
                                final usia = hitungUsiaKehamilan(
                                  hpht: widget.hpht!,
                                  tanggalPersalinan: dateTime,
                                );
                                data.umurKehamilanController.text = usia
                                    .toString();
                              });
                            }
                          },
                          validator: (val) =>
                              val == null ? 'Wajib diisi' : null,
                          context: context,
                        ),
                        DropdownField(
                          label: 'Status Bayi',
                          icon: Icons.child_care,
                          items: statusBayiList,
                          value: data.statusBayi,
                          onChanged: (newValue) {
                            setState(() {
                              data.statusBayi = newValue ?? '';
                            });
                          },
                          validator: (val) => val == null || val.isEmpty
                              ? 'Wajib dipilih'
                              : null,
                        ),
                        CustomTextField(
                          label: 'Berat Lahir',
                          icon: Icons.monitor_weight,
                          onSaved: (val) => data.beratLahir = val,
                          isNumber: true,
                          suffixText: 'gram',
                          disable: data.statusBayi == "Abortus",
                          validator: (val) {
                            if (data.statusBayi != "Abortus") {
                              if (val == null || val.isEmpty) {
                                return 'Wajib diisi';
                              }
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          label: 'Lingkar Kepala',
                          icon: Icons.circle_outlined,
                          onSaved: (val) => data.lingkarKepala = val,
                          isNumber: true,
                          suffixText: 'cm',
                          disable: data.statusBayi == "Abortus",
                          validator: (val) {
                            if (data.statusBayi != "Abortus") {
                              if (val == null || val.isEmpty) {
                                return 'Wajib diisi';
                              }
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          label: 'Panjang Badan',
                          icon: Icons.straighten,
                          onSaved: (val) => data.panjangBadan = val,
                          isNumber: true,
                          suffixText: 'cm',
                          disable: data.statusBayi == "Abortus",
                          validator: (val) {
                            if (data.statusBayi != "Abortus") {
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
                          onSaved: (val) => data.umurKehamilan = val,
                          isNumber: true,
                          readOnly: true,
                          controller: data.umurKehamilanController,
                          suffixText: 'minggu',
                          validator: (val) =>
                              val!.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        Utils.sectionTitle('Kondisi Kelahiran'),
                        DropdownField(
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
                          validator: (val) {
                            if (data.statusBayi != "Abortus") {
                              if (val == null || val.isEmpty) {
                                return 'Wajib dipilih';
                              }
                            }
                            return null;
                          },
                        ),
                        // DropdownField(
                        //   label: 'Cara Persalinan',
                        //   icon: Icons.pregnant_woman,
                        //   items: data.statusBayi != "Abortus"
                        //       ? _caraLahirList
                        //       : _caraAbortusList,
                        //   value: data.cara,
                        //   onChanged: (newValue) {
                        //     setState(() {
                        //       data.cara = newValue ?? '';
                        //     });
                        //   },
                        //   validator: (val) => val == null || val.isEmpty
                        //       ? 'Wajib dipilih'
                        //       : null,
                        // ),
                        _buildCaraMelahirkanField(data),
                        _buildPenolongField(data),
                        DropdownField(
                          label: 'Tempat Persalinan',
                          icon: Icons.home,
                          items: tempatList,
                          value: data.tempat,
                          onChanged: (newValue) {
                            setState(() {
                              data.tempat = newValue ?? '';
                            });
                          },
                          validator: (val) => val == null || val.isEmpty
                              ? 'Wajib dipilih'
                              : null,
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
                            icon: const Icon(Icons.delete, color: Colors.red),
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
                child: BlocConsumer<AddPersalinanCubit, AddPersalinanState>(
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

  Widget _buildPenolongField(Persalinan data) {
    bool isLainnya = data.penolong == 'Lainnya';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownField(
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
          validator: (val) => val == null ? 'Wajib dipilih' : null,
        ),
        if (isLainnya) const SizedBox(height: 8),
        if (isLainnya)
          CustomTextField(
            label: 'Penolong Lainnya',
            icon: Icons.person_outline,
            onSaved: (val) => data.penolong = val,
            validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
          ),
      ],
    );
  }

  Widget _buildCaraMelahirkanField(Persalinan data) {
    bool isLainnya = data.cara == 'Lainnya';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownField(
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
          validator: (val) =>
              val == null || val.isEmpty ? 'Wajib dipilih' : null,
        ),
        if (isLainnya) const SizedBox(height: 8),
        if (isLainnya)
          CustomTextField(
            label: 'Cara Persalinan Lainnya',
            icon: Icons.pregnant_woman,
            onSaved: (val) => data.cara = val,
            validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
          ),
      ],
    );
  }
}
