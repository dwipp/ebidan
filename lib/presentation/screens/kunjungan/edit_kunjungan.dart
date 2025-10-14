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
import 'package:ebidan/state_management/kunjungan/cubit/selected_kunjungan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import FormValidator
import 'package:ebidan/common/utility/form_validator.dart';

class EditKunjunganScreen extends StatefulWidget {
  const EditKunjunganScreen({super.key});

  @override
  State<EditKunjunganScreen> createState() => _EditKunjunganState();
}

class _EditKunjunganState extends State<EditKunjunganScreen> {
  final _formKey = GlobalKey<FormState>();

  // **PERUBAHAN 1: Definisikan GlobalKey untuk setiap field wajib**
  final Map<String, GlobalKey> _fieldKeys = {
    'keluhan': GlobalKey(),
    'bb': GlobalKey(),
    'lila': GlobalKey(),
    'lp': GlobalKey(),
    'uk': GlobalKey(),
    'planning': GlobalKey(),
  };

  // **PERUBAHAN 2: Deklarasi FormValidator**
  late FormValidator _formValidator;

  final TextEditingController bbController = TextEditingController();
  final TextEditingController keluhanController = TextEditingController();
  final TextEditingController lilaController = TextEditingController();
  final TextEditingController lpController = TextEditingController();
  final TextEditingController planningController = TextEditingController();
  final TextEditingController tdController = TextEditingController();
  final TextEditingController tfuController = TextEditingController();
  final TextEditingController ukController = TextEditingController();
  final TextEditingController terapiController = TextEditingController();
  final TextEditingController nextSfController = TextEditingController();

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

  Kunjungan? kunjungan;
  Bumil? bumil;

  // Validator standar untuk wajib diisi
  String? _requiredValidator(dynamic val) {
    if (val is String) {
      return val.isEmpty ? 'Wajib diisi' : null;
    }
    return val == null ? 'Wajib dipilih' : null;
  }

  @override
  void initState() {
    super.initState();
    // **PERUBAHAN 3: Inisialisasi FormValidator**
    _formValidator = FormValidator(fieldKeys: _fieldKeys);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bumil = context.watch<SelectedBumilCubit>().state;
    kunjungan = context.watch<SelectedKunjunganCubit>().state;
    bbController.text = kunjungan!.bb!.toString();
    keluhanController.text = kunjungan!.keluhan!;
    lilaController.text = kunjungan!.lila!;
    lpController.text = kunjungan!.lp!;
    planningController.text = kunjungan!.planning!;
    tdController.text = kunjungan!.td!;
    tfuController.text = kunjungan?.tfu ?? '';
    ukController.text = kunjungan!.uk!;
    terapiController.text = kunjungan!.terapi ?? '';
    _selectedStatusKunjungan = kunjungan?.status ?? '';
    _createdAt = kunjungan!.createdAt!;
  }

  Future<void> _saveData() async {
    // **PERUBAHAN 4: Ganti validasi manual dengan validateAndScroll**
    _formValidator.reset();

    if (!_formValidator.validateAndScroll(_formKey, context)) {
      return;
    }

    final data = Kunjungan(
      id: kunjungan!.id,
      idBumil: bumil?.idBumil,
      idKehamilan: bumil?.latestKehamilanId,
      keluhan: keluhanController.text,
      bb: num.tryParse(bbController.text) ?? 0,
      tb: kunjungan?.tb,
      lila: lilaController.text,
      lp: lpController.text,
      td: tdController.text,
      tfu: tfuController.text,
      uk: ukController.text,
      terapi: terapiController.text,
      nextSf: num.tryParse(nextSfController.text) ?? 0,
      planning: planningController.text,
      status: _selectedStatusKunjungan ?? '-',
      createdAt: _createdAt,
    );

    Navigator.pushNamed(
      context,
      AppRouter.reviewKunjungan,
      arguments: {'data': data, 'firstTime': false},
    );
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
    nextSfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title: Text("Perbaharui Kunjungan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Utils.sectionTitle('Subjective'),
              CustomTextField(
                key: _fieldKeys['keluhan'], // Tambahkan key
                controller: keluhanController,
                label: "Keluhan",
                icon: Icons.warning_amber,
                isMultiline: true,
                // **PERUBAHAN 5: Wrap validator**
                validator: (val) => _formValidator.wrapValidator(
                  'keluhan',
                  val,
                  _requiredValidator,
                ),
              ),
              const SizedBox(height: 16),
              Utils.sectionTitle('Objective'),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['bb'], // Tambahkan key
                controller: bbController,
                label: "Berat Badan",
                icon: Icons.monitor_weight,
                suffixText: 'kg',
                isNumber: true,
                // **Wrap validator**
                validator: (val) =>
                    _formValidator.wrapValidator('bb', val, _requiredValidator),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['lila'], // Tambahkan key
                controller: lilaController,
                label: "Lingkar Lengan Atas (LILA)",
                icon: Icons.straighten,
                suffixText: 'cm',
                isNumber: true,
                // **Wrap validator**
                validator: (val) => _formValidator.wrapValidator(
                  'lila',
                  val,
                  _requiredValidator,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['lp'], // Tambahkan key
                controller: lpController,
                label: "Lingkar Perut",
                icon: Icons.pregnant_woman,
                suffixText: 'cm',
                isNumber: true,
                // **Wrap validator**
                validator: (val) =>
                    _formValidator.wrapValidator('lp', val, _requiredValidator),
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
              DatePickerFormField(
                labelText: 'Tanggal Kunjungan',
                prefixIcon: Icons.calendar_view_day,
                initialValue: _createdAt,
                context: context,
                readOnly: true,
                onDateSelected: (date) {
                  setState(() => _createdAt = date);
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['uk'], // Tambahkan key
                controller: ukController,
                label: "Usia Kandungan",
                icon: Icons.calendar_today,
                isNumber: true,
                readOnly: true,
                // **Wrap validator**
                validator: (val) =>
                    _formValidator.wrapValidator('uk', val, _requiredValidator),
              ),
              const SizedBox(height: 16),
              Utils.sectionTitle('Planning'),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['planning'], // Tambahkan key
                controller: planningController,
                label: "Planning",
                icon: Icons.assignment,
                isMultiline: true,
                // **Wrap validator**
                validator: (val) => _formValidator.wrapValidator(
                  'planning',
                  val,
                  _requiredValidator,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: nextSfController,
                label: "Pemberian SF",
                icon: Icons.bloodtype,
                isNumber: true,
                suffixText: 'tablet',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: terapiController,
                label: "Terapi",
                icon: Icons.healing,
                isMultiline: true,
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
}
