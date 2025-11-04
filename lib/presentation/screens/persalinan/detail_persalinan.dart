import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/persalinan/cubit/selected_persalinan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailPersalinanScreen extends StatelessWidget {
  const DetailPersalinanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final persalinan = context.watch<SelectedPersalinanCubit>().state;
    return Scaffold(
      appBar: PageHeader(
        title: Text('Detail Persalinan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              Navigator.pushNamed(context, AppRouter.editPersalinan);
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

              // Selalu tampil
              Utils.generateRowLabelValue(
                context,
                label: "Status Bayi",
                value: persalinan?.statusBayi ?? "-",
              ),

              // Tampil hanya jika status bayi bukan Abortus
              if (persalinan?.statusBayi != "Abortus") ...[
                Utils.generateRowLabelValue(
                  context,
                  label: "Berat Lahir",
                  value: persalinan?.beratLahir?.toString() ?? "-",
                  suffix: 'gram',
                ),
                Utils.generateRowLabelValue(
                  context,
                  label: "Panjang Badan",
                  value: persalinan?.panjangBadan?.toString() ?? "-",
                  suffix: 'cm',
                ),
                Utils.generateRowLabelValue(
                  context,
                  label: "Lingkar Kepala",
                  value: persalinan?.lingkarKepala?.toString() ?? "-",
                  suffix: 'cm',
                ),
                Utils.generateRowLabelValue(
                  context,
                  label: "Jenis Kelamin",
                  value: persalinan?.sex ?? "-",
                ),
              ],

              const SizedBox(height: 16),
              const Text(
                "Detail Persalinan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                context,
                label: "Status Ibu",
                value: persalinan?.statusIbu ?? "-",
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Tanggal Persalinan",
                value: persalinan?.tglPersalinan != null
                    ? Utils.formattedDate(persalinan?.tglPersalinan!)
                    : "-",
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Umur Kehamilan",
                value: persalinan?.umurKehamilan?.toString() ?? "-",
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Cara Persalinan",
                value: persalinan?.cara ?? "-",
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Tempat",
                value: persalinan?.tempat ?? "-",
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Penolong",
                value: persalinan?.penolong ?? "-",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
