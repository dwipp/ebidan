import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/search_bumil_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/selected_bumil_cubit.dart';
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
      child: BlocBuilder<SearchBumilCubit, SearchBumilState>(
        builder: (context, state) {
          return Scaffold(
            appBar: PageHeader(
              title: state.filter.showHamilOnly
                  ? const Text("Pilih Ibu Hamil")
                  : const Text("Pilih Pasien"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.cyan),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(
                          AppRouter.addBumil,
                          arguments: {'fromReg': false},
                        )
                        .then((_) => _refresh(context));
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // ===== Search Box dalam Card =====
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 1,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari nama atau NIK...',
                              prefixIcon: const Icon(Icons.search),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                            onChanged: (val) {
                              context.read<SearchBumilCubit>().search(val);
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        tooltip: state.filter.showHamilOnly
                            ? 'Tampilkan semua'
                            : 'Filter hanya yang sedang hamil',
                        icon: Icon(
                          state.filter.showHamilOnly
                              ? Icons.pregnant_woman
                              : Icons.filter_alt_outlined,
                          color: state.filter.showHamilOnly
                              ? Colors.pinkAccent
                              : Colors.grey,
                        ),
                        onPressed: () {
                          if (!state.filter.showHamilOnly) {
                            context
                                .read<SearchBumilCubit>()
                                .toggleFilterHamil();
                            context.read<SearchBumilCubit>().setStatus('Semua');
                          } else {
                            context.read<SearchBumilCubit>().resetFilter();
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // ===== Filter Section =====
                if (state.filter.showHamilOnly)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Status Chips
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      [
                                            'Semua',
                                            'K1',
                                            'K2',
                                            'K3',
                                            'K4',
                                            'K5',
                                            'K6',
                                          ]
                                          .map(
                                            (s) => Padding(
                                              padding: const EdgeInsets.only(
                                                right: 6,
                                              ),
                                              child: ChoiceChip(
                                                label: Text(s),
                                                selected: state.filter.statuses
                                                    .contains(s),
                                                selectedColor: Colors.pink[100],
                                                onSelected: (_) {
                                                  context
                                                      .read<SearchBumilCubit>()
                                                      .setStatus(s);
                                                },
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 4),

                // ===== List Data =====
                Expanded(
                  child: () {
                    if (state is BumilLoading && state.bumilList.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: context.themeColors.tertiary,
                        ),
                      );
                    }

                    if (state.filteredList.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Data tidak ditemukan',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => _refresh(context),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.filteredList.length,
                        itemBuilder: (context, i) {
                          final bumil = state.filteredList[i];
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.pink[50],
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                              title: Text(
                                bumil.namaIbu,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                'NIK: ${bumil.nikIbu.isNotEmpty ? bumil.nikIbu : '-'}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                context.read<SelectedBumilCubit>().selectBumil(
                                  bumil,
                                );

                                Navigator.pushNamed(
                                  context,
                                  AppRouter.dataBumil,
                                ).then((_) => _refresh(context));
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
