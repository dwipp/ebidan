import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/kunjungan/cubit/selected_kunjungan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailKunjunganScreen extends StatelessWidget {
  const DetailKunjunganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kunjungan = context.watch<SelectedKunjunganCubit>().state;
    return Scaffold(
      appBar: PageHeader(
        title: Utils.formattedDate(kunjungan?.createdAt),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              Navigator.pushNamed(context, AppRouter.editKunjungan);
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
              if (kunjungan?.status != '-')
                Center(
                  child: Text(
                    "${kunjungan?.status}",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                )
              else
                SizedBox(),
              Text(
                "Subjective",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue("Keluhan", kunjungan?.keluhan),
              const SizedBox(height: 16),
              const Text(
                "Objective",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Utils.generateRowLabelValue(
                "Berat Badan",
                kunjungan?.bb,
                suffix: 'kg',
              ),
              Utils.generateRowLabelValue(
                "Lingkar Lengan Atas (LILA)",
                kunjungan?.lila,
                suffix: 'cm',
              ),
              Utils.generateRowLabelValue(
                "Lingkar Perut",
                kunjungan?.lp,
                suffix: 'cm',
              ),
              Utils.generateRowLabelValue(
                "Tekanan Darah",
                kunjungan?.td,
                suffix: 'mmHg',
              ),
              Utils.generateRowLabelValue(
                "Tinggi Fundus Uteri (TFU)",
                kunjungan?.tfu,
              ),

              const SizedBox(height: 16),
              const Text(
                "Analysis",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue("Usia Kandungan", kunjungan?.uk),

              const SizedBox(height: 16),
              const Text(
                "Planning",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue("Planning", kunjungan?.planning),
            ],
          ),
        ),
      ),
    );
  }
}
