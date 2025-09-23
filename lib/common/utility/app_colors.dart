import 'package:flutter/material.dart';

extension AppColors on BuildContext {
  ColorScheme get themeColors => Theme.of(this).colorScheme;
}
