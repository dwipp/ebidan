import 'package:ebidan/presentation/widgets/menu_button.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:flutter/material.dart';

class UpdateKehamilanScreen extends StatelessWidget {
  final String kehamilanId;
  final String bumilId;
  final List<String> resti;
  final DateTime? hpht;

  const UpdateKehamilanScreen({
    super.key,
    required this.kehamilanId,
    required this.bumilId,
    required this.resti,
    this.hpht,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title: 'Update Kehamilan'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MenuButton(
              icon: Icons.calendar_month,
              title: 'Kunjungan Baru',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.kunjungan,
                  arguments: {
                    'bumilId': bumilId,
                    'kehamilanId': kehamilanId,
                    'firstTime': false,
                  },
                );
              },
            ),
            MenuButton(
              icon: Icons.pregnant_woman,
              title: 'Persalinan',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.addPersalinan,
                  arguments: {
                    'kehamilanId': kehamilanId,
                    'bumilId': bumilId,
                    'resti': resti,
                    'hpht': hpht,
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
