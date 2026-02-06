import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/data/models/bidan_model.dart';
import 'package:ebidan/presentation/widgets/browser_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart';

class Utils {
  // ====== DATE ======

  /// Utility agar Timestamp/String bisa jadi DateTime
  static DateTime? toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static String formattedDate(DateTime? date) {
    if (date == null) return "-";
    // Format ke bahasa Indonesia: 1 Januari 1990
    return DateFormat("d MMMM yyyy", "id_ID").format(date);
  }

  static DateTime? parseDateKTP(String? tanggal) {
    if (tanggal == null) return null;
    try {
      final parts = tanggal.split('-');
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final dt = DateTime(year, month, day);

      // validasi tanggal palsu (misal 32-13-1991)
      if (dt.day != day || dt.month != month || dt.year != year) {
        return null;
      }

      return dt;
    } catch (_) {
      return null;
    }
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

  // Helper method untuk mendapatkan bulan-bulan terakhir
  static List<String> getLastMonths(String latestMonth, int count) {
    final DateFormat formatter = DateFormat("yyyy-MM");
    DateTime date = DateFormat("yyyy-MM").parse(latestMonth);
    List<String> months = [];

    for (int i = 0; i < count; i++) {
      DateTime target = DateTime(date.year, date.month - i, 1);
      months.add(formatter.format(target));
    }
    return months;
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

  // ====== MISC ======

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

  static Color generateDistinctColor(String label) {
    final hash = label.hashCode.abs();
    // Langkah besar antar hue untuk beda jauh
    final hueStep = 137.508; // bilangan irasional (golden angle)
    final hue = (hash * hueStep) % 360;

    final hsl = HSLColor.fromAHSL(
      1.0,
      hue,
      0.5, // saturasi cukup tinggi agar beda mencolok
      0.70, // lightness sedang agar tetap nyaman
    );

    return hsl.toColor();
  }

  static Color generateForegroundColor(Color background) {
    final luminance = background.computeLuminance();
    final hsl = HSLColor.fromColor(background);

    if (luminance < 0.5) {
      // background gelap → foreground terang sedikit tone sama
      return hsl
          .withLightness(0.9)
          .withSaturation(0.3)
          .toColor(); // terang lembut, tidak murni putih
    } else {
      // background terang → foreground gelap sedikit tone sama
      return hsl
          .withLightness(0.2)
          .withSaturation(0.4)
          .toColor(); // gelap tapi masih “nyambung” dengan warna latar
    }
  }

  static Color generateHighContrastColor(
    Color baseColor, {
    double saturationBoost = 1.6,
    double lightnessReduce = 0.25,
  }) {
    final hsl = HSLColor.fromColor(baseColor);

    final isLight = baseColor.computeLuminance() > 0.5;
    final newLightness = isLight
        ? (hsl.lightness - (lightnessReduce + 0.07)).clamp(0.0, 1.0)
        : (hsl.lightness - lightnessReduce).clamp(0.0, 1.0);

    final newSaturation = isLight
        ? (hsl.saturation * saturationBoost).clamp(0.0, 1.0)
        : (hsl.saturation * saturationBoost).clamp(0.0, 1.0);

    return hsl
        .withSaturation(newSaturation)
        .withLightness(newLightness)
        .toColor();
  }

  // ====== WIDGET ======
  static Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
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

  static Widget floatingComplaint(BuildContext context, Bidan user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (user.premiumUntil != null &&
            user.premiumUntil!.isAfter(
              DateTime.now().add(const Duration(days: 1)),
            )) ...[
          FloatingActionButton.small(
            heroTag: "complaintWa",
            backgroundColor: context.themeColors.complaintWa,
            onPressed: () {
              final auth = FirebaseAuth.instance.currentUser;
              if (auth == null) return;
              final message =
                  "Halo eBidan,\nsaya ${user.nama}\n(UID: ${auth.uid}),\n"
                  "ingin menyampaikan keluhan sebagai berikut:\n\n";

              final url =
                  "https://wa.me/628991904891?text=${Uri.encodeComponent(message)}";

              BrowserLauncher.openInApp(url);
            },
            child: Image.asset(
              'assets/icons/ic_wa.png',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ),
        ],

        SizedBox(height: 4),
        FloatingActionButton.small(
          heroTag: "complaintFab",
          backgroundColor: context.themeColors.complaint,
          onPressed: () {
            BrowserLauncher.openInApp("https://forms.gle/2SR34kx1xjMgA3G27");
          },
          child: const Icon(Icons.feedback, color: Colors.white),
        ),
      ],
    );
  }

  // ktp extractor
  static Future<String> getAssetPath(String asset) async {
    final path = await getLocalPath(asset);
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
    }
    return file.path;
  }

