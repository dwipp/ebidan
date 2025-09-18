import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:ebidan/presentation/widgets/blood_pressure_field.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/date_picker_field.dart';
import 'package:ebidan/presentation/widgets/dropdown_field.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KunjunganScreen extends StatefulWidget {
  final bool firstTime;

  const KunjunganScreen({super.key, required this.firstTime});

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
  final TextEditingController terapiController = TextEditingController();

  DateTime? _createdAt = DateTime.now();

  String? _selectedStatusKunjungan;
  final List<String> _statusKunjunganList = [
    'K1',
    'K2',
    'K3',
    'K4',
    'K5',
    'K6',
    '-',
  ];


  bool? _selectedPeriksaUsg;
  final List<String> _periksaUsgList = ['Ya', 'Tidak'];

  Bumil? bumil;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bumil = context.watch<SelectedBumilCubit>().state;
    ukController.text = _hitungUsiaKehamilan(hpht: bumil!.latestKehamilanHpht!);
    if (widget.firstTime) {
      _selectedStatusKunjungan = 'K1';
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final kunjungan = Kunjungan(
      id: '',
      idBumil: bumil?.idBumil,
      idKehamilan: bumil?.latestKehamilanId,
      keluhan: keluhanController.text,
      bb: bbController.text,
      lila: lilaController.text,
      lp: lpController.text,
      td: tdController.text,
      tfu: tfuController.text,
      uk: ukController.text,
      terapi: terapiController.text,
      planning: planningController.text,
      status: _selectedStatusKunjungan ?? '-',
      createdAt: _createdAt,
      periksaUsg: _selectedPeriksaUsg,
    );

    Navigator.pushNamed(
      context,
      AppRouter.reviewKunjungan,
      arguments: {'data': kunjungan, 'firstTime': widget.firstTime},
    );
  }

  String _hitungUsiaKehamilan({required DateTime hpht}) {
    final today = DateTime.now();

    // Hitung selisih hari antara today dan hpht
    final selisihHari = today.difference(hpht).inDays;

    if (selisihHari < 0) {
      return '0 minggu';
    }

    final minggu = selisihHari ~/ 7;
    final hari = selisihHari % 7;
    if (hari == 0) {
      return '$minggu minggu';
    }
    return '$minggu minggu $hari hari';
  }

  @override
  void dispose() {
    bbController.dispose();
    keluhanController.dispose();
    lilaController.dispose();
    lpController.dispose();
    planningController.dispose();
    tdController.dispose();
    tfuController.dispose();
    ukController.dispose();
    terapiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title: "Kunjungan Baru"),
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
                label: "Berat Badan",
                icon: Icons.monitor_weight,
                suffixText: 'kg',
                isNumber: true,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: lilaController,
                label: "Lingkar Lengan Atas (LILA)",
                icon: Icons.straighten,
                suffixText: 'cm',
                isNumber: true,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: lpController,
                label: "Lingkar Perut",
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
                label: "Tinggi Fundus Uteri (TFU)",
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
                isNumber: true,
                readOnly: true,
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
              CustomTextField(
                controller: terapiController,
                label: "Terapi",
                icon: Icons.healing,
                isMultiline: true,
              ),
              const SizedBox(height: 12),
              // DropdownField(
              //   label: 'Status Kunjungan',
              //   icon: Icons.info_outline,
              //   items: _statusKunjunganList,
              //   value: _selectedStatusKunjungan,
              //   onChanged: (newValue) {
              //     setState(() {
              //       _selectedStatusKunjungan = newValue;
              //     });
              //   },
              // ),
              _buildUsgField(),
              const SizedBox(height: 12),
              DatePickerFormField(
                labelText: 'Tanggal Pembuatan Data (Auto)',
                prefixIcon: Icons.calendar_view_day,
                initialValue: _createdAt,
                context: context,
                onDateSelected: (date) {
                  setState(() => _createdAt = date);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Button(
                  isSubmitting: false,
                  onPressed: _saveData,
                  label: 'Review',
                  icon: Icons.check,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

/**
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
 */

  Widget _buildUsgField() {
    bool isUsg = _selectedStatusKunjungan == 'K5' || _selectedStatusKunjungan == 'K6';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        if (isUsg) const SizedBox(height: 8),
        if (isUsg)
          DropdownField(
            label: 'Periksa USG',
            icon: Icons.pregnant_woman,
            items: _periksaUsgList,
            value: _selectedPeriksaUsg == null
                      ? null
                      : (_selectedPeriksaUsg! ? 'Ya' : 'Tidak'),
            onChanged: (newValue) {
              setState(() {
                _selectedPeriksaUsg = newValue?.toLowerCase() == "ya";
              });
            },
            validator: (val) => val == null ? 'Wajib dipilih' : null,
          ),
      ],
    );
  }
}
