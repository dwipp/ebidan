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
            if (pilihState == 'bumil')
              BlocBuilder<SearchBumilCubit, SearchBumilState>(
                builder: (context, state) {
                  return IconButton(
                    tooltip: state.filter.showHamilOnly
                        ? 'Tampilkan semua'
                        : 'Filter hanya yang sedang hamil',
                    icon: Icon(
                      state.filter.showHamilOnly
                          ? Icons.pregnant_woman
                          : Icons.filter_alt_outlined,
                      color: state.filter.showHamilOnly
                          ? Colors.pink
                          : Colors.grey,
                    ),
                    onPressed: () {
                      if (!state.filter.showHamilOnly) {
                        context.read<SearchBumilCubit>().toggleFilterHamil();
                      } else {
                        context.read<SearchBumilCubit>().resetFilter();
                      }
                    },
                  );
                },
              ),
            if (pilihState == 'kunjungan')
              IconButton(
                icon: const Icon(Icons.add, color: Colors.lightBlueAccent),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(AppRouter.checkDataBumil)
                      .then((_) => _refresh(context));
                },
              ),
          ],
        ),
        body: Column(
          children: [
            // ===== Search =====
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

            // ===== Compact Filter (Status + Bulan) =====
            BlocBuilder<SearchBumilCubit, SearchBumilState>(
              builder: (context, state) {
                if (!state.filter.showHamilOnly) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      // Filter Status
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: state.filter.statuses.isNotEmpty
                              ? state.filter.statuses.first
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                          ),
                          items: ['K1', 'K2', 'K3', 'K4', 'K5', 'K6']
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              context.read<SearchBumilCubit>().setStatuses([
                                val,
                              ]);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Filter Month
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: state.filter.month ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              helpText: 'Pilih Bulan',
                            );
                            if (picked != null) {
                              final month = DateTime(picked.year, picked.month);
                              context.read<SearchBumilCubit>().setMonth(month);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Bulan',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  state.filter.month != null
                                      ? '${state.filter.month!.month}/${state.filter.month!.year}'
                                      : 'Pilih Bulan',
                                ),
                                const Icon(Icons.calendar_today, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // ===== List Data =====
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
                            onTap: () {
                              context.read<SelectedBumilCubit>().selectBumil(
                                bumil,
                              );

                              if (pilihState == 'bumil') {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.dataBumil,
                                ).then((_) => _refresh(context));
                              } else {
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
