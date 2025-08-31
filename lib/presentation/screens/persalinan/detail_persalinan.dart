import 'package:ebidan/data/models/persalinan_model.dart';
import 'package:ebidan/common/Utils.dart';
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
        title: 'Detail Persalinan',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              print('edit persalinan');
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
                "Status Bayi",
                persalinan?.statusBayi ?? "-",
              ),

              // Tampil hanya jika status bayi bukan Abortus
              if (persalinan?.statusBayi != "Abortus") ...[
                Utils.generateRowLabelValue(
                  "Berat Lahir",
                  persalinan?.beratLahir?.toString() ?? "-",
                  suffix: 'gram',
                ),
                Utils.generateRowLabelValue(
                  "Panjang Badan",
                  persalinan?.panjangBadan?.toString() ?? "-",
                  suffix: 'cm',
                ),
                Utils.generateRowLabelValue(
                  "Lingkar Kepala",
                  persalinan?.lingkarKepala?.toString() ?? "-",
                  suffix: 'cm',
                ),
                Utils.generateRowLabelValue(
                  "Jenis Kelamin",
                  persalinan?.sex ?? "-",
                ),
              ],

              const SizedBox(height: 16),
              const Text(
                "Detail Persalinan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                "Tanggal Persalinan",
                persalinan?.tglPersalinan != null
                    ? Utils.formattedDate(persalinan?.tglPersalinan!)
                    : "-",
              ),
              Utils.generateRowLabelValue(
                "Umur Kehamilan",
                persalinan?.umurKehamilan?.toString() ?? "-",
              ),
              Utils.generateRowLabelValue(
                "Cara Persalinan",
                persalinan?.cara ?? "-",
              ),
              Utils.generateRowLabelValue("Tempat", persalinan?.tempat ?? "-"),
              Utils.generateRowLabelValue(
                "Penolong",
                persalinan?.penolong ?? "-",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
