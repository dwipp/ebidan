import 'package:ebidan/data/models/persalinan_model.dart';
import 'package:ebidan/logic/utility/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';

class ListPersalinanScreen extends StatelessWidget {
  final List<Persalinan> persalinans;

  const ListPersalinanScreen({super.key, required this.persalinans});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kunjungan"),
        actions: [
          // IconButton(
          //   icon: Icon(_sortDesc ? Icons.arrow_downward : Icons.arrow_upward),
          //   tooltip: _sortDesc ? "Urutkan Ascending" : "Urutkan Descending",
          //   onPressed: _toggleSort,
          // ),
        ],
      ),
      body: ListView.builder(
        itemCount: persalinans.length,
        itemBuilder: (context, index) {
          final persalinan = persalinans[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(Utils.formattedDateTime(persalinan.tglPersalinan)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.detailPersalinan,
                  arguments: {'persalinan': persalinan},
                );
              },
            ),
          );
        },
      ),
    );
  }
}
