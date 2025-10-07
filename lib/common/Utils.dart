import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/common/utility/app_colors.dart';
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

  static String formattedDateFromYearMonth(String key) {
    try {
      // key format: yyyy-MM
      final date = DateFormat('yyyy-MM').parse(key);
      return DateFormat('MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return key; // fallback kalau parsing gagal
    }
  }

  static String formattedYearMonth(DateTime date) {
    try {
      return DateFormat('yyyy-MM').format(date).toString();
    } catch (e) {
      return '';
    }
  }

  // mendapatkan format yyyy-MM dengan date bulan lalu jika tgl 1-7
  static String getAutoYearMonth() {
    final now = DateTime.now();
    if (now.day >= 7) {
      // tanggal 8–31, pakai bulan ini
      var date = DateTime(now.year, now.month);
      return DateFormat('yyyy-MM').format(date).toString();
    } else {
      // tanggal 1–7, pakai bulan sebelumnya
      final prevMonth = DateTime(now.year, now.month - 1);
      var date = DateTime(prevMonth.year, prevMonth.month);
      return DateFormat('yyyy-MM').format(date).toString();
    }
  }

  static int hitungJarakTahun({
    required DateTime? tglLahir,
    DateTime? tglKehamilanBaru,
  }) {
    if (tglLahir == null) return 0;

    final tglKehamilan = tglKehamilanBaru ?? DateTime.now();
    int tahun = tglKehamilan.year - tglLahir.year;

    // Kalau bulan sekarang < bulan lahir, atau bulan sama tapi hari sekarang < hari lahir,
    // berarti belum genap setahun → kurangi 1
    if (tglKehamilan.month < tglLahir.month ||
        (tglKehamilan.month == tglLahir.month &&
            tglKehamilan.day < tglLahir.day)) {
      tahun -= 1;
    }

    return tahun;
  }

  static Widget generateRowLabelValue(
    BuildContext context, {
    required String label,
    String? value,
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
              color: context.themeColors.onTertiary, // bg label
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

  static String hitungUsiaKehamilan({
    required DateTime? hpht,
    required DateTime? tglKunjungan,
  }) {
    final today = tglKunjungan ?? DateTime.now();
    if (hpht != null) {
      final selisihHari = today.difference(hpht).inDays;

      if (selisihHari < 0) {
        return '0 minggu';
      }

      final minggu = selisihHari ~/ 7;
      final hari = selisihHari % 7;

      return '$minggu minggu ${hari > 0 ? '$hari hari' : ''}'.trim();
    }
    return '-';
  }

  static DateTime? hitungHTP(DateTime? hpht) {
    if (hpht != null) {
      // Tambah 7 hari
      DateTime tambahHari = hpht.add(const Duration(days: 7));

      // Tambah 9 bulan
      int bulan = tambahHari.month + 9;
      int tahun = tambahHari.year;

      if (bulan > 12) {
        bulan -= 12;
        tahun += 1;
      }

      int hari = tambahHari.day;
      int maxHari = DateTime(tahun, bulan + 1, 0).day;
      if (hari > maxHari) {
        hari = maxHari;
      }
      return DateTime(tahun, bulan, hari);
    }
    return null;
  }
}
