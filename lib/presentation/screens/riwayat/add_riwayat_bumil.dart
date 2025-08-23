import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/common/dropdown_field.dart';
import 'package:ebidan/common/textfield.dart';
import 'package:ebidan/common/year_picker_field.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';

class AddRiwayatBumilScreen extends StatefulWidget {
  final String bumilId;
  final int age;
  const AddRiwayatBumilScreen({
    super.key,
    required this.bumilId,
    required this.age,
  });

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

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final docRef = FirebaseFirestore.instance
        .collection('bumil')
        .doc(widget.bumilId);

    int hidup = 0;
    int mati = 0;
    int abortus = 0;
    int beratRendah = 0;
    int? latestYear; // untuk simpan tahun terbaru

    List<Map<String, dynamic>> riwayatListFinal = [];

    for (var item in riwayatList) {
      if (item['tahun'] != '') {
        final tahun = int.tryParse(item['tahun']);
        if (tahun == null) continue;

        // hitung jumlah berdasarkan status_bayi
        if (item['status_bayi'] == 'hidup') {
          hidup++;
        } else if (item['status_bayi'] == 'mati') {
          mati++;
        } else if (item['status_bayi'] == 'abortus') {
          abortus++;
        }

        final beratBayi = int.parse(item['berat_bayi']);
        if (beratBayi < 2500) {
          beratRendah++;
        }

        riwayatListFinal.add({
          'tahun': tahun,
          'berat_bayi': beratBayi,
          'komplikasi': item['komplikasi'],
          'panjang_bayi': item['panjang_bayi'],
          'penolong': item['penolong'] == 'Lainnya'
              ? item['penolongLainnya']
              : item['penolong'],
          'status_bayi': item['status_bayi'],
          'status_lahir': item['status_lahir'],
          'status_term': item['status_term'],
          'tempat': item['tempat'],
        });

        // cek apakah tahun lebih besar dari latest
        if (latestYear == null || tahun > latestYear) {
          latestYear = tahun;
        }
      }
    }

    if (riwayatListFinal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data bumil disimpan tanpa riwayat kehamilan'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        AppRouter.pendataanKehamilan,
        arguments: {
          'bumilId': widget.bumilId,
          'age': widget.age,
          'latestHistoryYear': null,
          'jumlahRiwayat': 0,
          'jumlahPara': 0,
          'julmahAbortus': 0,
          'jumlahBeratRendah': 0,
        },
      );
    } else {
      try {
        // simpan sebagai array of maps
        await docRef.update({'riwayat': riwayatListFinal});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Riwayat berhasil disimpan'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacementNamed(
            context,
            AppRouter.pendataanKehamilan,
            arguments: {
              'bumilId': widget.bumilId,
              'age': widget.age,
              'latestHistoryYear': latestYear,
              'jumlahRiwayat': riwayatListFinal.length,
              'jumlahPara': hidup + mati,
              'jumlahAbortus': abortus,
              'jumlahBeratRendah': beratRendah,
            },
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan riwayat: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Bumil'),
        automaticallyImplyLeading: false,
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
                        CustomTextField(
                          label: 'Berat Bayi',
                          icon: Icons.monitor_weight,
                          onSaved: (val) => data['berat_bayi'] = val,
                          isNumber: true,
                          suffixText: 'gram',
                        ),
                        CustomTextField(
                          label: 'Panjang Bayi',
                          icon: Icons.straighten,
                          onSaved: (val) => data['panjang_bayi'] = val,
                          isNumber: true,
                          suffixText: 'cm',
                        ),
                        _buildPenolongField(data),
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
                        CustomTextField(
                          label: 'Komplikasi',
                          icon: Icons.local_hospital,
                          onSaved: (val) => data['komplikasi'] = val,
                        ),
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
                child: ElevatedButton.icon(
                  onPressed: _addRiwayat,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Riwayat'),
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
