import 'package:ebidan/common/utility/app_colors.dart';
import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool enabled;

  const MenuButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color iconColor = enabled
        ? context.themeColors.primary
        : context.themeColors.primary.withOpacity(0.38);
    final Color textColor = enabled
        ? context.themeColors.onSurface
        : context.themeColors.onSurface.withOpacity(0.38);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null, // disable klik kalau tidak aktif
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: enabled
                    ? context.themeColors.onSurface
                    : context.themeColors.onSurface.withOpacity(0.38),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
