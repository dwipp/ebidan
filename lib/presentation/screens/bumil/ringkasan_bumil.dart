import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RingkasanBumilScreen extends StatelessWidget {
  const RingkasanBumilScreen({super.key});

  int usia(DateTime tanggalLahir) {
    DateTime sekarang = DateTime.now();
    int usia = sekarang.year - tanggalLahir.year;

    // cek apakah ulang tahun tahun ini sudah lewat atau belum
    if (sekarang.month < tanggalLahir.month ||
        (sekarang.month == tanggalLahir.month &&
            sekarang.day < tanggalLahir.day)) {
      usia--;
    }

    return usia;
  }

  String getK1status(String? input) {
    if (input != null) {
      // Parsing string "X minggu Y hari"
      final regex = RegExp(r'(\d+)\s*minggu(?:\s*(\d+)\s*hari)?');
      final match = regex.firstMatch(input.toLowerCase());

      if (match == null) return "-";

      final minggu = int.parse(match.group(1)!);
      final hari = match.group(2) != null ? int.parse(match.group(2)!) : 0;

      // Konversi ke total hari
      final totalHari = (minggu * 7) + hari;

      if (totalHari <= 84) {
        return "K1 Murni";
      } else {
        return "K1 Akses";
      }
    }
    return "-";
  }

  @override
  Widget build(BuildContext context) {
    final bumil = context.watch<SelectedBumilCubit>().state;
    return Scaffold(
      appBar: PageHeader(title: Text("Ringkasan Ibu Hamil")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Data Ibu",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                context,
                label: "Nama Ibu",
                value: bumil?.namaIbu,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Nama Suami",
                value: bumil?.namaSuami,
              ),
              if (bumil?.birthdateIbu != null)
                Utils.generateRowLabelValue(
                  context,
                  label: "Usia Ibu",
                  value: '${usia(bumil!.birthdateIbu!)} tahun',
                ),
              Utils.generateRowLabelValue(
                context,
                label: "Alamat",
                value: bumil?.alamat,
              ),
              const SizedBox(height: 16),
              const Text(
                "Data Kehamilan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Status Kunjungan",
                value: bumil?.latestKunjungan?.status,
              ),

              if (bumil?.latestKunjungan?.status == "K1")
                Utils.generateRowLabelValue(
                  context,
                  label: "Golongan K1",
                  value: getK1status(bumil?.latestKunjungan?.uk),
                ),
              Utils.generateRowLabelValue(
                context,
                label: "Resti",
                value: bumil?.latestKehamilan?.statusResti,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "GPA",
                value: bumil?.latestKehamilan?.gpa,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Umur Kehamilan",
                value: Utils.hitungUsiaKehamilan(
                  hpht: bumil?.latestKehamilanHpht,
                  tglKunjungan: bumil?.latestKunjungan?.createdAt,
                ),
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Hari Pertama Haid Terakhir (HPHT)",
                value: Utils.formattedDate(bumil?.latestKehamilanHpht),
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Hari Taksiran Persalinan (HTP)",
                value: Utils.formattedDate(
                  Utils.hitungHTP(bumil?.latestKehamilanHpht),
                ),
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Jarak Persalinan Terakhir",
                value:
                    "${Utils.hitungJarakTahun(tglLahir: bumil?.latestRiwayat?.tglLahir, tglKehamilanBaru: bumil?.latestKehamilan?.createdAt)} tahun",
              ),
              Utils.generateRowLabelValue(
                context,
                label: "LILA",
                value: bumil?.latestKunjungan?.lila,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Nilai Hemoglobin",
                value: bumil?.latestKehamilan?.hemoglobin,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Hasil Lab Lainnya",
                value: bumil?.latestKehamilan?.hasilLab,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
