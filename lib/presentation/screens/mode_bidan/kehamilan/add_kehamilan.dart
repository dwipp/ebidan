import 'package:ebidan/common/utility/form_validator.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/dropdown_field.dart';
import 'package:ebidan/presentation/widgets/date_picker_field.dart';
import 'package:ebidan/presentation/widgets/gpa_field.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/data/models/kehamilan_model.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/kehamilan/cubit/submit_kehamilan_cubit.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddKehamilanScreen extends StatefulWidget {
  const AddKehamilanScreen({super.key});

  @override
  State<AddKehamilanScreen> createState() => _PendataanKehamilanState();
}

class _PendataanKehamilanState extends State<AddKehamilanScreen> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, GlobalKey> _fieldKeys = {
    'noKohort': GlobalKey(),
    'statusResti': GlobalKey(),
    'tb': GlobalKey(),
    'kb': GlobalKey(),
    'statusTT': GlobalKey(),
    'kontrolDokter': GlobalKey(),
    'createdAt': GlobalKey(),
  };

  // Hapus: Map<String, FieldValidator> _validators, karena akan menggunakan wrapValidator

  late FormValidator _formValidator;

  // Validator standar untuk string/text (val.isEmpty)
  String? _requiredStringValidator(dynamic val) =>
      val == null || val.isEmpty ? 'Wajib diisi' : null;

  // Validator standar untuk objek/dropdown/datepicker (val == null)
  String? _requiredObjectValidator(dynamic val) =>
      val == null ? 'Wajib dipilih' : null;

  // Validator kustom lainnya jika diperlukan...

  // Controller untuk setiap field
  final _tbController = TextEditingController();
  final _hemoglobinController = TextEditingController();
  final _bpjsController = TextEditingController();
  final _noKohortController = TextEditingController();
  final _noRekaMedisController = TextEditingController();
  final _riwayatAlergiController = TextEditingController();
  final _riwayatPenyakitController = TextEditingController();
  final _hasilLabController = TextEditingController();
  final _jarakKehamilan = TextEditingController();
  final _gravidaController = TextEditingController();
  final _paraController = TextEditingController();
  final _abortusController = TextEditingController();

  DateTime? _hpht;
  DateTime? _htp;
  DateTime? _tglPeriksaUsg;
  DateTime? _createdAt;

  String? _selectedStatusResti;
  final List<String> _statusRestiList = ['Nakes', 'Masyarakat', '-'];

  String? _selectedKB;
  final List<String> _kbList = [
    'Pil',
    'Suntik',
    'Implan',
    'IUD',
    'Tidak ber-KB',
  ];

  String? _selectedTT;
  final List<String> _ttList = ['TT0', 'TT1', 'TT2', 'TT3', 'TT4', 'TT5'];

  bool? _selectedKontrolDokter;
  final List<String> _kontrolDokterList = ['Ya', 'Tidak'];

  Bumil? bumil;

  @override
  void initState() {
    context.read<SubmitKehamilanCubit>().setInitial();

    // Inisialisasi FormValidator hanya dengan fieldKeys
    _formValidator = FormValidator(fieldKeys: _fieldKeys);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bumil = context.watch<SelectedBumilCubit>().state;
    final jarakTahun = Utils.hitungJarakTahun(
      tglLahir: bumil?.latestRiwayat?.tglLahir,
      tglKehamilanBaru: _createdAt,
    );
    _jarakKehamilan.text = jarakTahun == 0 ? '-' : '$jarakTahun tahun';
    _gravidaController.text =
        '${(bumil?.statisticRiwayat['gravida'] ?? 0) + 1}';
    _paraController.text = '${bumil?.statisticRiwayat['para']}';
    _abortusController.text = '${bumil?.statisticRiwayat['abortus']}';
  }

  Map<String, int> hitungSelisihTahunBulan(DateTime dari, DateTime ke) {
    int tahun = ke.year - dari.year;
    int bulan = ke.month - dari.month;

    if (bulan < 0) {
      tahun--;
      bulan += 12;
    }

    if (ke.day < dari.day) {
      bulan--;
      if (bulan < 0) {
        bulan += 12;
        tahun--;
      }
    }

    return {"tahun": tahun, "bulan": bulan};
  }

  List<String> collectingResti() {
    List<String> resti = [];
    if (bumil!.age < 20 || bumil!.age > 35) {
      resti.add('Usia ${bumil!.age} tahun');
    }
    if (bumil!.statisticRiwayat['gravida']! >= 3) {
      resti.add('Riwayat kehamilan ${bumil?.statisticRiwayat['gravida']}x');
    }

    if (bumil!.statisticRiwayat['gravida']! > 0) {
      final jarakTahun = Utils.hitungJarakTahun(
        tglLahir: bumil?.latestRiwayat?.tglLahir,
        tglKehamilanBaru: _createdAt,
      );
      if (jarakTahun < 2) {
        resti.add('Jarak kehamilan terlalu dekat ($jarakTahun tahun)');
      }
    }

    if (_tbController.text.isNotEmpty) {
      if (int.tryParse(_tbController.text) != null &&
          int.parse(_tbController.text) < 145) {
        resti.add('Risiko panggul sempit (tb: ${_tbController.text} cm)');
      }
    }

    if (_hemoglobinController.text.isNotEmpty) {
      if (double.tryParse(_hemoglobinController.text) != null &&
          double.parse(_hemoglobinController.text) < 11) {
        resti.add('Anemia (Hb: ${_hemoglobinController.text} g/dL)');
      }
    }

    if (int.tryParse(_abortusController.text) != null &&
        int.parse(_abortusController.text) > 0) {
      resti.add('Pernah keguguran ${_abortusController.text}x');
    }

    if (bumil!.statisticRiwayat['beratRendah']! > 0) {
      resti.add(
        'Pernah melahirkan bayi dengan berat < 2500 gram (${bumil?.statisticRiwayat['beratRendah']}x)',
      );
    }

    return resti;
  }

  Future<void> _submitForm() async {
    _formValidator.reset();

    // **Panggil validateAndScroll**
    if (!_formValidator.validateAndScroll(_formKey, context)) {
      // **Hapus: Snackbar manual di sini**, karena sudah ditangani oleh FormValidator
      return;
    }

    final kehamilan = Kehamilan(
      tb: _tbController.text,
      hemoglobin: num.tryParse(_hemoglobinController.text),
      bpjs: _bpjsController.text,
      noKohortIbu: _noKohortController.text,
      noRekaMedis: _noRekaMedisController.text,
      gpa:
          'G${_gravidaController.text}P${_paraController.text}A${_abortusController.text}',
      kontrasepsiSebelumHamil: _selectedKB,
      riwayatAlergi: _riwayatAlergiController.text,
      riwayatPenyakit: _riwayatPenyakitController.text,
      statusResti: _selectedStatusResti,
      statusTt: _selectedTT,
      hasilLab: _hasilLabController.text,
      hpht: _hpht,
      htp: _htp,
      tglPeriksaUsg: _tglPeriksaUsg,
      kontrolDokter: _selectedKontrolDokter ?? false,
      createdAt: _createdAt,
      idBumil: bumil?.idBumil,
      resti: collectingResti(),
      usia: bumil?.age,
    );

    context.read<SubmitKehamilanCubit>().submitKehamilan(kehamilan);
  }

  @override
  void dispose() {
    _tbController.dispose();
    _hemoglobinController.dispose();
    _bpjsController.dispose();
    _noKohortController.dispose();
    _noRekaMedisController.dispose();
    _riwayatAlergiController.dispose();
    _riwayatPenyakitController.dispose();
    _hasilLabController.dispose();
    _jarakKehamilan.dispose();
    _gravidaController.dispose();
    _paraController.dispose();
    _abortusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title: Text("Kehamilan Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.sectionTitle('Data Umum'),
              CustomTextField(
                key: _fieldKeys['noKohort'],
                label: "No. Kohort Ibu",
                icon: Icons.numbers,
                controller: _noKohortController,
                textCapitalization: TextCapitalization.characters,
                // **Gunakan wrapValidator**
                validator: (val) => _formValidator.wrapValidator(
                  'noKohort',
                  val,
                  _requiredStringValidator,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "No. Rekam Medis",
                icon: Icons.local_hospital,
                controller: _noRekaMedisController,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 12),
              DropdownField(
                key: _fieldKeys['statusResti'],
                label: 'Status Resti',
                icon: Icons.person,
                items: _statusRestiList,
                value: _selectedStatusResti,
                onChanged: (newValue) {
                  setState(() {
                    _selectedStatusResti = newValue;
                  });
                },
                // **Gunakan wrapValidator**
                validator: (val) => _formValidator.wrapValidator(
                  'statusResti',
                  val,
                  _requiredObjectValidator,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "No. BPJS",
                icon: Icons.card_membership,
                controller: _bpjsController,
                isNumber: true,
              ),
              const SizedBox(height: 16),
              Utils.sectionTitle('Data Kehamilan'),
              DatePickerFormField(
                labelText: 'Hari Pertama Haid Terakhir (HPHT)',
                prefixIcon: Icons.date_range,
                context: context,
                onDateSelected: (date) {
                  setState(() {
                    _hpht = date;
                    _htp = Utils.hitungHTP(date);
                  });
                },
              ),
              const SizedBox(height: 12),
              DatePickerFormField(
                key: ValueKey(_htp),
                labelText: 'Hari Taksiran Persalinan (HTP)',
                prefixIcon: Icons.event,
                context: context,
                value: _htp,
                readOnly: true,
                lastDate: DateTime(
                  DateTime.now().year + 1,
                  DateTime.now().month,
                  DateTime.now().day,
                ),
                onDateSelected: (date) {
                  setState(() => _htp = date);
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['tb'],
                label: "Tinggi Badan (TB)",
                icon: Icons.height,
                controller: _tbController,
                suffixText: 'cm',
                isNumber: true,
                // **Gunakan wrapValidator**
                validator: (val) => _formValidator.wrapValidator(
                  'tb',
                  val,
                  _requiredStringValidator,
                ),
              ),
              const SizedBox(height: 12),
              DropdownField(
                key: _fieldKeys['kb'],
                label: 'Penggunaan KB Sebelum Hamil',
                icon: Icons.medication,
                items: _kbList,
                value: _selectedKB,
                onChanged: (newValue) {
                  setState(() {
                    _selectedKB = newValue;
                  });
                },
                // **Gunakan wrapValidator**
                validator: (val) => _formValidator.wrapValidator(
                  'kb',
                  val,
                  _requiredObjectValidator,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "Riwayat Penyakit",
                icon: Icons.healing,
                controller: _riwayatPenyakitController,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "Riwayat Alergi",
                icon: Icons.warning,
                controller: _riwayatAlergiController,
              ),
              const SizedBox(height: 12),
              DropdownField(
                key: _fieldKeys['statusTT'],
                label: 'Status Imunisasi TT',
                icon: Icons.vaccines,
                items: _ttList,
                value: _selectedTT,
                onChanged: (newValue) {
                  setState(() {
                    _selectedTT = newValue;
                  });
                },
                // **Gunakan wrapValidator**
                validator: (val) => _formValidator.wrapValidator(
                  'statusTT',
                  val,
                  _requiredObjectValidator,
                ),
              ),
              const SizedBox(height: 12),
              DatePickerFormField(
                key: _fieldKeys['createdAt'],
                labelText: 'Tanggal Terima Buku KIA',
                prefixIcon: Icons.calendar_view_day,
                context: context,
                onDateSelected: (date) {
                  setState(() => _createdAt = date);
                  final jarakTahun = Utils.hitungJarakTahun(
                    tglLahir: bumil?.latestRiwayat?.tglLahir,
                    tglKehamilanBaru: date,
                  );
                  _jarakKehamilan.text = jarakTahun == 0
                      ? '-'
                      : '$jarakTahun tahun';
                },
                validator: (val) => _formValidator.wrapValidator(
                  'createdAt',
                  val,
                  _requiredObjectValidator,
                ),
              ),
              const SizedBox(height: 12),
              GPAField(
                gravidaController: _gravidaController,
                paraController: _paraController,
                abortusController: _abortusController,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "Jarak Kehamilan",
                icon: Icons.more_time,
                controller: _jarakKehamilan,
                readOnly: true,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "Hasil Lab",
                icon: Icons.science,
                controller: _hasilLabController,
                isMultiline: true,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "Kadar Hemoglobin",
                icon: Icons.bloodtype,
                controller: _hemoglobinController,
                suffixText: 'g/dL',
                isNumber: true,
              ),
              const SizedBox(height: 12),
              DatePickerFormField(
                labelText: 'Tanggal Periksa USG',
                prefixIcon: Icons.calendar_today,
                context: context,
                onDateSelected: (date) {
                  setState(() => _tglPeriksaUsg = date);
                },
              ),
              const SizedBox(height: 12),
              DropdownField(
                key: _fieldKeys['kontrolDokter'],
                label: 'Kontrol Dokter',
                icon: Icons.health_and_safety,
                items: _kontrolDokterList,
                value: _selectedKontrolDokter == null
                    ? null
                    : (_selectedKontrolDokter! ? 'Ya' : 'Tidak'),
                onChanged: (newValue) {
                  setState(() {
                    _selectedKontrolDokter = newValue?.toLowerCase() == "ya";
                  });
                },
                // **Gunakan wrapValidator**
                validator: (val) => _formValidator.wrapValidator(
                  'kontrolDokter',
                  val,
                  _requiredObjectValidator,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: BlocConsumer<SubmitKehamilanCubit, SubmitKehamilanState>(
                  listener: (context, state) {
                    if (state is AddKehamilanSuccess) {
                      Snackbar.show(
                        context,
                        message: 'Data kehamilan berhasil disimpan',
                        type: SnackbarType.success,
                      );
                      Navigator.pushReplacementNamed(
                        context,
                        AppRouter.kunjungan,
                        arguments: {'firstTime': state.firstTime},
                      );
                    } else if (state is AddKehamilanFailure) {
                      Snackbar.show(
                        context,
                        message: 'Gagal: ${state.message}',
                        type: SnackbarType.error,
                      );
                    }
                  },
                  builder: (context, state) {
                    var isSubmitting = false;
                    if (state is AddKehamilanLoading) {
                      isSubmitting = true;
                    }
                    return Button(
                      isSubmitting: isSubmitting,
                      onPressed: _submitForm,
                      label: 'Simpan',
                      icon: Icons.check,
                      loadingLabel: 'Menyimpan...',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
