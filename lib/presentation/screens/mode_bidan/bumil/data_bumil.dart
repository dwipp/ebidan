import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/presentation/widgets/menu_button.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/selected_bumil_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataBumilScreen extends StatelessWidget {
  const DataBumilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bumil = context.watch<SelectedBumilCubit>().state;
    return Scaffold(
      appBar: PageHeader(title: Text(bumil?.namaIbu ?? '')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                MenuButton(
                  icon: Icons.person,
                  title: 'Detail Bumil',
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.detailBumil);
                  },
                ),
                MenuButton(
                  icon: Icons.history,
                  title: 'Riwayat Bumil',
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.listRiwayat);
                  },
                ),
                MenuButton(
                  icon: Icons.pregnant_woman,
                  title: 'Data Kehamilan Bumil',
                  enabled: bumil?.latestKehamilan != null,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.listKehamilan);
                  },
                ),
              ],
            ),
          ),

          // Sticky bottom container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child:
                (bumil?.latestKehamilanId == null ||
                    bumil?.latestKehamilanPersalinan == true)
                ?
                  // kehamilan baru
                  Expanded(child: _showKehamilanBaru(context))
                : Row(
                    children: [
                      if (!bumil!.latestKehamilanKunjungan) ...[
                        // kunjungan baru
                        Expanded(
                          child: _showButtonKunjunganBaru(
                            context,
                            showChevron: true,
                          ),
                        ),
                      ] else ...[
                        // kunjungan baru
                        // BUTTON KIRI
                        Expanded(child: _showButtonKunjunganBaru(context)),
                        SizedBox(width: 1),
                        // persalinan
                        // BUTTON KANAN
                        Expanded(child: _showCatatPersalinan(context)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _showButtonKunjunganBaru(
    BuildContext context, {
    bool showChevron = false,
  }) {
    return InkWell(
      onTap: () {
        print('Kunjungan Baru');
      },
      child: Container(
        height: 60,
        color: context.themeColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.how_to_reg, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  "Kunjungan Baru",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),

            if (showChevron) ...[
              // Kanan: Chevron
              const Icon(Icons.chevron_right, color: Colors.white, size: 28),
            ],
          ],
        ),
      ),
    );
  }

  Widget _showKehamilanBaru(BuildContext context) {
    return InkWell(
      onTap: () {
        print('kehamilan baru');
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
                Icon(Icons.pregnant_woman, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  "Kehamilan Baru",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),

            // Kanan: Chevron
            const Icon(Icons.chevron_right, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _showCatatPersalinan(BuildContext context) {
    return InkWell(
      onTap: () {
        print('Catat Persalinan');
      },
      child: Container(
        height: 60,
        color: context.themeColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              children: [
                Icon(
                  Icons.baby_changing_station,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  "Catat Persalinan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
