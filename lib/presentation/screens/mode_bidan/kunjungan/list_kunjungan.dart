import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/data/models/bidan_model.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/kunjungan/cubit/get_kunjungan_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/kunjungan/cubit/selected_kunjungan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListKunjunganScreen extends StatefulWidget {
  final String docId;

  const ListKunjunganScreen({super.key, required this.docId});

  @override
  State<ListKunjunganScreen> createState() => _ListKunjunganScreenState();
}

class _ListKunjunganScreenState extends State<ListKunjunganScreen> {
  List<Kunjungan> _kunjunganList = [];
  bool _sortDesc = true; // default: terbaru di atas
  Bidan? user;

  @override
  void initState() {
    super.initState();
    context.read<GetKunjunganCubit>().getKunjungan(kehamilanId: widget.docId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = context.watch<UserCubit>().state;
  }

  void _toggleSort() {
    setState(() {
      _sortDesc = !_sortDesc;
      Utils.sortByDateTime<Kunjungan>(
        _kunjunganList,
        (k) => k.createdAt!,
        descending: _sortDesc,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    context.read<SelectedKunjunganCubit>().clear();

    return Scaffold(
      appBar: PageHeader(
        title: const Text("Kunjungan"),
        actions: [
          IconButton(
            icon: Icon(_sortDesc ? Icons.arrow_downward : Icons.arrow_upward),
            tooltip: _sortDesc ? "Urutkan Ascending" : "Urutkan Descending",
            onPressed: _toggleSort,
          ),
        ],
      ),
      body: Stack(
        children: [
          BlocConsumer<GetKunjunganCubit, GetKunjunganState>(
            listener: (context, state) {
              if (state is GetKunjunganSuccess) {
                _kunjunganList = state.kunjungans;
              } else if (state is GetKunjunganFailure) {
                Snackbar.show(
                  context,
                  message: 'Gagal: ${state.message}',
                  type: SnackbarType.error,
                );
              }
            },
            builder: (context, state) {
              if (state is GetKunjunganLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: context.themeColors.tertiary,
                  ),
                );
              } else if (state is GetKunjunganEmpty ||
                  state is GetKunjunganFailure) {
                return const Center(child: Text("Tidak ada data kunjungan"));
              }

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 60,
                ), // biar gak ketutupan container bawah
                child: ListView.builder(
                  itemCount: _kunjunganList.length,
                  itemBuilder: (context, index) {
                    final kunjungan = _kunjunganList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text(Utils.formattedDate(kunjungan.createdAt)),
                        subtitle: kunjungan.status == '-'
                            ? null
                            : Text('status: ${kunjungan.status}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context
                              .read<SelectedKunjunganCubit>()
                              .selectKunjungan(kunjungan);
                          Navigator.pushNamed(
                            context,
                            AppRouter.detailKunjungan,
                          ).then((value) {
                            context.read<GetKunjunganCubit>().getKunjungan(
                              kehamilanId: widget.docId,
                            );
                          });
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Sticky bottom container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: InkWell(
              onTap: () {
                if (user != null && !user!.premiumStatus.isPremium) {
                  // User bukan premium
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Akses Premium"),
                      content: const Text(
                        "Fitur ini hanya tersedia untuk pengguna premium. "
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
                            Future.microtask(() async {
                              final subscribed = await Navigator.pushNamed(
                                context,
                                AppRouter.subs,
                              ); // arahkan ke halaman subscribe
                              if (subscribed != null) {
                                if (subscribed == true) {
                                  // masuk ke grafik kunjungan
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.grafikKunjungan,
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
                  Navigator.pushNamed(context, AppRouter.grafikKunjungan);
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
                        Icon(Icons.show_chart, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "Grafik Perkembangan Kehamilan",
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
