import 'package:ebidan/common/date_time_picker_field.dart';
import 'package:ebidan/common/dropdown_field.dart';
import 'package:ebidan/common/textfield.dart';
import 'package:ebidan/logic/utility/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';

class AddPersalinanScreen extends StatefulWidget {
  final String kehamilanId;

  const AddPersalinanScreen({super.key, required this.kehamilanId});

  @override
  State<AddPersalinanScreen> createState() => _PersalinanScreenState();
}

class _PersalinanScreenState extends State<AddPersalinanScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController beratLahirController = TextEditingController();
  final TextEditingController lingkarKepalaController = TextEditingController();
  final TextEditingController panjangBadanController = TextEditingController();
  final TextEditingController umurKehamilanController = TextEditingController();

  DateTime? _tglPersalinan;

  String? _selectedCara;
  final List<String> _caraList = ['Sectio', 'Normal'];

  String? _selectedPenolong;
  final List<String> _penolongList = [
    'Dukun Kampung',
    'Dokter',
    'Bidan',
    'Lainnya',
  ];

  String? _selectedSex;
  final List<String> _sexList = ['Perempuan', 'Laki-laki'];

  String? _selectedTempat;
  final List<String> _tempatList = [
    'Rumah Sakit',
    'Poskesdes',
    'Polindes',
    'Rumah',
    'Jalan',
  ];

  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal lahir bayi wajib diisi')),
      );
      return;
    }

    final resultData = {
      'kehamilanId': widget.kehamilanId,
      'berat_lahir': beratLahirController.text,
      'cara': _selectedCara ?? '-',
      'lingkar_kepala': lingkarKepalaController.text,
      'panjang_badan': panjangBadanController.text,
      'penolong': _selectedPenolong ?? '-',
      'sex': _selectedSex ?? '-',
      'tempat': _selectedTempat ?? '-',
      'tgl_persalinan': _tglPersalinan,
      'umur_kehamilan': umurKehamilanController.text,
    };

    Navigator.pushNamed(
      context,
      AppRouter.reviewPersalinan,
      arguments: {'data': resultData},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Input Persalinan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Utils.sectionTitle('Detail Kelahiran'),
              DateTimePickerField(
                labelText: 'Tanggal Persalinan',
                prefixIcon: Icons.calendar_today,
                onSaved: (dateTime) {
                  setState(() => _tglPersalinan = dateTime);
                },
                validator: (val) => val == null ? 'Wajib diisi' : null,
                context: context,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: beratLahirController,
                label: "Berat Lahir",
                icon: Icons.monitor_weight,
                suffixText: 'gram',
                isNumber: true,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: panjangBadanController,
                label: "Panjang Badan",
                icon: Icons.straighten,
                suffixText: 'cm',
                isNumber: true,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: lingkarKepalaController,
                label: "Lingkar Kepala",
                icon: Icons.circle_outlined,
                suffixText: 'cm',
                isNumber: true,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: umurKehamilanController,
                label: "Umur Kehamilan",
                icon: Icons.calendar_today,
                suffixText: 'minggu',
                isNumber: true,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Utils.sectionTitle('Kondisi Kelahiran'),
              const SizedBox(height: 12),
              DropdownField(
                label: 'Jenis Kelamin',
                icon: Icons.people,
                items: _sexList,
                value: _selectedSex,
                onChanged: (newValue) {
                  setState(() {
                    _selectedSex = newValue;
                  });
                },
                validator: (val) => val == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              DropdownField(
                label: 'Cara Lahir',
                icon: Icons.local_hospital,
                items: _caraList,
                value: _selectedCara,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCara = newValue;
                  });
                },
                validator: (val) => val == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              DropdownField(
                label: 'Penolong',
                icon: Icons.person,
                items: _penolongList,
                value: _selectedPenolong,
                onChanged: (newValue) {
                  setState(() {
                    _selectedPenolong = newValue;
                  });
                },
                validator: (val) => val == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              DropdownField(
                label: 'Tempat Lahir',
                icon: Icons.place,
                items: _tempatList,
                value: _selectedTempat,
                onChanged: (newValue) {
                  setState(() {
                    _selectedTempat = newValue;
                  });
                },
                validator: (val) => val == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveData,
                  label: const Text('Review'),
                  icon: const Icon(Icons.check),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
