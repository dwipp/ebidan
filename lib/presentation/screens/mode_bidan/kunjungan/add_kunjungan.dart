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
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/selected_bumil_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/common/utility/form_validator.dart';

class KunjunganScreen extends StatefulWidget {
  final bool firstTime;

  const KunjunganScreen({super.key, required this.firstTime});

  @override
  State<KunjunganScreen> createState() => _KunjunganState();
}

class _KunjunganState extends State<KunjunganScreen> {
  final _formKey = GlobalKey<FormState>();

  // Definisi Global Key untuk field wajib
  final Map<String, GlobalKey> _fieldKeys = {
    'keluhan': GlobalKey(),
    'bb': GlobalKey(),
    'lila': GlobalKey(),
    'lp': GlobalKey(),
    'td': GlobalKey(),
    'uk': GlobalKey(),
    'planning': GlobalKey(),
    'periksaUsg': GlobalKey(), // Untuk field kondisional di _buildUsgField
  };

  late FormValidator _formValidator;

  // Validator standar untuk string/text (val.isEmpty)
  String? _requiredStringValidator(dynamic val) =>
      val == null || val.isEmpty ? 'Wajib diisi' : null;

  // Validator standar untuk objek/dropdown/datepicker (val == null)
  String? _requiredObjectValidator(dynamic val) =>
      val == null ? 'Wajib dipilih' : null;

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

  bool? _selectedPeriksaUsg;
  final List<String> _periksaUsgList = ['Ya', 'Tidak'];

  Bumil? bumil;

  @override
  void initState() {
    _formValidator = FormValidator(fieldKeys: _fieldKeys);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bumil = context.watch<SelectedBumilCubit>().state;
    ukController.text = Utils.hitungUsiaKehamilan(
      hpht: bumil?.latestKehamilanHpht ?? bumil?.latestKehamilan?.hpht,
      tglKunjungan: _createdAt,
    );
    if (widget.firstTime) {
      _selectedStatusKunjungan = 'K1';
    }
  }

  Future<void> _saveData() async {
    _formValidator.reset();

    // Panggil validateAndScroll
    if (!_formValidator.validateAndScroll(_formKey, context)) {
      // SnackBar error sudah ditangani oleh FormValidator
      return;
    }

    final kunjungan = Kunjungan(
      id: '',
      idBumil: bumil?.idBumil,
      idKehamilan: bumil?.latestKehamilanId,
      keluhan: keluhanController.text,
      bb: num.tryParse(bbController.text) ?? 0,
      tb: num.tryParse(bumil?.latestKehamilan?.tb ?? "") ?? 0,
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
      nextSf: num.tryParse(nextSfController.text) ?? 0,
    );

    Navigator.pushNamed(
      context,
      AppRouter.reviewKunjungan,
      arguments: {'data': kunjungan, 'firstTime': widget.firstTime},
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
      appBar: PageHeader(title: Text("Kunjungan Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.sectionTitle('Subjective'),
              CustomTextField(
                key: _fieldKeys['keluhan'],
                controller: keluhanController,
                label: "Keluhan",
                icon: Icons.warning_amber,
                isMultiline: true,
                // Gunakan wrapValidator
                validator: (val) => _formValidator.wrapValidator(
                  'keluhan',
                  val,
                  _requiredStringValidator,
                ),
              ),
              const SizedBox(height: 16),
              Utils.sectionTitle('Objective'),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['bb'],
                controller: bbController,
                label: "Berat Badan",
                icon: Icons.monitor_weight,
                suffixText: 'kg',
                isNumber: true,
                // Gunakan wrapValidator
                validator: (val) => _formValidator.wrapValidator(
                  'bb',
                  val,
                  _requiredStringValidator,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['lila'],
                controller: lilaController,
                label: "Lingkar Lengan Atas (LILA)",
                icon: Icons.straighten,
                suffixText: 'cm',
                isNumber: true,
                // Gunakan wrapValidator
                validator: (val) => _formValidator.wrapValidator(
                  'lila',
                  val,
                  _requiredStringValidator,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['lp'],
                controller: lpController,
                label: "Lingkar Perut",
                icon: Icons.pregnant_woman,
                suffixText: 'cm',
                isNumber: true,
                // Gunakan wrapValidator
                validator: (val) => _formValidator.wrapValidator(
                  'lp',
                  val,
                  _requiredStringValidator,
                ),
              ),
              const SizedBox(height: 12),
              BloodPressureField(
                fieldKey: _fieldKeys['td'],
                controller: tdController,
                formValidator: _formValidator,
              ),
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
                onDateSelected: (date) {
                  setState(() => _createdAt = date);
                  ukController.text = Utils.hitungUsiaKehamilan(
                    hpht: bumil?.latestKehamilanHpht,
                    tglKunjungan: date,
                  );
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['uk'],
                controller: ukController,
                label: "Usia Kandungan",
                icon: Icons.calendar_today,
                readOnly: true,
                // Gunakan wrapValidator
                validator: (val) => _formValidator.wrapValidator(
                  'uk',
                  val,
                  _requiredStringValidator,
                ),
              ),
              const SizedBox(height: 16),
              Utils.sectionTitle('Planning'),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['planning'],
                controller: planningController,
                label: "Planning",
                icon: Icons.assignment,
                isMultiline: true,
                // Gunakan wrapValidator
                validator: (val) => _formValidator.wrapValidator(
                  'planning',
                  val,
                  _requiredStringValidator,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: nextSfController,
                label:
                    !widget.firstTime && bumil?.latestKehamilan?.sfCount != null
                    ? "Pemberian SF (prev ${bumil?.latestKehamilan?.sfCount ?? 0} tablet)"
                    : "Pemberian SF",
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
              _buildUsgField(),
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

  Widget _buildUsgField() {
    bool isUsg =
        _selectedStatusKunjungan == 'K5' || _selectedStatusKunjungan == 'K6';

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
            key: _fieldKeys['periksaUsg'], // Key untuk field kondisional
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
            // Gunakan wrapValidator
            validator: (val) => _formValidator.wrapValidator(
              'periksaUsg',
              val,
              _requiredObjectValidator,
            ),
          ),
      ],
    );
  }
}
