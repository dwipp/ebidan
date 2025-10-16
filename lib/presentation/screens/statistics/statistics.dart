import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/widgets/menu_button.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/premium_warning_banner.dart';
import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final warningBanner = PremiumWarningBanner.fromContext(context);

    return Scaffold(
      appBar: PageHeader(title: Text('Statistik')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (warningBanner != null) warningBanner,
            MenuButton(
              icon: Icons.event_note,
              title: 'Kunjungan',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.kunjunganStats,
                  arguments: {'monthKey': Utils.getAutoYearMonth()},
                );
              },
            ),
            MenuButton(
              icon: Icons.health_and_safety,
              title: 'Resti',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.restiStats,
                  arguments: {'monthKey': Utils.getAutoYearMonth()},
                );
              },
            ),
            MenuButton(
              icon: Icons.bloodtype,
              title: 'Konsumsi Suplemen Fe',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.sfStats,
                  arguments: {'monthKey': Utils.getAutoYearMonth()},
                );
              },
            ),
            MenuButton(
              icon: Icons.health_and_safety,
              title: 'Persalinan',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.persalinanStats,
                  arguments: {'monthKey': Utils.getAutoYearMonth()},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
