import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/dropdown_field.dart';
import 'package:ebidan/presentation/widgets/date_picker_field.dart';
import 'package:ebidan/presentation/widgets/gpa_field.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/data/models/kehamilan_model.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/kehamilan/cubit/submit_kehamilan_cubit.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditKehamilanScreen extends StatefulWidget {
  final Kehamilan kehamilan;
  const EditKehamilanScreen({super.key, required this.kehamilan});

  @override
  State<EditKehamilanScreen> createState() => _EditKehamilanState();
}

class _EditKehamilanState extends State<EditKehamilanScreen> {
  final _formKey = GlobalKey<FormState>();
  // bool _isSubmitting = false;

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
    super.initState();
    context.read<SubmitKehamilanCubit>().setInitial();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tbController.text = widget.kehamilan.tb ?? '';
    _hemoglobinController.text = widget.kehamilan.hemoglobin ?? '';
    _bpjsController.text = widget.kehamilan.bpjs ?? '';
    _noKohortController.text = widget.kehamilan.noKohortIbu ?? '';
    _noRekaMedisController.text = widget.kehamilan.noRekaMedis ?? '';
    _riwayatAlergiController.text = widget.kehamilan.riwayatAlergi ?? '';
    _riwayatPenyakitController.text = widget.kehamilan.riwayatPenyakit ?? '';
    _hasilLabController.text = widget.kehamilan.hasilLab ?? '';

    bumil = context.watch<SelectedBumilCubit>().state;
    final jarakTahun =
        DateTime.now().year - (bumil?.latestHistoryYear ?? DateTime.now().year);
    _jarakKehamilan.text = jarakTahun == 0 ? '-' : '$jarakTahun tahun';

    _gravidaController.text = bumil!.statisticRiwayat['gravida']!.toString();
    _paraController.text = bumil!.statisticRiwayat['para']!.toString();
    _abortusController.text = bumil!.statisticRiwayat['abortus']!.toString();

