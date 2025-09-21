import 'package:cloud_firestore/cloud_firestore.dart';
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

  static String formattedDateTime(DateTime? date) {
    if (date == null) return "-";
    // Format ke bahasa Indonesia: 1 Januari 1990
    return DateFormat("d MMMM yyyy, HH:mm", "id_ID").format(date);
  }

  static String formattedYearMonth(String key) {
    try {
      // key format: yyyy-MM
      final date = DateFormat('yyyy-MM').parse(key);
      return DateFormat('MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return key; // fallback kalau parsing gagal
    }
  }

  static int hitungJarakTahun(DateTime? tglLahir) {
    if (tglLahir == null) return 0;

    final now = DateTime.now();
    int tahun = now.year - tglLahir.year;

    // Kalau bulan sekarang < bulan lahir, atau bulan sama tapi hari sekarang < hari lahir,
    // berarti belum genap setahun → kurangi 1
    if (now.month < tglLahir.month ||
        (now.month == tglLahir.month && now.day < tglLahir.day)) {
      tahun -= 1;
    }

    return tahun;
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

  static void sortByDateTime<T>(
    List<T> list,
    DateTime Function(T item) getDateTime, {
    bool descending = true,
  }) {
    list.sort((a, b) {
      final dateA = getDateTime(a);
      final dateB = getDateTime(b);

      return descending ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });
  }

  static Future<bool> hasAnyPendingWrites() async {
    final collections = ["bumil", "kehamilan", "kunjungan"];

    for (final col in collections) {
      final snapshot = await FirebaseFirestore.instance
          .collection(col)
          .get(const GetOptions(source: Source.cache));

      final hasPending = snapshot.docs.any(
        (doc) => doc.metadata.hasPendingWrites,
      );
      if (hasPending) {
        return true;
      }
    }

    return false;
  }

  static void showSnackBar(
    BuildContext context, {
    required String content,
    required bool isSuccess,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }
}
