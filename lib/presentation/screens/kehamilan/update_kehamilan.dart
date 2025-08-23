import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';

class UpdateKehamilanScreen extends StatelessWidget {
  final String kehamilanId;
  final String bumilId;

  const UpdateKehamilanScreen({
    super.key,
    required this.kehamilanId,
    required this.bumilId,
  });

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
        title: Text('Update Kehamilan'),
        // centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMenuButton(
              icon: Icons.calendar_month,
              title: 'Kunjungan Baru',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.kunjungan,
                  arguments: {'kehamilanId': kehamilanId, 'firstTime': false},
                );
              },
            ),
            _buildMenuButton(
              icon: Icons.pregnant_woman,
              title: 'Persalinan',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.addPersalinan,
                  arguments: {'kehamilanId': kehamilanId, 'bumilId': bumilId},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
