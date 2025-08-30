import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/kunjungan/cubit/add_kunjungan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewKunjunganScreen extends StatefulWidget {
  final Kunjungan data;
  final bool firstTime;

  const ReviewKunjunganScreen({
    super.key,
    required this.data,
    required this.firstTime,
  });

  @override
  State<ReviewKunjunganScreen> createState() => _ReviewKunjunganScreenState();
}

class _ReviewKunjunganScreenState extends State<ReviewKunjunganScreen> {
  Widget _buildRow(String label, String value, {String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value.isNotEmpty ? '$value $suffix' : "-",
              softWrap: true,
              maxLines: null, // biar multiline
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title: "Hasil Kunjungan"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Subjective",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildRow("Keluhan", widget.data.keluhan ?? '-'),
              const SizedBox(height: 16),
              const Text(
                "Objective",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildRow("Berat Badan", widget.data.bb ?? '-', suffix: 'kg'),
              _buildRow(
                "Lingkar Lengan Atas (LILA)",
                widget.data.lila ?? '-',
                suffix: 'cm',
              ),
              _buildRow("Lingkar Perut", widget.data.lp ?? '-', suffix: 'cm'),
              _buildRow("Tekanan Darah", widget.data.td ?? '-', suffix: 'mmHg'),
              _buildRow("Tinggi Fundus Uteri (TFU)", widget.data.tfu ?? '-'),
              const SizedBox(height: 16),
              const Text(
                "Analysis",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildRow("Usia Kandungan", widget.data.uk ?? '-'),
              const SizedBox(height: 16),
              const Text(
                "Planning",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildRow("Planning", widget.data.planning ?? '-'),
              _buildRow("Status Kunjungan", widget.data.status ?? '-'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: BlocConsumer<AddKunjunganCubit, AddKunjunganState>(
                  listener: (context, state) {
                    if (state is AddKunjunganSuccess) {
                      Utils.showSnackBar(
                        context,
                        content: 'Data berhasil disimpan',
                        isSuccess: true,
                      );
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRouter.homepage,
                        (route) => false,
                      );
                    } else if (state is AddKunjunganFailure) {
                      Utils.showSnackBar(
                        context,
                        content: 'Gagal: ${state.message}',
                        isSuccess: true,
                      );
                    }
                  },
                  builder: (context, state) {
                    var isSubmitting = false;
                    if (state is AddKunjunganCubit) {
                      isSubmitting = true;
                    }
                    return Button(
                      isSubmitting: isSubmitting,
                      onPressed: () =>
                          context.read<AddKunjunganCubit>().addKunjungan(
                            widget.data,
                            firstTime: widget.firstTime,
                          ),
                      label: 'Simpan',
                      icon: Icons.check,
                      loadingLabel: 'Menyimpan...',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
