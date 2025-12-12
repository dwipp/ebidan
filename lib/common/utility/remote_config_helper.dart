import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class RemoteConfigHelper {
  static final _remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    final hasConnection = await InternetConnection().hasInternetAccess;
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 12),
      ),
    );
    if (hasConnection) {
      await _remoteConfig.fetchAndActivate();
    } else {
      await _remoteConfig.activate();
    }
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
