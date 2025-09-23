import 'package:ebidan/common/utility/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/data/models/bidan_model.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';

class PremiumWarningBanner extends StatelessWidget {
  final DateTime expiry;
  final PremiumType premiumType;

  const PremiumWarningBanner({
    super.key,
    required this.expiry,
    required this.premiumType,
  });

  /// Factory untuk dipakai langsung dari context
  static Widget? fromContext(BuildContext context, {VoidCallback? onTap}) {
    final user = context.watch<UserCubit>().state;
    final expiry = user?.expiryDate;
    final premiumType = user?.premiumType;

    if (expiry == null ||
        premiumType == null ||
        premiumType == PremiumType.none) {
      return null;
    }

    final now = DateTime.now();
    final daysLeft = expiry.difference(now).inDays;

    if (daysLeft > 7 || daysLeft < 0) return null;

    return PremiumWarningBanner(expiry: expiry, premiumType: premiumType);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysLeft = expiry.difference(now).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.themeColors.secondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.themeColors.secondary.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: () {
          debugPrint("perpanjang");
        },
        child: Row(
          children: [
            Icon(Icons.warning, color: context.themeColors.secondary),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: context.themeColors.onSurface),
                  children: [
                    TextSpan(
                      text:
                          "Akun ${premiumType == PremiumType.trial ? "Trial" : "Premium"} "
                          "Anda akan berakhir dalam $daysLeft hari. ",
                    ),
                    TextSpan(
                      text: "Klik untuk perpanjang",
                      style: TextStyle(
                        color: context.themeColors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
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
