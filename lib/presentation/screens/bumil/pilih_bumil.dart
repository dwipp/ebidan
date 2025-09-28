import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/bumil/cubit/search_bumil_cubit.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/general/cubit/connectivity_cubit.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PilihBumilScreen extends StatelessWidget {
  final String pilihState;
  const PilihBumilScreen({super.key, required this.pilihState});

  Future<void> _refresh(BuildContext context) async {
    await context.read<SearchBumilCubit>().fetchData(
      context.read<ConnectivityCubit>().state,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.read<SearchBumilCubit>().fetchData(
      context.read<ConnectivityCubit>().state,
    );
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        context.read<SearchBumilCubit>().resetFilter();
      },
      child: Scaffold(
        appBar: PageHeader(
          title: const Text('Pilih Bumil'),
          actions: [
            // === Tombol filter isHamil ===
            BlocBuilder<SearchBumilCubit, SearchBumilState>(
              builder: (context, state) {
                return IconButton(
                  tooltip: state.showHamilOnly
                      ? 'Tampilkan semua'
                      : 'Filter hanya yang sedang hamil',
                  icon: Icon(
                    state.showHamilOnly
                        ? Icons
                              .pregnant_woman // ikon khusus biar jelas
                        : Icons.filter_alt_outlined,
                    color: state.showHamilOnly ? Colors.pink : Colors.grey,
                  ),
                  onPressed: () {
                    context.read<SearchBumilCubit>().toggleFilterHamil();
                  },
                );
              },
            ),
            if (pilihState == 'kunjungan')
              IconButton(
                icon: const Icon(Icons.add, color: Colors.lightBlueAccent),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(AppRouter.checkDataBumil).then((_) {
                    _refresh(context);
                  });
                },
              ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Nama atau NIK...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (val) {
                  context.read<SearchBumilCubit>().search(val);
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchBumilCubit, SearchBumilState>(
                builder: (context, state) {
                  if (state is BumilLoading && state.bumilList.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: context.themeColors.tertiary,
                      ),
                    );
                  }

                  if (state.filteredList.isEmpty) {
                    return const Center(child: Text('Data tidak ditemukan.'));
                  }

                  return RefreshIndicator(
                    onRefresh: () => _refresh(context),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.filteredList.length,
                      itemBuilder: (context, i) {
                        Bumil bumil = state.filteredList[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            title: Text(bumil.namaIbu),
                            subtitle: Text('NIK: ${bumil.nikIbu}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              context.read<SelectedBumilCubit>().selectBumil(
                                bumil,
                              );

                              if (pilihState == 'bumil') {
                                print('isHamil: ${state.showHamilOnly}');
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.dataBumil,
                                ).then((_) => _refresh(context));
                              } else {
                                // === pilihState == kunjungan ===
                                if (bumil.latestKehamilanId == null ||
                                    bumil.latestKehamilanPersalinan == true) {
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.addKehamilan,
                                  ).then((_) => _refresh(context));
                                } else {
                                  final firstTime =
                                      !bumil.latestKehamilanKunjungan;

                                  if (firstTime) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRouter.kunjungan,
                                      arguments: {'firstTime': true},
                                    ).then((_) => _refresh(context));
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      AppRouter.updateKehamilan,
                                    ).then((_) => _refresh(context));
                                  }
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
