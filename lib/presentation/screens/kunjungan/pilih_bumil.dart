import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/logic/general/cubit/bumil_cubit.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PilihBumilScreen extends StatelessWidget {
  const PilihBumilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<BumilCubit>().fetchData();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Bumil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.lightBlueAccent),
            onPressed: () {
              // print('tambah bumil');
              Navigator.of(context).pushNamed(AppRouter.addBumil);
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
                hintText: 'Cari nama bumil...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (val) {
                context.read<BumilCubit>().search(val);
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<BumilCubit, BumilState>(
              builder: (context, state) {
                print('update: ${state.filteredList}');
                // print('loading: ${state.loading}');
                if (state is BumilLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.filteredList.isEmpty) {
                  return const Center(child: Text('Data tidak ditemukan.'));
                }

                return ListView.builder(
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
                          // print('selected bumil: ${b.namaIbu}');
                          final latestKehamilanId =
                              await getLatestKehamilanDocId(
                                bumilId: bumil.idBumil,
                                bidanId: bumil.idBidan,
                              );

                          if (latestKehamilanId != null) {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRouter.kunjungan,
                              arguments: {'kehamilanId': latestKehamilanId},
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> getLatestKehamilanDocId({
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

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      debugPrint('Error getLatestKehamilanDocId: $e');
      return null;
    }
  }
}
