import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class RemoteConfigHelper {
  static final _remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 12),
      ),
    );
    await _remoteConfig.fetchAndActivate();
  }

  // versioning - force update
  static int get versionMinimum => _remoteConfig.getInt('version_minimum');
  static String get versionMessage =>
      _remoteConfig.getString('version_message');
  static String get versionUrl => _remoteConfig.getString('version_url');

  // promo
  static bool get promoActive => _remoteConfig.getBool('promo_active');

  // mode reviewer
  static String get reviewerEmail => _remoteConfig.getString('reviewer_email');
  static String get reviewerPass => _remoteConfig.getString('reviewer_pass');
  static bool get reviewerActive => _remoteConfig.getBool('reviewer_active');

  static Future<bool> shouldForceUpdate() async {
    final info = await PackageInfo.fromPlatform();
    final currentVersion = int.tryParse(info.buildNumber) ?? 0;
    return currentVersion < versionMinimum;
  }
}
