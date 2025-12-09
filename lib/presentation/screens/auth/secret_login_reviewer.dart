import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/state_management/auth/cubit/login_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Logo aplikasi besar + hidden 10 taps
class SecretLoginReviewer extends StatefulWidget {
  const SecretLoginReviewer();

  @override
  State<SecretLoginReviewer> createState() => _SecretLoginRevieweroState();
}

class _SecretLoginRevieweroState extends State<SecretLoginReviewer> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  void _onLogoTapped() {
    final now = DateTime.now();

    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(seconds: 1)) {
      _tapCount = 0; // reset jika lewat 1 detik
    }

    _tapCount++;
    _lastTapTime = now;

    if (_tapCount >= 10) {
      _tapCount = 0;

      // === ACTION SAAT 10x TAP ===
      context.read<LoginCubit>().signInForReviewer();
      Snackbar.show(context, message: 'Reviewer mode activated. Logging In...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onLogoTapped,
      child: Image.asset(
        'assets/images/logo-ebidan.png',
        width: 250,
        height: 250,
      ),
    );
  }
}
