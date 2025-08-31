import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/data/models/riwayat_model.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListRiwayatBumilScreen extends StatefulWidget {
  const ListRiwayatBumilScreen({super.key});

  @override
  State<ListRiwayatBumilScreen> createState() => _ListRiwayatBumilScreenState();
}

class _ListRiwayatBumilScreenState extends State<ListRiwayatBumilScreen> {
  late List<Riwayat> _riwayatList;
  Bumil? bumil;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ambil state dari cubit
    bumil = context.watch<SelectedBumilCubit>().state;

    if (bumil?.riwayat != null) {
      _riwayatList = List.from(bumil!.riwayat!);
      _sortList();
    } else {
      _riwayatList = [];
    }
  }

  void _sortList() {
    _riwayatList.sort((a, b) => b.tahun.compareTo(a.tahun));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(
        title: "Riwayat Kehamilan",
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.lightBlueAccent),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRouter.addRiwayat,
                arguments: {
                  'state': 'lateUpdate',
                  'bumilId': bumil?.idBumil,
                  'age': (bumil?.birthdateIbu != null
                      ? DateTime.now().year - bumil!.birthdateIbu!.year
                      : 0),
                },
              );

              if (result != null && result is List<Riwayat>) {
                setState(() {
                  _riwayatList.addAll(result);
                  _sortList();
                });
              }
            },
          ),
        ],
      ),
      body: _riwayatList.isEmpty
          ? const Center(child: Text('Belum ada riwayat'))
          : ListView.builder(
              itemCount: _riwayatList.length,
              itemBuilder: (context, i) {
                final Riwayat riwayat = _riwayatList[i];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text(
                      "Tahun ${riwayat.tahun}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(riwayat.statusTerm),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.detailRiwayat,
                        arguments: {'riwayat': riwayat},
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
