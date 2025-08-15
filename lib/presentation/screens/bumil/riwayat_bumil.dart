import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';

class RiwayatBumilScreen extends StatefulWidget {
  final String bumilId;
  const RiwayatBumilScreen({super.key, required this.bumilId});

  @override
  State<RiwayatBumilScreen> createState() => _RiwayatBumilState();
}

class _RiwayatBumilState extends State<RiwayatBumilScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> riwayatList = [];

  final List<String> statusBayiList = ['Hidup', 'Mati', 'Abortus'];

  final List<String> statusKehamilanList = ['Aterm', 'Preterm', 'Postterm'];

  final List<String> penolongList = [
    'Dukun Kampung',
    'Tenaga Kesehatan',
    'Lainnya',
  ];

  final List<String> tempatList = ['Rumah', 'RS', 'Jalan', 'Lainnya'];

  final List<String> statusLahirList = ['Spontan', 'SC', 'Lainnya'];

  void _addRiwayat() {
    setState(() {
      riwayatList.add({
        'tahun': '',
        'berat_bayi': '',
        'komplikasi': '',
        'panjang_bayi': '',
        'penolong': '',
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

    Map<String, dynamic> riwayatMap = {};
    for (var item in riwayatList) {
      if (item['tahun'] != '') {
        riwayatMap[item['tahun']] = {
          'berat_bayi': item['berat_bayi'],
          'komplikasi': item['komplikasi'],
          'panjang_bayi': item['panjang_bayi'],
          'penolong': item['penolong'],
          'status_bayi': item['status_bayi'],
          'status_lahir': item['status_lahir'],
          'status_term': item['status_term'],
          'tempat': item['tempat'],
        };
      }
    }

    if (riwayatMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data bumil di simpan tanpa riwayat kehamilan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushReplacementNamed(AppRouter.homepage);
    } else {
      try {
        await docRef.update({'riwayat': riwayatMap});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Riwayat berhasil disimpan'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushReplacementNamed(AppRouter.homepage);
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

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Function(String) onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      textCapitalization: TextCapitalization.sentences,
      validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
      onSaved: (val) => onSaved(val ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Bumil')),
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
                        _buildYearPickerField(
                          context: context,
                          label: 'Tahun',
                          icon: Icons.calendar_today,
                          initialYear: data['tahun'],
                          onSaved: (year) => data['tahun'] = year,
                        ),
                        _buildTextField(
                          label: 'Berat Bayi',
                          icon: Icons.monitor_weight,
                          onSaved: (val) => data['berat_bayi'] = val,
                        ),
                        _buildTextField(
                          label: 'Komplikasi',
                          icon: Icons.health_and_safety,
                          onSaved: (val) => data['komplikasi'] = val,
                        ),
                        _buildTextField(
                          label: 'Panjang Bayi',
                          icon: Icons.straighten,
                          onSaved: (val) => data['panjang_bayi'] = val,
                        ),
                        DropdownButtonFormField<String>(
                          value: data['penolong'].isNotEmpty
                              ? data['penolong']
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Penolong',
                            prefixIcon: Icon(Icons.person),
                          ),
                          items: penolongList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              data['penolong'] = newValue ?? '';
                            });
                          },
                          validator: (val) => val == null || val.isEmpty
                              ? 'Wajib dipilih'
                              : null,
                        ),
                        DropdownButtonFormField<String>(
                          value: data['status_bayi'].isNotEmpty
                              ? data['status_bayi']
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Status Bayi',
                            prefixIcon: Icon(Icons.child_care),
                          ),
                          items: statusBayiList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              data['status_bayi'] = newValue ?? '';
                            });
                          },
                          validator: (val) => val == null || val.isEmpty
                              ? 'Wajib dipilih'
                              : null,
                        ),
                        DropdownButtonFormField<String>(
                          value: data['status_lahir'].isNotEmpty
                              ? data['status_lahir']
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Status Lahir',
                            prefixIcon: Icon(Icons.pregnant_woman),
                          ),
                          items: statusLahirList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              data['status_lahir'] = newValue ?? '';
                            });
                          },
                          validator: (val) => val == null || val.isEmpty
                              ? 'Wajib dipilih'
                              : null,
                        ),
                        DropdownButtonFormField<String>(
                          value: data['status_term'].isNotEmpty
                              ? data['status_term']
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Status Kehamilan',
                            prefixIcon: Icon(Icons.date_range),
                          ),
                          items: statusKehamilanList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              data['status_term'] = newValue ?? '';
                            });
                          },
                          validator: (val) => val == null || val.isEmpty
                              ? 'Wajib dipilih'
                              : null,
                        ),
                        DropdownButtonFormField<String>(
                          value: data['tempat'].isNotEmpty
                              ? data['tempat']
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Tempat Persalinan',
                            prefixIcon: Icon(Icons.home),
                          ),
                          items: tempatList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              data['tempat'] = newValue ?? '';
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
                            onPressed: () => _removeRiwayat(index),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              // ElevatedButton.icon(
              //   onPressed: _addRiwayat,
              //   icon: const Icon(Icons.add),
              //   label: const Text('Tambah Riwayat'),
              // ),
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
              // ElevatedButton(
              //   onPressed: _submitData,
              //   child: const Text('Simpan'),
              // ),
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

  Widget _buildYearPickerField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String initialYear,
    required Function(String) onSaved,
  }) {
    final controller = TextEditingController(text: initialYear);

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      readOnly: true,
      validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
      onTap: () async {
        final currentYear = DateTime.now().year;
        const minYear = 1900;
        int tempSelectedYear = initialYear.isNotEmpty
            ? int.tryParse(initialYear) ?? currentYear
            : currentYear;

        await showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  title: const Text('Pilih Tahun'),
                  content: SizedBox(
                    height: 200,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 50,
                      onSelectedItemChanged: (index) {
                        setStateDialog(() {
                          tempSelectedYear = currentYear - index;
                        });
                      },
                      physics: const FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: currentYear - minYear + 1, // Batas tahun
                        builder: (context, index) {
                          final year = currentYear - index;
                          final isSelected = year == tempSelectedYear;

                          return Container(
                            decoration: isSelected
                                ? BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  )
                                : null,
                            alignment: Alignment.center,
                            child: Text(
                              '$year',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected ? Colors.blue : Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        controller.text = tempSelectedYear.toString();
                        onSaved(tempSelectedYear.toString());
                      },
                      child: const Text('Pilih'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
