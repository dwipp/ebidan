import 'package:ebidan/common/blood_pressure_field.dart';
import 'package:ebidan/common/textfield.dart';
import 'package:ebidan/logic/utility/Utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class KunjunganScreen extends StatefulWidget {
  final String kehamilanId; // misalnya id bumil-C5kNHJsd... untuk parent doc

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
  final TextEditingController statusController = TextEditingController();
  final TextEditingController tdController = TextEditingController();
  final TextEditingController tfuController = TextEditingController();
  final TextEditingController ukController = TextEditingController();

  bool _isLoading = false;

  var maskUsiaKandungan = MaskTextInputFormatter(
    mask: '± ##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('kehamilan')
          .doc(widget.kehamilanId)
          .collection('kunjungan');

      // Ambil jumlah dokumen di collection kunjungan
      final snapshot = await docRef.get();
      final nextId = (snapshot.docs.length + 1).toString(); // 1,2,3 dst

      await docRef.doc(nextId).set({
        'bb': bbController.text,
        'created_at': DateTime.now(),
        'keluhan': keluhanController.text,
        'lila': lilaController.text,
        'lp': lpController.text,
        'planning': planningController.text,
        'status': statusController.text,
        'td': tdController.text,
        'tfu': tfuController.text,
        'uk': ukController.text,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal simpan: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
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
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: lilaController,
                label: "LILA",
                icon: Icons.straighten,
                suffixText: 'cm',
                isNumber: true,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: lpController,
                label: "LP",
                icon: Icons.pregnant_woman,
                suffixText: 'cm',
                isNumber: true,
              ),
              const SizedBox(height: 12),
              BloodPressureField(),
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
              ),
              const SizedBox(height: 16),
              Utils.sectionTitle('Planning'),
              const SizedBox(height: 12),
              CustomTextField(
                controller: planningController,
                label: "Planning",
                icon: Icons.assignment,
                isMultiline: true,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: statusController,
                label: "Status Kunjungan",
                icon: Icons.info_outline,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveData,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(_isLoading ? 'Menyimpan...' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
