import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/data/models/kehamilan_model.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/kehamilan/cubit/get_kehamilan_cubit.dart';
import 'package:ebidan/state_management/kehamilan/cubit/selected_kehamilan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListKehamilanScreen extends StatefulWidget {
  const ListKehamilanScreen({super.key});

  @override
  State<ListKehamilanScreen> createState() => _ListKehamilanScreenState();
}

class _ListKehamilanScreenState extends State<ListKehamilanScreen> {
  List<Kehamilan> _kehamilanList = [];
  bool _loading = false;
  bool _expanded = false; // tanda apakah user sudah fetch semua

  @override
  void initState() {
    context.read<GetKehamilanCubit>().setInitial();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    context.read<SelectedKehamilanCubit>().clear;
    final bumil = context.watch<SelectedBumilCubit>().state;
    return Scaffold(
      appBar: PageHeader(title: Text("List Kehamilan")),
      body: BlocConsumer<GetKehamilanCubit, GetKehamilanState>(
        listener: (context, state) {
          if (state is GetKehamilanSuccess) {
            _kehamilanList = state.kehamilans;
            _expanded = true;
            _loading = false;
          } else if (state is GetKehamilanEmpty) {
            _expanded = true;
            _loading = false;
          } else if (state is GetKehamilanLoading) {
            _expanded = false;
            _loading = true;
          } else if (state is GetKehamilanFailure) {
            Snackbar.show(
              context,
              message: 'Gagal: ${state.message}',
              type: SnackbarType.error,
            );
            _expanded = false;
            _loading = false;
          }
        },
        builder: (context, state) {
          return ListView(
            children: [
              // item pertama: latest kehamilan
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                    "Tahun ${bumil?.latestKehamilan?.createdAt!.year}",
                  ),
                  subtitle: Text(
                    "Status persalinan: ${bumil?.latestKehamilan?.persalinan != null ? 'sudah' : 'belum'}",
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    print(
                      'bumil?.latestKehamilan: ${bumil?.latestKehamilan?.noKohortIbu}',
                    );
                    if (bumil?.latestKehamilan != null) {
                      context.read<SelectedKehamilanCubit>().selectKehamilan(
                        bumil!.latestKehamilan!,
                      );
                      Navigator.pushNamed(context, AppRouter.detailKehamilan);
                    }
                  },
                ),
              ),

              // item kedua: tombol atau daftar riwayat
              if (_expanded)
                ..._kehamilanList
                    .skip(1)
                    .map(
                      (kehamilan) => Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text("Tahun ${kehamilan.createdAt!.year}"),
                          subtitle: Text(
                            "Status persalinan: ${kehamilan.persalinan != null ? 'sudah' : 'belum'}",
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context
                                .read<SelectedKehamilanCubit>()
                                .selectKehamilan(kehamilan);
                            Navigator.pushNamed(
                              context,
                              AppRouter.detailKehamilan,
                            );
                          },
                        ),
                      ),
                    )
              else
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _loading
                        ? null
                        : () {
                            context.read<GetKehamilanCubit>().getKehamilan(
                              bumilId: bumil!.idBumil,
                            );
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      child: Center(
                        child: _loading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: context.themeColors.tertiary,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.history, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text(
                                    "Lihat kehamilan sebelumnya",
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.expand_more, color: Colors.grey),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
