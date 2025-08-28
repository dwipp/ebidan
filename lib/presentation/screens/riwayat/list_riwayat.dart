import 'package:ebidan/data/models/riwayat_model.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:flutter/material.dart';

class ListRiwayatBumilScreen extends StatefulWidget {
  final String idBumil;
  final DateTime? birthdayIbu;
  final List<Riwayat> riwayatList;

  const ListRiwayatBumilScreen({
    super.key,
    required this.riwayatList,
    required this.idBumil,
    required this.birthdayIbu,
  });

  @override
  State<ListRiwayatBumilScreen> createState() => _ListRiwayatBumilScreenState();
}

class _ListRiwayatBumilScreenState extends State<ListRiwayatBumilScreen> {
  late List<Riwayat> _riwayatList;

  @override
  void initState() {
    super.initState();
    // copy supaya bisa dimodifikasi
    _riwayatList = List.from(widget.riwayatList);
    _sortList();
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
                AppRouter.addRiwayatBumil,
                arguments: {
                  'state': 'lateUpdate',
                  'bumilId': widget.idBumil,
                  'age': (widget.birthdayIbu != null
                      ? DateTime.now().year - widget.birthdayIbu!.year
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
