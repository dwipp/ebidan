import 'package:ebidan/common/Utils.dart';
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
    context.read<StatisticCubit>().fetchStatistics();
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
        child: Icon(Icons.add),
      ),
      body: BlocBuilder<StatisticCubit, StatisticState>(
        builder: (context, state) {
          if (state is StatisticLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StatisticFailure) {
            return Center(child: Text("Error: ${state.message}"));
          } else if (state is StatisticSuccess) {
            final statistic = state.statistic;
            return StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
              children: [
                StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 2,
                  child: Container(
                    color: Colors.teal[200],
                    child: Text(
                      "Bumil bulan ini: ${statistic?.bumil.bumilThisMonth}",
                    ),
                  ),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 1,
                  child: InkWell(
                    child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
                      builder: (context, state) {
                        return Container(
                          color: state.connected
                              ? Colors.lime[200]
                              : Colors.red[300],
                          child: Text("sync"),
                        );
                      },
                    ),
                    onTap: () {},
                  ),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 1,
                  child: InkWell(
                    child: Container(
                      color: Colors.pink[200],
                      child: Text(
                        "Total bumil: ${statistic?.bumil.bumilTotal}",
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRouter.pilihBumil,
                        arguments: {'state': 'bumil'},
                      );
                    },
                  ),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 4,
                  mainAxisCellCount: 2,
                  child: Container(
                    color: Colors.teal[200],
                    child: Text("Total Customer"),
                  ),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 1,
                  child: Container(
                    color: Colors.teal[200],
                    child: Text(
                      "K1 Murni: ${statistic?.lastMonthData?.k1Murni}",
                    ),
                  ),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 2,
                  child: Container(
                    color: Colors.teal[200],
                    child: Text("K1: ${statistic?.lastMonthData?.k1}"),
                  ),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 1,
                  child: Container(
                    color: Colors.teal[200],
                    child: Text(
                      "K1 Akses: ${statistic?.lastMonthData?.k1Akses}",
                    ),
                  ),
                ),
              ],
            );
          }
          // default kalau masih initial
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _onLogoutPressed(BuildContext context) async {
    final hasPending = await Utils.hasAnyPendingWrites();

    if (hasPending) {
      // Tampilkan alert ke user
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
        // Kembali ke login screen
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } else {
      // langsung logout
      await FirebaseAuth.instance.signOut();
      // Kembali ke login screen
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}
