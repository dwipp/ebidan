import 'package:ebidan/common/blood_pressure_field.dart';
import 'package:ebidan/common/dropdown_field.dart';
import 'package:ebidan/common/textfield.dart';
import 'package:ebidan/logic/utility/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class KunjunganScreen extends StatefulWidget {
  final String kehamilanId;

  const KunjunganScreen({super.key, required this.kehamilanId});

  @override
  State<KunjunganScreen> createState() => _KunjunganState();
}

class _KunjunganState extends State<KunjunganScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController bbController = TextEditingController();
  final TextEditingController keluhanController = TextEditingController();
  final TextEditingController lilaController = TextEditingController();
  final TextEditingController lpController = TextEditingController();
  final TextEditingController planningController = TextEditingController();
  final TextEditingController tdController = TextEditingController();
  final TextEditingController tfuController = TextEditingController();
  final TextEditingController ukController = TextEditingController();

  var maskUsiaKandungan = MaskTextInputFormatter(
    mask: '± ##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  String? _selectedStatusKunjungan;
  final List<String> _statusKunjunganList = [
    'Kunjungan 1',
    'Kunjungan 2',
    'Kunjungan 3',
    'Kunjungan 4',
    'Kunjungan 5',
    'Kunjungan 6',
    '-',
  ];

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final resultData = {
      'kehamilanId': widget.kehamilanId,
      'keluhan': keluhanController.text,
      'bb': bbController.text,
      'lila': lilaController.text,
      'lp': lpController.text,
      'td': tdController.text,
      'tfu': tfuController.text,
      'uk': ukController.text,
      'planning': planningController.text,
      'status': _selectedStatusKunjungan ?? '-',
    };

    Navigator.pushNamed(
      context,
      AppRouter.reviewKunjungan,
      arguments: {'data': resultData},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Input Kunjungan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Utils.sectionTitle('Subjective'),
              CustomTextField(
                controller: keluhanController,
                label: "Keluhan",
                icon: Icons.warning_amber,
                isMultiline: true,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Utils.sectionTitle('Objective'),
              const SizedBox(height: 12),
              CustomTextField(
                controller: bbController,
                label: "BB",
                icon: Icons.monitor_weight,
                suffixText: 'kilogram',
                isNumber: true,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: lilaController,
                label: "LILA",
                icon: Icons.straighten,
                suffixText: 'cm',
                isNumber: true,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: lpController,
                label: "LP",
                icon: Icons.pregnant_woman,
                suffixText: 'cm',
                isNumber: true,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              BloodPressureField(controller: tdController),
              const SizedBox(height: 12),
              CustomTextField(
                controller: tfuController,
                label: "TFU",
                icon: Icons.height,
                isMultiline: true,
              ),
              const SizedBox(height: 16),
              Utils.sectionTitle('Analysis'),
              const SizedBox(height: 12),
              CustomTextField(
                controller: ukController,
                label: "Usia Kandungan",
                icon: Icons.calendar_today,
                suffixText: 'minggu',
                isNumber: true,
                inputFormatters: [maskUsiaKandungan],
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Utils.sectionTitle('Planning'),
              const SizedBox(height: 12),
              CustomTextField(
                controller: planningController,
                label: "Planning",
                icon: Icons.assignment,
                isMultiline: true,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownField(
                label: 'Status Kunjungan',
                icon: Icons.info_outline,
                items: _statusKunjunganList,
                value: _selectedStatusKunjungan,
                onChanged: (newValue) {
                  setState(() {
                    _selectedStatusKunjungan = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveData,
                  label: Text('Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