    print('hpht: ${widget.kehamilan.hpht}');
    _hpht = widget.kehamilan.hpht;
    _htp = widget.kehamilan.htp;
    _tglPeriksaUsg = widget.kehamilan.tglPeriksaUsg;
    _createdAt = widget.kehamilan.createdAt;
    _selectedStatusResti = widget.kehamilan.statusResti;
    _selectedKB = widget.kehamilan.kontrasepsiSebelumHamil;
    _selectedTT = widget.kehamilan.statusTt;
    _selectedKontrolDokter = widget.kehamilan.kontrolDokter;
  }

  Map<String, int> hitungSelisihTahunBulan(DateTime dari, DateTime ke) {
    int tahun = ke.year - dari.year;
    int bulan = ke.month - dari.month;

    // kalau bulan negatif, berarti tahunnya harus dikurangi 1
    if (bulan < 0) {
      tahun--;
      bulan += 12;
    }

    // opsional: kalau harinya belum lewat, bulan dikurangi 1
    if (ke.day < dari.day) {
      bulan--;
      if (bulan < 0) {
        bulan += 12;
        tahun--;
      }
    }

    return {"tahun": tahun, "bulan": bulan};
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final kehamilan = Kehamilan(
      tb: _tbController.text,
      hemoglobin: _hemoglobinController.text,
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
      idBumil: widget.kehamilan.idBumil,
      resti: collectingResti(),
      id: widget.kehamilan.id,
    );

    context.read<SubmitKehamilanCubit>().submitKehamilan(kehamilan);
  }

  List<String> collectingResti() {
    List<String> resti = [];
    if (bumil!.age < 20 && bumil!.age > 35) {
      resti.add('Usia ${bumil!.age} tahun');
    }
    if (bumil!.statisticRiwayat['gravida']! >= 4) {
      resti.add('Riwayat kehamilan ${bumil?.statisticRiwayat['gravida']}x');
    }

    final jarakTahun =
        DateTime.now().year -
        (bumil?.latestRiwayat?.tahun ?? DateTime.now().year);
    if (jarakTahun < 2) {
      resti.add('Jarak kehamilan terlalu dekat ($jarakTahun tahun)');
    }

    if (int.parse(_tbController.text) < 145) {
      resti.add('Risiko panggul sempit (tb: ${_tbController.text} cm)');
    }

    if (_hemoglobinController.text.isNotEmpty &&
        int.parse(_hemoglobinController.text) < 11) {
      resti.add('Anemia (Hb: ${_hemoglobinController.text} g/dL)');
    }

    if (int.parse(_abortusController.text) > 0) {
      resti.add('Pernah keguguran ${_abortusController.text}x');
    }

    if (bumil!.statisticRiwayat['beratRendah']! > 0) {
      resti.add(
        'Pernah melahirkan bayi dengan berat < 2500 gram (${bumil!.statisticRiwayat['beratRendah']!}x)',
      );
    }

    return resti;
  }

  DateTime hitungHTP(DateTime hpht) {
    // Tambah 7 hari
    DateTime tambahHari = hpht.add(const Duration(days: 7));

    // Tambah 9 bulan
    int bulan = tambahHari.month + 9;
    int tahun = tambahHari.year;

    // Kalau bulan lebih dari 12, adjust tahun & bulan
    if (bulan > 12) {
      bulan -= 12;
      tahun += 1;
    }

    // Pastikan tanggal valid (misalnya Februari tidak ada tgl 30)
    int hari = tambahHari.day;
    int maxHari = DateTime(tahun, bulan + 1, 0).day;
    if (hari > maxHari) {
      hari = maxHari;
    }
    return DateTime(tahun, bulan, hari);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
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
      appBar: PageHeader(title: "Perbaharui Kehamilan"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Data Umum'),
              CustomTextField(
                label: "No. Kohort Ibu",
                icon: Icons.numbers,
                controller: _noKohortController,
                textCapitalization: TextCapitalization.characters,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
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
                label: 'Status Resti',
                icon: Icons.person,
                items: _statusRestiList,
                value: _selectedStatusResti,
                onChanged: (newValue) {
                  setState(() {
                    _selectedStatusResti = newValue;
                  });
                },
                validator: (val) => val == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "No. BPJS",
                icon: Icons.card_membership,
                controller: _bpjsController,
                isNumber: true,
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Data Kehamilan'),
              DatePickerFormField(
                labelText: 'Hari Pertama Haid Terakhir (HPHT)',
                prefixIcon: Icons.date_range,
                context: context,
                initialValue: _hpht,
                onDateSelected: (date) {
                  setState(() {
                    _hpht = date;
                    _htp = hitungHTP(date);
                  });
                },
              ),
              const SizedBox(height: 12),
              DatePickerFormField(
                key: ValueKey(_htp),
                labelText: 'Hari Taksiran Persalinan (HTP)',
                prefixIcon: Icons.event,
                context: context,
                initialValue: _htp,
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
                label: "Tinggi Badan (TB)",
                icon: Icons.height,
                controller: _tbController,
                suffixText: 'cm',
                isNumber: true,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownField(
                label: 'Penggunaan KB Sebelum Hamil',
                icon: Icons.medication,
                items: _kbList,
                value: _selectedKB,
                onChanged: (newValue) {
                  setState(() {
                    _selectedKB = newValue;
                  });
                },
                validator: (val) => val == null ? 'Wajib dipilih' : null,
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
                label: 'Status Imunisasi TT',
                icon: Icons.vaccines,
                items: _ttList,
                value: _selectedTT,
                onChanged: (newValue) {
                  setState(() {
                    _selectedTT = newValue;
                  });
                },
                validator: (val) => val == null ? 'Wajib dipilih' : null,
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
                initialValue: _tglPeriksaUsg,
                context: context,
                onDateSelected: (date) {
                  setState(() => _tglPeriksaUsg = date);
                },
              ),
              const SizedBox(height: 12),
              DropdownField(
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
                validator: (val) => val == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              DatePickerFormField(
                labelText: 'Tanggal Pembuatan Data',
                prefixIcon: Icons.calendar_view_day,
                initialValue: _createdAt,
                context: context,
                readOnly: true,
                onDateSelected: (date) {
                  setState(() => _createdAt = date);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: BlocConsumer<SubmitKehamilanCubit, SubmitKehamilanState>(
                  listener: (context, state) {
                    if (state is AddKehamilanSuccess) {
                      Utils.showSnackBar(
                        context,
                        content: 'Data kehamilan berhasil disimpan',
                        isSuccess: true,
                      );
                      Navigator.pop(context);
                    } else if (state is AddKehamilanFailure) {
                      Utils.showSnackBar(
                        context,
                        content: 'Gagal: ${state.message}',
                        isSuccess: false,
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
                      label: 'Perbaharui',
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
