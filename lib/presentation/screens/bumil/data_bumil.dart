import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';

class DataBumilScreen extends StatelessWidget {
  final Bumil bumil;

  const DataBumilScreen({super.key, required this.bumil});

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue, size: 28),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bumil.namaIbu),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMenuButton(
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
            _buildMenuButton(
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
            _buildMenuButton(
              icon: Icons.pregnant_woman,
              title: 'Data Kehamilan Bumil',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
