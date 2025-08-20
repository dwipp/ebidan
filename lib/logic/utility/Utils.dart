import 'package:flutter/material.dart';

class Utils {
  /// Ambil nama route sebelumnya sesuai level.
  /// level=1 -> 1 level sebelumnya
  /// level=2 -> 2 level sebelumnya
  static String? getPreviousRouteName(BuildContext context, {int level = 1}) {
    final navigator = Navigator.of(context);
    final routes = <Route<dynamic>>[];

    navigator.popUntil((route) {
      routes.add(route);
      return true;
    });

    final targetIndex = routes.length - 1 - level;

    if (targetIndex >= 0) {
      return routes[targetIndex].settings.name;
    }
    return null;
  }

  static Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
