import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/riwayat/cubit/selected_riwayat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailRiwayatScreen extends StatelessWidget {
  const DetailRiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final riwayat = context.watch<SelectedRiwayatCubit>().state;
    return Scaffold(
      appBar: PageHeader(
        title: "Detail Riwayat",
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
                "Berat Bayi",
                riwayat?.beratBayi.toString(),
                suffix: 'gram',
              ),
              Utils.generateRowLabelValue(
                "Panjang Bayi",
                riwayat?.panjangBayi,
                suffix: 'cm',
              ),
              Utils.generateRowLabelValue("Status Bayi", riwayat?.statusBayi),

              const SizedBox(height: 16),
              const Text(
                "Kelahiran",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                "Tahun Lahir",
                riwayat?.tahun.toString(),
              ),
              Utils.generateRowLabelValue("Status Lahir", riwayat?.statusLahir),
              Utils.generateRowLabelValue(
                "Status Kehamilan",
                riwayat?.statusTerm,
              ),
              Utils.generateRowLabelValue("Tempat", riwayat?.tempat),
              Utils.generateRowLabelValue("Penolong", riwayat?.penolong),
              Utils.generateRowLabelValue("Komplikasi", riwayat?.komplikasi),
            ],
          ),
        ),
      ),
    );
  }
}
