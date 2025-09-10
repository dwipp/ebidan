import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/data/models/statistic_model.dart';
import 'package:ebidan/presentation/widgets/k1_chart.dart';
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
import 'package:firebase_auth/firebase_auth.dart';
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _onLogoutPressed(context);
            },
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
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  // pakai .fit untuk tile yang butuh tinggi dinamis
                  children: [
                    StaggeredGridTile.fit(
                      crossAxisCellCount: 3,
                      child: _buildInfoTile(
                        title: "Bumil Bulan Ini",
                        value: "${statistic?.lastMonthData?.bumil.total ?? 0}",
                        color: Colors.teal[200]!,
                        icon: Icons.pregnant_woman,
                      ),
                    ),
                    StaggeredGridTile.fit(
                      crossAxisCellCount: 1,
                      child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
                        builder: (context, state) {
                          return _buildInfoTile(
                            title: state.connected ? "Online" : "Offline",
                            value: "",
                            color: state.connected
                                ? Colors.green[300]!
                                : Colors.red[300]!,
                            icon: Icons.wifi,
                          );
                        },
                      ),
                    ),

                    StaggeredGridTile.fit(
                      crossAxisCellCount: 3,
                      child: _buildInfoTile(
                        title: "Total Bumil",
                        value: "${statistic?.bumil.allBumilCount ?? 0}",
                        color: Colors.pink[200]!,
                        icon: Icons.groups,
                      ),
                    ),

                    // Menu 'Pilih Bumil' - clickable, jelas terlihat
                    StaggeredGridTile.fit(
                      crossAxisCellCount: 4,
                      child: _buildMenuTile(
                        title: "Pilih Bumil",
                        subtitle: "Lihat Data",
                        color: Colors.purple[200]!,
                        icon: Icons.assignment_ind,
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRouter.pilihBumil,
                          arguments: {'state': 'bumil'},
                        ),
                      ),
                    ),

                    // Statistik sebagai full row menu
                    StaggeredGridTile.fit(
                      crossAxisCellCount: 4,
                      child: _buildMenuTile(
                        title: "Statistik",
                        subtitle: "Lihat Detail",
                        color: Colors.blue[200]!,
                        icon: Icons.bar_chart,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.statistics),
                      ),
                    ),

                    StaggeredGridTile.fit(
                      crossAxisCellCount: 4, // full row biar lega
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: K1Chart(
                            k1Murni:
                                statistic?.lastMonthData?.kunjungan.k1Murni ??
                                0,
                            k1Akses:
                                statistic?.lastMonthData?.kunjungan.k1Akses ??
                                0,
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

  /// Info tile tetap non-clickable (height mengikuti konten)
  Widget _buildInfoTile({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Material(
      color: color,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min, // penting supaya height mengikuti isi
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
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

  Future<void> _onLogoutPressed(BuildContext context) async {
    final hasPending = await Utils.hasAnyPendingWrites();
    if (hasPending) {
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Data Belum Tersinkron"),
          content: const Text(
            "Ada data yang masih offline dan belum tersinkron ke server. "
            "Besar kemungkinan data akan hilang jika anda logout.\n\n"
            "Apakah Anda yakin ingin tetap logout?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("Ya"),
            ),
          ],
        ),
      );

      if (shouldLogout == true) {
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } else {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}
