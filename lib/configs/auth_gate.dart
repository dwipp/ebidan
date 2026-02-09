import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/common/utility/remote_config_helper.dart';
import 'package:ebidan/common/utility/user_preferences.dart';
import 'package:ebidan/presentation/screens/auth/login.dart';
import 'package:ebidan/presentation/screens/home.dart';
import 'package:ebidan/presentation/screens/intro/intro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? _hasSeenIntro;

  @override
  void initState() {
    super.initState();
    _requestNotifPermission();
    _checkForceUpdate();
    _loadIntroStatus();
  }

  Future<void> _loadIntroStatus() async {
    final seen = await UserPreferences().getBool(UserPrefs.intro);
    setState(() {
      _hasSeenIntro = seen;
    });
  }

  Future<void> _requestNotifPermission() async {
    final messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // ambil token
      final token = await messaging.getToken();
      print('FCM Token: $token');

      // WAJIB untuk broadcast
      await messaging.subscribeToTopic('all');
    }
  }

  Future<void> _checkForceUpdate() async {
    try {
      final shouldUpdate = await RemoteConfigHelper.shouldForceUpdate();
      if (shouldUpdate && mounted) {
        _showForceUpdateDialog(context);
      }
    } catch (e) {
      print('Error checking force update: $e');
    }
  }

  void _showForceUpdateDialog(BuildContext context) async {
    final message = RemoteConfigHelper.versionMessage;
    final versionUrl = RemoteConfigHelper.versionUrl;
    final url = versionUrl.isNotEmpty
        ? versionUrl
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

        // ❗ PRIORITAS INTRO
        if (_hasSeenIntro == false) {
          return const IntroScreen();
        }

        if (user == null) {
          return const LoginScreen();
        }

        return const HomeScreen();

        // if (user == null) {
        //   return const LoginScreen();
        // } else {
        //   return const HomeScreen();
        // }
      },
    );
  }
}
