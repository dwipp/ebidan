import 'package:ebidan/common/date_picker_field.dart';
import 'package:ebidan/common/textfield.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PendataanKehamilanScreen extends StatefulWidget {
  final String bumilId;
  const PendataanKehamilanScreen({super.key, required this.bumilId});

  @override
  State<PendataanKehamilanScreen> createState() => _PendataanKehamilanState();
}

class _PendataanKehamilanState extends State<PendataanKehamilanScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controller untuk setiap field
  final _bbController = TextEditingController();
  final _tbController = TextEditingController();
  final _lilaController = TextEditingController();
  final _lpController = TextEditingController();
  final _bpjsController = TextEditingController();
  final _noKohortController = TextEditingController();
  final _noRekaMedisController = TextEditingController();
  final _gpaController = TextEditingController();
  final _kontrasepsiController = TextEditingController();
  final _riwayatAlergiController = TextEditingController();
  final _riwayatPenyakitController = TextEditingController();
  final _statusIbuController = TextEditingController();
  final _statusTtController = TextEditingController();
  final _hasilLabController = TextEditingController();
  final _jarakKehamilan = TextEditingController();

  DateTime? _hpht;
  DateTime? _htp;
  DateTime? _tglPeriksaUsg;

  @override
  void initState() {
    super.initState();
    _jarakKehamilan.text = '4 tahun';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String docId = 'bumil-${widget.bumilId}-${DateTime.now().year}';

    try {
      await FirebaseFirestore.instance.collection('kehamilan').doc(docId).set({
        "bb": _bbController.text,
        "tb": _tbController.text,
        "lila": _lilaController.text,
        "lp": _lpController.text,
        "bpjs": _bpjsController.text,
        "no_kohort_ibu": _noKohortController.text,
        "no_reka_medis": _noRekaMedisController.text,
        "gpa": _gpaController.text,
        "kontrasepsi_sebelum_hamil": _kontrasepsiController.text,
        "riwayat_alergi": _riwayatAlergiController.text,
        "riwayat_penyakit": _riwayatPenyakitController.text,
        "status_ibu": _statusIbuController.text,
        "status_tt": _statusTtController.text,
        "hasil_lab": _hasilLabController.text,
        "hpht": _hpht,
        "htp": _htp,
        "tgl_periksa_usg": _tglPeriksaUsg,
        "id_bidan": user.uid,
        "created_at": DateTime.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data kehamilan berhasil disimpan')),
        );
        Navigator.pushReplacementNamed(context, AppRouter.kunjungan);
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
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "No. Rekam Medis",
                icon: Icons.local_hospital,
                controller: _noRekaMedisController,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "Status Ibu", // resti nakes, resti kader,
                icon: Icons.person,
                controller: _statusIbuController,
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
                validator: (val) => val == null ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DatePickerFormField(
                labelText: 'Hari Taksiran Persalinan (HTP)',
                prefixIcon: Icons.event,
                context: context,
                onDateSelected: (date) {
                  setState(() => _htp = date);
                },
                validator: (val) => val == null ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "Lingkar Lengan Atas (LILA)",
                icon: Icons.straighten,
                controller: _lilaController,
                suffixText: 'cm',
                isNumber: true,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "Tinggi Badan (TB)",
                icon: Icons.height,
                controller: _tbController,
                suffixText: 'cm',
                isNumber: true,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "Berat Badan (BB)",
                icon: Icons.monitor_weight,
                controller: _bbController,
                suffixText: 'gram',
                isNumber: true,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "Lingkar Perut (LP)",
                icon: Icons.accessibility,
                controller: _lpController,
                suffixText: 'cm',
                isNumber: true,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "Penggunaan KB Sebelum Hamil",
                icon: Icons.medication,
                controller: _kontrasepsiController,
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
              CustomTextField(
                label: "Status Imunisasi TT",
                icon: Icons.vaccines,
                controller: _statusTtController,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "GPA",
                icon: Icons.info,
                controller: _gpaController,
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
              DatePickerFormField(
                labelText: 'Tanggal Periksa USG',
                prefixIcon: Icons.calendar_today,
                context: context,
                onDateSelected: (date) {
                  setState(() => _tglPeriksaUsg = date);
                },
                validator: (val) => val == null ? 'Wajib diisi' : null,
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
