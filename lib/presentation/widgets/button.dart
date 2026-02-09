import 'package:ebidan/common/utility/app_colors.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final bool secondaryButton;
  final bool isSubmitting;
  final VoidCallback? onPressed;
  final String label;
  final String loadingLabel;
  final IconData? icon;

  const Button({
    super.key,
    this.secondaryButton = false,
    required this.isSubmitting,
    required this.onPressed,
    required this.label,
    this.loadingLabel = 'Loading...',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isSubmitting ? null : onPressed,
      icon: isSubmitting
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: context.themeColors.tertiary,
                strokeWidth: 2,
              ),
            )
          : icon != null
          ? Icon(icon)
          : null,
      label: Text(isSubmitting ? loadingLabel : label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: secondaryButton
            ? null
            : Theme.of(context).colorScheme.primary,
        foregroundColor: secondaryButton ? null : Colors.white,
      ),
    );
  }
}
