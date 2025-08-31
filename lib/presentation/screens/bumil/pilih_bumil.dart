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
    return Scaffold(
      appBar: PageHeader(
        title: 'Pilih Bumil',
        actions: [
          pilihState == 'kunjungan'
              ? IconButton(
                  icon: const Icon(Icons.add, color: Colors.lightBlueAccent),
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRouter.addBumil);
                  },
                )
              : const SizedBox(),
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
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.filteredList.isEmpty) {
                  return const Center(child: Text('Data tidak ditemukan.'));
                }

                // Tambahkan RefreshIndicator di sini
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
                              Navigator.pushNamed(context, AppRouter.dataBumil);
                            } else {
                              // pilihState == kunjungan
                              // final latestKehamilan = await getLatestKehamilan(
                              //   bumilId: bumil.idBumil,
                              //   bidanId: bumil.idBidan,
                              // );
                              print('latest id; ${bumil.latestKehamilanId}');
                              print(
                                'latest persalinan: ${bumil.latestKehamilanPersalinan}',
                              );
                              print(
                                'latest kubnjungan: ${bumil.latestKehamilanKunjungan}',
                              );
                              if (bumil.latestKehamilanId == null ||
                                  bumil.latestKehamilanPersalinan == true) {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.addKehamilan,
                                );
                              } else {
                                final firstTime =
                                    !bumil.latestKehamilanKunjungan;

                                if (firstTime == true) {
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.kunjungan,
                                    arguments: {'firstTime': true},
                                  );
                                } else {
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.updateKehamilan,
                                  );
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
    );
  }
}
