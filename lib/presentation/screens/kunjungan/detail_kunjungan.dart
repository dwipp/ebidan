import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:ebidan/logic/utility/Utils.dart';
import 'package:flutter/material.dart';

class DetailKunjunganScreen extends StatelessWidget {
  final Kunjungan kunjungan;

  const DetailKunjunganScreen({super.key, required this.kunjungan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Utils.formattedDate(kunjungan.createdAt)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              print('edit');
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
              if (kunjungan.status != '-')
                Center(
                  child: Text(
                    "${kunjungan.status}",
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
              Utils.generateRowLabelValue("Keluhan", kunjungan.keluhan),
              const SizedBox(height: 16),
              const Text(
                "Objective",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Utils.generateRowLabelValue(
                "Berat Badan",
                kunjungan.bb,
                suffix: 'kg',
              ),
              Utils.generateRowLabelValue(
                "Lingkar Lengan Atas (LILA)",
                kunjungan.lila,
                suffix: 'cm',
              ),
              Utils.generateRowLabelValue(
                "Lingkar Perut",
                kunjungan.lp,
                suffix: 'cm',
              ),
              Utils.generateRowLabelValue(
                "Tekanan Darah",
                kunjungan.td,
                suffix: 'mmHg',
              ),
              Utils.generateRowLabelValue(
                "Tinggi Fundus Uteri (TFU)",
                kunjungan.tfu,
              ),

              const SizedBox(height: 16),
              const Text(
                "Analysis",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                "Usia Kandungan",
                ' ${kunjungan.uk}',
                suffix: 'minggu',
              ),

              const SizedBox(height: 16),
              const Text(
                "Planning",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue("Planning", kunjungan.planning),
            ],
          ),
        ),
      ),
    );
  }
}
