import 'package:ebidan/data/models/statistic_model.dart';
import 'package:ebidan/presentation/widgets/logout_handler.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/summary_chart.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
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
    final user = context.watch<UserCubit>().state;
    
    return Scaffold(
      appBar: PageHeader(
        title: 'eBidan',
        hideBackButton: true,
        actions: [
          // IconButton untuk menampilkan foto profil user
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              // Memeriksa apakah photoUrl tersedia
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!) as ImageProvider
                  : null,
              // Jika photoUrl tidak ada, tampilkan ikon default atau inisial nama
              child: user?.photoUrl == null
                  ? const Icon(Icons.person, color: Colors.black54)
                  : null,
                  radius: 13,
            ),
            onPressed: () {
              // if (user == null){
                LogoutHandler.handleLogout(context);
              // }else {
              // // Navigasi ke halaman profil
              // // Navigator.of(context).pushNamed(AppRouter.profile);
              // }
            },
          ),
          // Logout button
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   onPressed: () => LogoutHandler.handleLogout(context),
          // ),
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
                                children: const [
                                  Text(
                                    "Kehamilan",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
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
                                  Expanded(
                                    child: _buildStatItem(
                                      icon: Icons.groups,
                                      iconColor: Colors.white,
                                      label: "Total Ibu Hamil",
                                      value:
                                          "${statistic?.kehamilan.allBumilCount ?? 0}",
                                      bgColor: Colors.pink.shade400.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildStatItem(
                                      icon: Icons.pregnant_woman,
                                      iconColor: Colors.white,
                                      label: "Bulan Ini",
                                      value:
                                          "${statistic?.lastMonthData?.kehamilan.total ?? 0}",
                                      bgColor: Colors.teal.shade400.withOpacity(
                                        0.3,
                                      ),
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
                    // Statistik Card
                    StaggeredGridTile.fit(
                      crossAxisCellCount: 4,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          if (user != null && !user.premiumStatus.isPremium) {
                            // User bukan premium
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Akses Premium"),
                                content: const Text(
                                  "Fitur statistik hanya tersedia untuk pengguna premium. "
                                  "Upgrade sekarang untuk membuka akses penuh.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text("Batal"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(ctx); // tutup dialog
                                      // Navigator.pushNamed(
                                      //   context,
                                      //   AppRouter.subscribe,
                                      // ); // arahkan ke halaman subscribe
                                    },
                                    child: const Text("Upgrade"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            Navigator.pushNamed(context, AppRouter.statistics);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade300,
                                Colors.blue.shade100,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade100.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    "Statistik",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SummaryChart(
                                pasien:
                                    statistic?.lastMonthData?.pasien.total ?? 0,
                                kehamilan: statistic
                                        ?.lastMonthData?.kehamilan.total ??
                                    0,
                                kunjungan: statistic
                                        ?.lastMonthData?.kunjungan.total ??
                                    0,
                                persalinan: statistic
                                        ?.lastMonthData?.persalinan.total ??
                                    0,
                                showCenterValue: false,
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
}