import 'package:flutter/material.dart';

extension AppColors on BuildContext {
  ColorScheme get themeColors => Theme.of(this).colorScheme;
}

extension Gradients on ColorScheme {
  LinearGradient get pinkGradient => LinearGradient(
    colors: brightness == Brightness.dark
        ? [Colors.pink.shade800, Colors.pink.shade300]
        : [Colors.pink.shade200, Colors.pink.shade100],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  LinearGradient get blueGradient => LinearGradient(
    colors: brightness == Brightness.dark
        ? [Colors.blue.shade800, Colors.blue.shade300]
        : [Colors.blue.shade300, Colors.blue.shade100],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  LinearGradient get tealGradient => LinearGradient(
    colors: brightness == Brightness.dark
        ? [Colors.teal.shade800, Colors.teal.shade300]
        : [Colors.teal.shade300, Colors.teal.shade100],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  LinearGradient get orangeGradient => LinearGradient(
    colors: brightness == Brightness.dark
        ? [Colors.orange.shade800, Colors.orange.shade300]
        : [Colors.orange.shade300, Colors.orange.shade100],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

extension CustomColors on ColorScheme {
  Color get darkGrey => brightness == Brightness.dark
      ? Colors.grey.shade600
      : Colors.grey.shade800;
  Color get suffixText =>
      brightness == Brightness.dark ? Colors.grey.shade400 : Colors.black54;
  Color get hintText =>
      brightness == Brightness.dark ? Colors.grey.shade800 : Colors.black26;
  Color get complaint => brightness == Brightness.dark
      ? Colors.redAccent
      : Colors.redAccent.shade100;

  Color get shadowPink => brightness == Brightness.dark
      ? Colors.transparent
      : Colors.pink.shade100.withOpacity(0.4);
  Color get shadowBlue => brightness == Brightness.dark
      ? Colors.transparent
      : Colors.blue.shade100.withOpacity(0.4);
  Color get premiumBg => brightness == Brightness.dark
      ? Colors.green.shade100.withOpacity(0.5)
      : Colors.green.shade100;
  Color get trialBg => brightness == Brightness.dark
      ? Colors.orange.shade100.withOpacity(0.5)
      : Colors.orange.shade100;
  Color get nonPremiumBg => brightness == Brightness.dark
      ? Colors.red.shade100.withOpacity(0.5)
      : Colors.red.shade100;
}
