import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/common/utility/pdf_helper.dart';
import 'package:ebidan/presentation/widgets/menu_button.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/premium_warning_banner.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final warningBanner = PremiumWarningBanner.fromContext(context);

    return Scaffold(
      appBar: PageHeader(title: Text('Statistik')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (warningBanner != null) warningBanner,
                MenuButton(
                  icon: Icons.event_note,
                  title: 'Kunjungan',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.kunjunganStats,
                      arguments: {'monthKey': Utils.getAutoYearMonth()},
                    );
                  },
                ),
                MenuButton(
                  icon: Icons.health_and_safety,
                  title: 'Resti',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.restiStats,
                      arguments: {'monthKey': Utils.getAutoYearMonth()},
                    );
                  },
                ),
                MenuButton(
                  icon: Icons.bloodtype,
                  title: 'Konsumsi Suplemen Fe',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.sfStats,
                      arguments: {'monthKey': Utils.getAutoYearMonth()},
                    );
                  },
                ),
                MenuButton(
                  icon: Icons.baby_changing_station,
                  title: 'Persalinan',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.persalinanStats,
                      arguments: {'monthKey': Utils.getAutoYearMonth()},
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: InkWell(
              onTap: () async {
                try {
                  final bidan = context.read<UserCubit>().state;
                  if (bidan == null) {
                    return;
                  }
                  final service = PdfHelper();

                  // await service.generateAndDownload();
                  await service.generateAndPreview(context, bidan);

                  Snackbar.show(
                    context,
                    message: 'PDF berhasil di buat.',
                    type: SnackbarType.success,
                  );
                } catch (e) {
                  Snackbar.show(
                    context,
                    message: 'Gagal: $e',
                    type: SnackbarType.error,
                  );
                }
              },
              child: Container(
                height: 60,
                color: context.themeColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Kiri: Icon + Text
                    Row(
                      children: const [
                        Icon(
                          Icons.document_scanner_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Generate Laporan PDF",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),

                    // Kanan: Chevron
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
