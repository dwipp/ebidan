import 'package:ebidan/data/models/statistic_model.dart';
import 'package:ebidan/presentation/widgets/k1_chart.dart';
import 'package:ebidan/presentation/widgets/logout_handler.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/general/cubit/connectivity_cubit.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:ebidan/state_management/kehamilan/cubit/selected_kehamilan_cubit.dart';
import 'package:ebidan/state_management/kunjungan/cubit/selected_kunjungan_cubit.dart';
import 'package:ebidan/state_management/persalinan/cubit/selected_persalinan_cubit.dart';
import 'package:ebidan/state_management/riwayat/cubit/selected_riwayat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<StatisticCubit>().fetchStatistic();
    context.read<SelectedPersalinanCubit>().clear;
    context.read<SelectedKunjunganCubit>().clear;
    context.read<SelectedRiwayatCubit>().clear;
    context.read<SelectedBumilCubit>().clear;
    context.read<SelectedKehamilanCubit>().clear;

    return Scaffold(
      appBar: PageHeader(
        title: 'eBidan',
        hideBackButton: true,
        actions: [
          BlocBuilder<ConnectivityCubit, ConnectivityState>(
            builder: (context, state) {
              final connected = state.connected;
              return Row(
                children: [
                  Icon(
                    connected ? Icons.wifi : Icons.wifi_off,
                    color: connected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 12),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => LogoutHandler.handleLogout(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).pushNamed(AppRouter.pilihBumil, arguments: {'state': 'kunjungan'});
        },
        backgroundColor: Colors.lightBlue[100],
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          // Scrollable supaya halaman bisa discroll bila konten banyak
          child: SingleChildScrollView(
            child: BlocBuilder<StatisticCubit, StatisticState>(
              builder: (context, state) {
                Statistic? statistic;
                if (state is StatisticSuccess) {
                  statistic = state.statistic;
                }
                if (state is StatisticFailure) {
                  return Center(child: Text("Error: ${state.message}"));
                }

                return StaggeredGrid.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    // Card Bumil (Total + Bulan Ini)
                    StaggeredGridTile.fit(
                      crossAxisCellCount: 4,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRouter.pilihBumil,
                          arguments: {'state': 'bumil'},
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                Colors.pink.shade200,
                                Colors.pink.shade100,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pink.shade100.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Kehamilan",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    icon: Icons.groups,
                                    iconColor: Colors.white,
                                    label: "Total Ibu Hamil",
                                    value:
                                        "${statistic?.bumil.allBumilCount ?? 0}",
                                    bgColor: Colors.pink.shade400.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                  _buildStatItem(
                                    icon: Icons.pregnant_woman,
                                    iconColor: Colors.white,
                                    label: "Bulan Ini",
                                    value:
                                        "${statistic?.lastMonthData?.bumil.total ?? 0}",
                                    bgColor: Colors.teal.shade400.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // K1 Chart
                    StaggeredGridTile.fit(
                      crossAxisCellCount: 4,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.statistics),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Statistik",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 28,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: K1Chart(
                                  k1Murni:
                                      statistic
                                          ?.lastMonthData
                                          ?.kunjungan
                                          .k1Murni ??
                                      0,
                                  k1Akses:
                                      statistic
                                          ?.lastMonthData
                                          ?.kunjungan
                                          .k1Akses ??
                                      0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Helper untuk stat item (icon + value + label)
  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color bgColor,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Menu tile clickable: Material + InkWell supaya ripple terlihat.
  Widget _buildMenuTile({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: Colors.black87),
              const SizedBox(width: 12),
              // Column untuk title + subtitle; gunakan Expanded agar teks tidak overflow
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 28, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
