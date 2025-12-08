import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/mode_bidan/riwayat/cubit/selected_riwayat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailRiwayatScreen extends StatelessWidget {
  const DetailRiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final riwayat = context.watch<SelectedRiwayatCubit>().state;
    return Scaffold(
      appBar: PageHeader(
        title: Text("Detail Riwayat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              Navigator.pushNamed(
                context,
                AppRouter.editRiwayat,
                arguments: {'state': 'lateUpdate'},
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Informasi Bayi",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                context,
                label: "Berat Bayi",
                value: riwayat?.beratBayi.toString(),
                suffix: 'gram',
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Panjang Bayi",
                value: riwayat?.panjangBayi,
                suffix: 'cm',
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Status Bayi",
                value: riwayat?.statusBayi,
              ),

              const SizedBox(height: 16),
              const Text(
                "Persalinan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                context,
                label: "Tanggal Lahir",
                value: Utils.formattedDate(riwayat?.tglLahir),
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Status Lahir",
                value: riwayat?.statusLahir,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Status Kehamilan",
                value: riwayat?.statusTerm,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Tempat",
                value: riwayat?.tempat,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Penolong",
                value: riwayat?.penolong,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Komplikasi",
                value: riwayat?.komplikasi,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
