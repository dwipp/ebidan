import 'package:avatar_glow/avatar_glow.dart';
import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/common/utility/subscription_helper.dart';
import 'package:ebidan/data/models/bidan_model.dart';
import 'package:ebidan/data/models/statistic_model.dart';
import 'package:ebidan/presentation/widgets/browser_launcher.dart';
import 'package:ebidan/presentation/widgets/logout_handler.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/presentation/widgets/summary_chart.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/state_management/general/cubit/back_press_cubit.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/kehamilan/cubit/selected_kehamilan_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/kunjungan/cubit/selected_kunjungan_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/persalinan/cubit/selected_persalinan_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/riwayat/cubit/selected_riwayat_cubit.dart';
import 'package:ebidan/state_management/profile/cubit/profile_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void verifySubs() async {
    final userCubit = context.read<UserCubit>();
    final subs = userCubit.state?.subscription;
    if (subs?.status == "expired") return;
    if (subs?.productId == null || subs?.purchaseToken == null) return;

    final now = DateTime.now();
    final lastVerified = subs?.lastVerified;
    const verifyInterval = Duration(hours: 24);

    // Jika belum pernah diverifikasi, langsung verifikasi
    final needVerify =
        lastVerified == null || now.difference(lastVerified) > verifyInterval;

    if (needVerify) {
      await SubscriptionHelper.verify(
        productId: subs!.productId!,
        purchaseToken: subs.purchaseToken!,
        user: userCubit,
      );
      print("[Subs Verify] Performed at $now");
    } else {
      final diff = now.difference(lastVerified);
      print(
        "[Subs Verify] Skip (last verified ${diff.inHours} jam ${diff.inMinutes % 60} menit lalu)",
      );
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().getProfile();
    verifySubs();
  }

  @override
  Widget build(BuildContext context) {
    context.read<StatisticCubit>().fetchStatistic();
    context.read<SelectedPersalinanCubit>().clear();
    context.read<SelectedKunjunganCubit>().clear();
    context.read<SelectedRiwayatCubit>().clear();
    context.read<SelectedBumilCubit>().clear();
    context.read<SelectedKehamilanCubit>().clear();
    final user = context.watch<UserCubit>().state;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final allowExit = context.read<BackPressCubit>().onBackPressed();
        if (!allowExit) {
          Snackbar.show(context, message: 'Tekan sekali lagi untuk keluar');
        } else {
          SystemNavigator.pop();
        }
      },
      child: BlocListener<UserCubit, Bidan?>(
        listener: (context, user) {
          if (FirebaseAuth.instance.currentUser != null && user == null) {
            _shouldRegister(context);
          }
        },
        child: Scaffold(
          appBar: PageHeader(
            title: Image.asset(
              'assets/images/logo-ebidan-text.png',
              height: 25,
            ),
            hideBackButton: true,
            actions: [
              // IconButton untuk menampilkan foto profil user
              IconButton(
                icon: CircleAvatar(
                  backgroundColor: context.themeColors.surface,
                  // Memeriksa apakah photoUrl tersedia
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!) as ImageProvider
                      : null,
                  radius: 13,
                  // Jika photoUrl tidak ada, tampilkan ikon default atau inisial nama
                  child: user?.photoUrl == null
                      ? Icon(Icons.person, color: context.themeColors.onSurface)
                      : null,
                ),
                onPressed: () {
                  if (user?.nama == null) {
                    LogoutHandler.handleLogout(context);
                  } else {
                    // Navigasi ke halaman profil
                    Navigator.of(context).pushNamed(AppRouter.profile);
                  }
                },
              ),
            ],
          ),
          floatingActionButton: user?.role.toLowerCase() != 'bidan'
              ? null
              : AvatarGlow(
                  glowRadiusFactor: 0.7,
                  duration: const Duration(seconds: 3),
                  glowColor: context.themeColors.secondaryContainer,
                  glowShape: BoxShape.circle,
                  child: FloatingActionButton(
                    shape: const CircleBorder(),
                    onPressed: () {
                      if (FirebaseAuth.instance.currentUser != null &&
                          user == null) {
                        _shouldRegister(context);
                      } else {
                        Navigator.of(context).pushNamed(
                          AppRouter.pilihBumil,
                          arguments: {'state': 'kunjungan'},
                        );
                      }
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // Scrollable supaya halaman bisa discroll bila konten banyak
                  child: SingleChildScrollView(
                    child: BlocBuilder<StatisticCubit, StatisticState>(
                      builder: (context, state) {
                        Statistic? statistic;
                        if (state is StatisticSuccess) {
                          statistic = state.statistic;
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
                                onTap: () {
                                  if (FirebaseAuth.instance.currentUser !=
                                          null &&
                                      user == null) {
                                    _shouldRegister(context);
                                  } else {
                                    if (user?.role.toLowerCase() != 'bidan') {
                                      Navigator.of(
                                        context,
                                      ).pushNamed(AppRouter.listBidan);
                                    } else {
                                      Navigator.of(context).pushNamed(
                                        AppRouter.pilihBumil,
                                        arguments: {'state': 'bumil'},
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: context.themeColors.pinkGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: context.themeColors.shadowPink,
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            user?.role.toLowerCase() != 'bidan'
                                                ? 'Data Bidan'
                                                : "Kehamilan",
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
                                              label:
                                                  user?.role.toLowerCase() !=
                                                      'bidan'
                                                  ? 'Total bidan terdaftar'
                                                  : "Total Ibu Hamil",
                                              value:
                                                  "${statistic?.kehamilan.allBumilCount ?? 0}",
                                              bgColor: Colors.pink.shade400
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          if (user?.role.toLowerCase() ==
                                              'bidan') ...[
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildStatItem(
                                                icon: Icons.pregnant_woman,
                                                iconColor: Colors.white,
                                                label: "Bulan Ini",
                                                value:
                                                    "${statistic?.lastMonthData?.kehamilan.total ?? 0}",
                                                bgColor: Colors.teal.shade400
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                          ],
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
                                  if (FirebaseAuth.instance.currentUser !=
                                          null &&
                                      user == null) {
                                    _shouldRegister(context);
                                  } else {
                                    if (user != null &&
                                        !user.premiumStatus.isPremium) {
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
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: const Text("Batal"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                  ctx,
                                                ); // tutup dialog
                                                Future.microtask(() async {
                                                  final subscribed =
                                                      await Navigator.pushNamed(
                                                        context,
                                                        AppRouter.subs,
                                                      ); // arahkan ke halaman subscribe
                                                  if (subscribed != null) {
                                                    if (subscribed == true) {
                                                      // masuk ke statistik
                                                      Navigator.pushNamed(
                                                        context,
                                                        AppRouter.statistics,
                                                      );
                                                    } else {
                                                      // no action
                                                    }
                                                  }
                                                });
                                              },
                                              child: const Text("Upgrade"),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        AppRouter.statistics,
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: context.themeColors.blueGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: context.themeColors.shadowBlue,
                                        blurRadius: 10,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            statistic
                                                ?.lastMonthData
                                                ?.pasien
                                                .total ??
                                            0,
                                        kehamilan:
                                            statistic
                                                ?.lastMonthData
                                                ?.kehamilan
                                                .total ??
                                            0,
                                        kunjungan:
                                            statistic
                                                ?.lastMonthData
                                                ?.kunjungan
                                                .total ??
                                            0,
                                        persalinan:
                                            statistic
                                                ?.lastMonthData
                                                ?.persalinan
                                                .total ??
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
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: FloatingActionButton.small(
                    heroTag: "complaintFab",
                    backgroundColor: context.themeColors.complaint,
                    onPressed: () {
                      BrowserLauncher.openInApp(
                        "https://forms.gle/2SR34kx1xjMgA3G27",
                      );
                    },
                    child: const Icon(Icons.feedback, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _shouldRegister(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Lengkapi Data"),
        content: const Text("Silakan lengkapi data terlebih dahulu."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, AppRouter.register);
            },
            child: const Text("Daftar Sekarang"),
          ),
        ],
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