  static Future<String> getLocalPath(String path) async {
    return '${(await getApplicationSupportDirectory()).path}/$path';
  }

  static Future<File?> cropImage(File imageFile, DetectedObject object) async {
    final parse = await img.decodeImageFile(imageFile.absolute.path);
    if (parse == null) return null;
    final result = img.copyCrop(
      parse,
      x: object.boundingBox.left.toInt(),
      y: object.boundingBox.top.toInt(),
      width: (object.boundingBox.right - object.boundingBox.left).toInt(),
      height: (object.boundingBox.bottom - object.boundingBox.top).toInt(),
    );
    List<int> cropByte = [];
    cropByte = img.encodeJpg(result);
    final File imageFileCrop = await File(
      imageFile.absolute.path,
    ).writeAsBytes(cropByte);
    return imageFileCrop;
  }

  static Future<File?> cropPassportMrz(
    File imageFile,
    DetectedObject object,
  ) async {
    final parse = await img.decodeImageFile(imageFile.absolute.path);
    if (parse == null) return null;

    final passportCrop = img.copyCrop(
      parse,
      x: object.boundingBox.left.toInt(),
      y: object.boundingBox.top.toInt(),
      width: (object.boundingBox.right - object.boundingBox.left).toInt(),
      height: (object.boundingBox.bottom - object.boundingBox.top).toInt(),
    );

    final mrzHeight = (passportCrop.height * 0.25).toInt();
    final mrzY = passportCrop.height - mrzHeight;

    final mrzCrop = img.copyCrop(
      passportCrop,
      x: 0,
      y: mrzY,
      width: passportCrop.width,
      height: mrzHeight,
    );

    final enhanced = img.contrast(mrzCrop, contrast: 1.2);
    final sharpened = img.convolution(
      enhanced,
      filter: [0, -1, 0, -1, 5, -1, 0, -1, 0],
    );

    List<int> cropByte = img.encodeJpg(sharpened);
    final String tempPath =
        '${imageFile.parent.path}/mrz_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File mrzFile = await File(tempPath).writeAsBytes(cropByte);
    return mrzFile;
  }

  static String calculateCheckDigit(String input) {
    const weights = [7, 3, 1];
    int sum = 0;

    String cleanInput = input
        .replaceAll('«', '<')
        .replaceAll('»', '<')
        .replaceAll('‹', '<')
        .replaceAll('›', '<')
        .replaceAll('〈', '<')
        .replaceAll('〉', '<')
        .replaceAll('＜', '<')
        .replaceAll('＞', '<');

    for (int i = 0; i < cleanInput.length; i++) {
      final char = cleanInput[i];
      int value;

      if (char == '<') {
        value = 0;
      } else if (RegExp(r'\d').hasMatch(char)) {
        value = int.parse(char);
      } else {
        value = char.codeUnitAt(0) - 'A'.codeUnitAt(0) + 10;
      }

      sum += value * weights[i % 3];
    }

    return (sum % 10).toString();
  }

  static bool validateMrzChecksum(String data, String checkDigit) {
    return calculateCheckDigit(data) == checkDigit;
  }
}
