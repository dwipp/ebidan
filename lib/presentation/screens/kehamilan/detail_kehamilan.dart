import 'package:ebidan/presentation/widgets/menu_button.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/kehamilan/cubit/selected_kehamilan_cubit.dart';
import 'package:ebidan/state_management/persalinan/cubit/selected_persalinan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DetailKehamilanScreen extends StatelessWidget {
  const DetailKehamilanScreen({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("d MMMM yyyy", "id_ID").format(date);
  }

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
                "Tinggi Badan",
                kehamilan.tb?.toString(),
                suffix: "cm",
              ),
              Utils.generateRowLabelValue(
                "No. Kohort Ibu",
                kehamilan.noKohortIbu,
              ),
              Utils.generateRowLabelValue(
                "No. Rekam Medis",
                kehamilan.noRekaMedis,
              ),
              Utils.generateRowLabelValue("BPJS", kehamilan.bpjs),
              Utils.generateRowLabelValue(
                "Status Resti",
                kehamilan.statusResti,
              ),
              Utils.generateRowLabelValue("Status TT", kehamilan.statusTt),
              Utils.generateRowLabelValue(
                "Kontrasepsi Sebelum Hamil",
                kehamilan.kontrasepsiSebelumHamil,
              ),
              Utils.generateRowLabelValue("GPA", kehamilan.gpa),
              Utils.generateRowLabelValue("HPHT", _formatDate(kehamilan.hpht)),
              Utils.generateRowLabelValue("HTP", _formatDate(kehamilan.htp)),
              Utils.generateRowLabelValue(
                "Tanggal Periksa USG",
                _formatDate(kehamilan.tglPeriksaUsg),
              ),
              Utils.generateRowLabelValue(
                "Riwayat Penyakit",
                kehamilan.riwayatPenyakit,
              ),
              Utils.generateRowLabelValue(
                "Riwayat Alergi",
                kehamilan.riwayatAlergi,
              ),
              Utils.generateRowLabelValue("Hasil Lab", kehamilan.hasilLab),
              Utils.generateRowLabelValue(
                'Hemoglobin',
                kehamilan.hemoglobin,
                suffix: 'g/dL',
              ),
              Utils.generateRowLabelValue(
                "Dibuat Pada",
                _formatDate(kehamilan.createdAt),
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
                          color: Colors.red.shade100,
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
