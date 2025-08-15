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
                        _buildTextField(
                          label: 'Penolong',
                          icon: Icons.person,
                          onSaved: (val) => data['penolong'] = val,
                        ),
                        _buildTextField(
                          label: 'Status Bayi',
                          icon: Icons.child_care,
                          onSaved: (val) => data['status_bayi'] = val,
                        ),
                        _buildTextField(
                          label: 'Status Lahir',
                          icon: Icons.pregnant_woman,
                          onSaved: (val) => data['status_lahir'] = val,
                        ),
                        _buildTextField(
                          label: 'Status Term',
                          icon: Icons.date_range,
                          onSaved: (val) => data['status_term'] = val,
                        ),
                        _buildTextField(
                          label: 'Tempat',
                          icon: Icons.home,
                          onSaved: (val) => data['tempat'] = val,
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
              ElevatedButton.icon(
                onPressed: _addRiwayat,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Riwayat'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: const Text('Simpan'),
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
    required String initialYear, // ubah ke String
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
        int selectedYear = initialYear.isNotEmpty
            ? int.tryParse(initialYear) ?? currentYear
            : currentYear;

        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Pilih Tahun'),
              content: SizedBox(
                height: 200,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  onSelectedItemChanged: (index) {
                    selectedYear = currentYear - index;
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      final year = currentYear - index;
                      return Center(
                        child: Text(
                          '$year',
                          style: const TextStyle(fontSize: 20),
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
                    controller.text = selectedYear.toString();
                    onSaved(selectedYear.toString());
                  },
                  child: const Text('Pilih'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
