import 'package:ebidan/data/models/persalinan_model.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:flutter/material.dart';

class ListPersalinanScreen extends StatelessWidget {
  final List<Persalinan> persalinans;

  const ListPersalinanScreen({super.key, required this.persalinans});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title: "Persalinan"),
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
