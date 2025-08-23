import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectionUtil {
  /// Mengecek apakah ada koneksi internet
  static Future<bool> hasConnection() async {
    return await InternetConnection().hasInternetAccess;
  }

  /// Mengecek koneksi lalu jalankan [onConnected] atau [onDisconnected]
  static Future<void> checkConnection({
    required Function() onConnected,
    required Function() onDisconnected,
  }) async {
    final isConnected = await hasConnection();
    if (isConnected) {
      onConnected();
    } else {
      onDisconnected();
    }
  }
}
