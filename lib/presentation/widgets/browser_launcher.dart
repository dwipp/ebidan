import 'package:url_launcher/url_launcher.dart';

class BrowserLauncher {
  static Future<void> openInApp(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView, // buka browser default
    )) {
      throw Exception('Tidak bisa membuka $url');
    }
  }
}
