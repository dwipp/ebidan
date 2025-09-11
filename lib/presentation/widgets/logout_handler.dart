import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/state_management/auth/cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogoutHandler {
  /// Menangani proses logout dengan pengecekan pending writes.
  static Future<void> handleLogout(BuildContext context) async {
    final hasPending = await Utils.hasAnyPendingWrites();

    if (hasPending) {
      final shouldLogout = await _showPendingDialog(context);

      if (shouldLogout == true) {
        await _logout(context);
      }
    } else {
      await _logout(context);
    }
  }

  /// Tampilkan dialog jika masih ada data offline yang belum tersinkron
  static Future<bool?> _showPendingDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Data Belum Tersinkron"),
        content: const Text(
          "Ada data yang masih offline dan belum tersinkron ke server. "
          "Besar kemungkinan data akan hilang jika anda logout.\n\n"
          "Apakah Anda yakin ingin tetap logout?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Ya"),
          ),
        ],
      ),
    );
  }

  /// Proses logout
  static Future<void> _logout(BuildContext context) async {
    context.read<LoginCubit>().signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
