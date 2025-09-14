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
      appBar: PageHeader(title: 'Statistik'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (warningBanner != null) warningBanner,
            MenuButton(
              icon: Icons.history,
              title: 'Kunjungan',
              onTap: () {
                Navigator.pushNamed(context, AppRouter.kunjunganStats, arguments: {'monthKey':null});
              },
            ),
          ],
        ),
      ),
    );
  }
}
