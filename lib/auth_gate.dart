import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/presentation/screens/auth/login.dart';
import 'package:ebidan/presentation/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkForceUpdate();
  }

  Future<void> _checkForceUpdate() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 12),
        ),
      );
      try {
        await remoteConfig.fetchAndActivate();
      } catch (e) {
        debugPrint('Remote Config fetch failed: $e');
        return;
      }

      final forceVersion = remoteConfig.getInt('minimum_version_code');
      final info = await PackageInfo.fromPlatform();
      final currentVersion = int.tryParse(info.buildNumber) ?? 0;

      final bool shouldUpdate = currentVersion < forceVersion;

      if (shouldUpdate && mounted) {
        _showForceUpdateDialog(context);
      }
    } catch (e) {
      print('Error checking force update: $e');
    }
  }

  void _showForceUpdateDialog(BuildContext context) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    final message = remoteConfig.getString('update_message');
    final updateUrl = remoteConfig.getString('update_url');
    final url = updateUrl.isNotEmpty
        ? updateUrl
        : 'https://play.google.com/store/apps/details?id=id.ebidan.aos';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Pembaruan Diperlukan'),
          content: Text(
            message.isNotEmpty
                ? message
                : 'Versi terbaru aplikasi tersedia. Harap lakukan pembaruan.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                } catch (_) {}
              },
              child: const Text('Perbarui Sekarang'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: context.themeColors.tertiary,
              ),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
