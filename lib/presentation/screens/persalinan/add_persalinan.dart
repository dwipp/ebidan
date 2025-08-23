import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/common/dropdown_field.dart';
import 'package:ebidan/common/textfield.dart';
import 'package:ebidan/data/models/persalinan_model.dart';
import 'package:ebidan/data/models/riwayat_model.dart';
import 'package:ebidan/logic/utility/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:ebidan/common/date_time_picker_field.dart';

class AddPersalinanScreen extends StatefulWidget {
  final String kehamilanId;
  final String bumilId;
  final List<String> resti;
  const AddPersalinanScreen({
    super.key,
    required this.bumilId,
    required this.kehamilanId,
    required this.resti,
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
  ];

  final List<String> _caraAbortusList = ['Kuretase', 'Mandiri'];
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

  Future<void> tambahRiwayatBumil(
    String bumilId,
    List<Riwayat> riwayats,
  ) async {
    final docRef = FirebaseFirestore.instance.collection('bumil').doc(bumilId);

    await docRef.set({
      'riwayat': FieldValue.arrayUnion(riwayats.map((e) => e.toMap()).toList()),
    }, SetOptions(merge: true));
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final docRef = FirebaseFirestore.instance
        .collection('kehamilan')
        .doc(widget.kehamilanId);

    try {
      await docRef.update({
        'persalinan': persalinanList.map((e) => e.toMap()).toList(),
      });

      List<Riwayat> riwayats = [];
      for (var persalinan in persalinanList) {
        print('riwayat');
        final riwayat = Riwayat(
          tahun: persalinan.tglPersalinan?.year ?? 0,
          beratBayi: int.tryParse(persalinan.beratLahir ?? '0') ?? 0,
          komplikasi: widget.resti.join(", "),
          panjangBayi: persalinan.panjangBadan ?? '0',
          penolong: persalinan.penolong ?? '-',
          statusBayi: persalinan.statusBayi ?? '-',
          statusLahir: persalinan.cara ?? '-',
          statusTerm: getStatusKehamilan(
            int.tryParse(persalinan.umurKehamilan ?? '-1') ?? -1,
          ),
          tempat: persalinan.tempat ?? '-',
        );
        riwayats.add(riwayat);
      }

      await tambahRiwayatBumil(widget.bumilId, riwayats);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data persalinan berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.homepage,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Persalinan')),
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
                        DropdownField(
                          label: 'Cara Persalinan',
                          icon: Icons.pregnant_woman,
                          items: data.statusBayi != "Abortus"
                              ? _caraLahirList
                              : _caraAbortusList,
                          value: data.cara,
                          onChanged: (newValue) {
                            setState(() {
                              data.cara = newValue ?? '';
                            });
                          },
                          validator: (val) => val == null || val.isEmpty
                              ? 'Wajib dipilih'
                              : null,
                        ),
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
                child: ElevatedButton.icon(
                  onPressed: _addPersalinan,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Persalinan (kembar)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitData,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
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
}
