import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/presentation/widgets/menu_button.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/kehamilan/cubit/selected_kehamilan_cubit.dart';
import 'package:ebidan/state_management/persalinan/cubit/selected_persalinan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailKehamilanScreen extends StatelessWidget {
  const DetailKehamilanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<SelectedPersalinanCubit>().clear;
    final kehamilan = context.watch<SelectedKehamilanCubit>().state;
    final bumil = context.watch<SelectedBumilCubit>().state;
    return Scaffold(
      appBar: PageHeader(
        title: "Kehamilan ${kehamilan?.createdAt?.year}",
        actions: (kehamilan?.id == bumil?.latestKehamilanId)
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.editKehamilan,
                      arguments: {'kehamilan': kehamilan},
                    );
                  },
                ),
              ]
            : [],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MenuButton(
                icon: Icons.calendar_month,
                title: 'Kunjungan',
                enabled: kehamilan!.kunjungan,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.listKunjungan,
                    arguments: {'docId': kehamilan.id},
                  );
                },
              ),
              MenuButton(
                icon: Icons.pregnant_woman,
                title: 'Persalinan',
                enabled: kehamilan.persalinan != null,
                onTap: () {
                  if (kehamilan.persalinan!.length > 1) {
                    Navigator.pushNamed(
                      context,
                      AppRouter.listPersalinan,
                      arguments: {'persalinans': kehamilan.persalinan!},
                    );
                  } else {
                    context.read<SelectedPersalinanCubit>().selectPersalinan(
                      kehamilan.persalinan![0],
                    );
                    Navigator.pushNamed(context, AppRouter.detailPersalinan);
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Data Kehamilan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                context,
                label: 'Tinggi Badan',
                value: kehamilan.tb?.toString(),
                suffix: 'cm',
              ),
              Utils.generateRowLabelValue(
                context,
                label: "No. Kohort Ibu",
                value: kehamilan.noKohortIbu,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "No. Rekam Medis",
                value: kehamilan.noRekaMedis,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "BPJS",
                value: kehamilan.bpjs,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Status Resti",
                value: kehamilan.statusResti,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Status TT",
                value: kehamilan.statusTt,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Kontrasepsi Sebelum Hamil",
                value: kehamilan.kontrasepsiSebelumHamil,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "GPA",
                value: kehamilan.gpa,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "HPHT",
                value: Utils.formattedDate(kehamilan.hpht),
              ),
              Utils.generateRowLabelValue(
                context,
                label: "HTP",
                value: Utils.formattedDate(kehamilan.htp),
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Tanggal Periksa USG",
                value: Utils.formattedDate(kehamilan.tglPeriksaUsg),
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Kontrol Dokter",
                value: kehamilan.kontrolDokter ? 'Ya' : 'Tidak',
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Riwayat Penyakit",
                value: kehamilan.riwayatPenyakit,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Riwayat Alergi",
                value: kehamilan.riwayatAlergi,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Hasil Lab",
                value: kehamilan.hasilLab,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Hemoglobin",
                value: kehamilan.hemoglobin,
                suffix: 'g/dL',
              ),

              const SizedBox(height: 16),
              const Text(
                "Lainnya",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                context,
                label: "Menerima buku KIA",
                value: Utils.formattedDate(kehamilan.createdAt),
              ),

              const SizedBox(height: 16),
              const Text(
                "Resti",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (kehamilan.resti != null && kehamilan.resti!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: kehamilan.resti!
                      .map(
                        (r) => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          color: context.themeColors.error.withOpacity(0.2),
                          child: Text('- $r'),
                        ),
                      )
                      .toList(),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade100, // bg label
                  child: const Text("-"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
