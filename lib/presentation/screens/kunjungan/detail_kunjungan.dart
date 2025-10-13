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
        title: Text(Utils.formattedDate(kunjungan?.createdAt)),
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
              Utils.generateRowLabelValue(
                context,
                label: "Keluhan",
                value: kunjungan?.keluhan,
              ),
              const SizedBox(height: 16),
              const Text(
                "Objective",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Berat Badan",
                value: kunjungan?.bb.toString(),
                suffix: 'kg',
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Lingkar Lengan Atas (LILA)",
                value: kunjungan?.lila,
                suffix: 'cm',
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Lingkar Perut",
                value: kunjungan?.lp,
                suffix: 'cm',
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Tekanan Darah",
                value: kunjungan?.td,
                suffix: 'mmHg',
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Tinggi Fundus Uteri (TFU)",
                value: kunjungan?.tfu,
              ),

              const SizedBox(height: 16),
              const Text(
                "Analysis",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                context,
                label: "Usia Kandungan",
                value: kunjungan?.uk,
              ),

              const SizedBox(height: 16),
              const Text(
                "Planning",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                context,
                label: "Planning",
                value: kunjungan?.planning,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Pemberian SF",
                value: kunjungan?.nextSf?.toString(),
                suffix: 'tablet',
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Terapi",
                value: kunjungan?.terapi ?? '-',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
