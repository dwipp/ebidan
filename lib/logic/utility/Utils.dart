import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  static String formattedDate(DateTime? date) {
    if (date == null) return "-";
    // Format ke bahasa Indonesia: 1 Januari 1990
    return DateFormat("d MMMM yyyy", "id_ID").format(date);
  }

  static Widget generateRowLabelValue(
    String label,
    String? value, {
    String suffix = '',
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade100, // bg label
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.transparent, // bg value
              alignment: Alignment.centerLeft,
              child: Text(
                (value != null && value.isNotEmpty) ? '$value $suffix' : "-",
                softWrap: true,
                maxLines: null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
