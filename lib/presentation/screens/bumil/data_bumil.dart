import 'package:ebidan/common/menu_button.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';

class DataBumilScreen extends StatelessWidget {
  final Bumil bumil;

  const DataBumilScreen({super.key, required this.bumil});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bumil.namaIbu),
        // centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MenuButton(
              icon: Icons.person,
              title: 'Detail Bumil',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.detailBumil,
                  arguments: {'bumil': bumil},
                );
              },
            ),
            MenuButton(
              icon: Icons.history,
              title: 'Riwayat Bumil',
              onTap: () {
                if (bumil.riwayat != null) {
                  Navigator.pushNamed(
                    context,
                    AppRouter.listRiwayat,
                    arguments: {'riwayatList': bumil.riwayat},
                  );
                } else {
                  // tampilan toast bahwa tidak ada riwayat
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tidak ada riwayat kehamilan'),
                    ),
                  );
                }
              },
            ),
            MenuButton(
              icon: Icons.pregnant_woman,
              title: 'Data Kehamilan Bumil',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.listKehamilan,
                  arguments: {
                    'bidanId': bumil.idBidan,
                    'bumilId': bumil.idBumil,
                  },
                );
              },
            ),
            // MenuButton(
            //   icon: Icons.calendar_month,
            //   title: 'Kunjungan (Hamil Terbaru)',
            //   onTap: () {
            //     Navigator.pushNamed(
            //       context,
            //       AppRouter.listKunjungan,
            //       arguments: {
            //         'bidanId': bumil.idBidan,
            //         'bumilId': bumil.idBumil,
            //       },
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
