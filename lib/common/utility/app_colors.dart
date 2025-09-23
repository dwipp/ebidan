import 'package:flutter/material.dart';

extension AppColors on BuildContext {
  ColorScheme get themeColors => Theme.of(this).colorScheme;
}

extension Gradients on ColorScheme {
  LinearGradient get pinkGradient => LinearGradient(
    colors: brightness == Brightness.dark
        ? [Colors.pink.shade800, Colors.pink.shade400]
        : [Colors.pink.shade200, Colors.pink.shade100],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  LinearGradient get blueGradient => LinearGradient(
    colors: brightness == Brightness.dark
        ? [Colors.blue.shade800, Colors.blue.shade400]
        : [Colors.blue.shade300, Colors.blue.shade100],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

extension CustomColors on ColorScheme {
  Color get darkGrey => brightness == Brightness.dark
      ? Colors.grey.shade600
      : Colors.grey.shade800;

  Color get shadowPink => brightness == Brightness.dark
      ? Colors.transparent
      : Colors.pink.shade100.withOpacity(0.4);
  Color get shadowBlue => brightness == Brightness.dark
      ? Colors.transparent
      : Colors.blue.shade100.withOpacity(0.4);
}
