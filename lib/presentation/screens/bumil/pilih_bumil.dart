import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/data/models/kehamilan_model.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:ebidan/logic/bumil/cubit/search_bumil_cubit.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PilihBumilScreen extends StatelessWidget {
  final String pilihState;
  const PilihBumilScreen({super.key, required this.pilihState});

  Future<void> _refresh(BuildContext context) async {
    await context.read<SearchBumilCubit>().fetchData();
  }

  @override
  Widget build(BuildContext context) {
    context.read<SearchBumilCubit>().fetchData();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Bumil'),
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
                hintText: 'Cari nama bumil...',
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
                if (state is BumilLoading) {
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
                          subtitle: Text('No HP: ${bumil.noHp}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            if (pilihState == 'bumil') {
                              Navigator.pushNamed(
                                context,
                                AppRouter.dataBumil,
                                arguments: {'bumil': bumil},
                              );
                            } else {
                              // pilihState == kunjungan
                              final latestKehamilan = await getLatestKehamilan(
                                bumilId: bumil.idBumil,
                                bidanId: bumil.idBidan,
                              );

                              if (latestKehamilan == null ||
                                  latestKehamilan.persalinan != null) {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.pendataanKehamilan,
                                  arguments: {
                                    'bumilId': bumil.idBumil,
                                    'age': bumil.age,
                                    'latestHistoryYear':
                                        bumil.latestRiwayat?.tahun,
                                    'jumlahRiwayat':
                                        bumil.statisticRiwayat['gravida'],
                                    'jumlahPara':
                                        bumil.statisticRiwayat['para'],
                                    'jumlahAbortus':
                                        bumil.statisticRiwayat['abortus'],
                                    'jumlahBeratRendah':
                                        bumil.statisticRiwayat['beratRendah'],
                                  },
                                );
                              } else {
                                final firstTime =
                                    latestKehamilan.kunjungan?.isEmpty;

                                if (firstTime == true) {
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.kunjungan,
                                    arguments: {
                                      'kehamilanId': latestKehamilan.id,
                                      'firstTime': true,
                                    },
                                  );
                                } else {
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.updateKehamilan,
                                    arguments: {
                                      'kehamilanId': latestKehamilan.id,
                                      'bumilId': latestKehamilan.idBumil,
                                      'resti': latestKehamilan.resti ?? [],
                                    },
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

  Future<Kehamilan?> getLatestKehamilan({
    required String bumilId,
    required String bidanId,
  }) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('kehamilan')
          .where('id_bumil', isEqualTo: bumilId)
          .where('id_bidan', isEqualTo: bidanId)
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data();

      // ambil subcollection kunjungan
      final kunjunganSnap = await doc.reference.collection('kunjungan').get();
      final kunjunganList = kunjunganSnap.docs
          .map((e) => Kunjungan.fromFirestore(e.data()))
          .toList();

      return Kehamilan.fromFirestore(doc.id, data, kunjunganList);
    } catch (e) {
      debugPrint('Error getLatestKehamilan: $e');
      return null;
    }
  }
}
