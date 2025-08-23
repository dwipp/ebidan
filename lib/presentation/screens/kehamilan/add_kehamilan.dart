import 'package:ebidan/common/dropdown_field.dart';
import 'package:ebidan/common/date_picker_field.dart';
import 'package:ebidan/common/gpa_field.dart';
import 'package:ebidan/common/textfield.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddKehamilanScreen extends StatefulWidget {
  final String bumilId;
  final int age;
  final int? latestHistoryYear;
  final int jumlahRiwayat;
  final int jumlahPara;
  final int jumlahAbortus;
  final int jumlahLahirBeratRendah;
  const AddKehamilanScreen({
    super.key,
    required this.bumilId,
    required this.age,
    required this.latestHistoryYear,
    required this.jumlahRiwayat,
    required this.jumlahPara,
    required this.jumlahAbortus,
    required this.jumlahLahirBeratRendah,
  });

  @override
  State<AddKehamilanScreen> createState() => _PendataanKehamilanState();
}

class _PendataanKehamilanState extends State<AddKehamilanScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controller untuk setiap field
  // final _bbController = TextEditingController();
  final _tbController = TextEditingController();
  // final _lilaController = TextEditingController();
  final _hemoglobinController = TextEditingController();
  // final _lpController = TextEditingController();
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

  String? _selectedStatusIbu;
  final List<String> _statusBumilList = [
    'Resti Nakes',
    'Resti Masyarakat',
    '-',
  ];

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

  @override
  void initState() {
    super.initState();
    final jarakTahun =
        DateTime.now().year - (widget.latestHistoryYear ?? DateTime.now().year);
    _jarakKehamilan.text = jarakTahun == 0 ? '-' : '$jarakTahun tahun';
    _gravidaController.text = '${widget.jumlahRiwayat}';
    _paraController.text = '${widget.jumlahPara}';
    _abortusController.text = '${widget.jumlahAbortus}';
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

  List<String> collectingResti() {
    List<String> resti = [];
    if (widget.age < 20 && widget.age > 35) {
      resti.add('Usia ${widget.age} tahun');
    }
    if (widget.jumlahRiwayat >= 4) {
      resti.add('Riwayat kehamilan ${widget.jumlahRiwayat}x');
    }

    final jarakTahun =
        DateTime.now().year - (widget.latestHistoryYear ?? DateTime.now().year);
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

    if (widget.jumlahLahirBeratRendah > 0) {
      resti.add(
        'Pernah melahirkan bayi dengan berat < 2500 gram (${widget.jumlahLahirBeratRendah}x)',
      );
    }

    return resti;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final docRef = await FirebaseFirestore.instance.collection('kehamilan').add({
        "tb": _tbController.text,
        "hemoglobin": _hemoglobinController.text,
        "bpjs": _bpjsController.text,
        "no_kohort_ibu": _noKohortController.text,
        "no_reka_medis": _noRekaMedisController.text,
        "gpa":
            'G${_gravidaController.text}P${_paraController.text}A${_abortusController.text}',
        "kontrasepsi_sebelum_hamil": _selectedKB,
        "riwayat_alergi": _riwayatAlergiController.text,
        "riwayat_penyakit": _riwayatPenyakitController.text,
        "status_ibu": _selectedStatusIbu,
        "status_tt": _selectedTT,
        "hasil_lab": _hasilLabController.text,
        "hpht": _hpht,
        "htp": _htp,
        "tgl_periksa_usg": _tglPeriksaUsg,
        "id_bidan": user.uid,
        "created_at": DateTime.now(),
        "id_bumil": widget.bumilId,
        "resti": collectingResti(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data kehamilan berhasil disimpan')),
        );
        Navigator.pushReplacementNamed(
          context,
          AppRouter.kunjungan,
          arguments: {'kehamilanId': docRef.id, 'firstTime': true},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Kehamilan")),
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
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownField(
                label: 'Status Ibu',
                icon: Icons.person,
                items: _statusBumilList,
                value: _selectedStatusIbu,
                onChanged: (newValue) {
                  setState(() {
                    _selectedStatusIbu = newValue;
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
                onDateSelected: (date) {
                  setState(() => _hpht = date);
                },
              ),
              const SizedBox(height: 12),
              DatePickerFormField(
                labelText: 'Hari Taksiran Persalinan (HTP)',
                prefixIcon: Icons.event,
                context: context,
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
                context: context,
                onDateSelected: (date) {
                  setState(() => _tglPeriksaUsg = date);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan Data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
