import 'package:ebidan/data/models/bidan_model.dart';
import 'package:ebidan/presentation/widgets/menu_button.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().state;
    final expiry = user?.expiryDate;
    final premiumType = user?.premiumType;

    Widget? warningBanner;

    if (expiry != null && premiumType != PremiumType.none) {
      final now = DateTime.now();
      final daysLeft = expiry.difference(now).inDays;

      if (daysLeft <= 7 && daysLeft >= 0) {
        warningBanner = Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: InkWell(
            onTap: () {
              print('perpanjang');
            },
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black87),
                      children: [
                        TextSpan(
                          text:
                              "Akun ${premiumType == PremiumType.trial ? "Trial" : "Premium"} "
                              "Anda akan berakhir dalam $daysLeft hari. ",
                        ),
                        TextSpan(
                          text: "Klik untuk perpanjang",
                          style: const TextStyle(
                            color: Colors.blue, // jadi biru
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration
                                .underline, // biar lebih kayak link
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

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
                Navigator.pushNamed(context, AppRouter.kunjunganStats);
              },
            ),
          ],
        ),
      ),
    );
  }
}
