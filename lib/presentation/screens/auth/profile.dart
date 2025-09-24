import 'package:ebidan/data/models/bidan_model.dart';
import 'package:ebidan/presentation/widgets/logout_handler.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/auth/cubit/profile_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildVersionInfo() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        if (snapshot.hasData) {
          final String version = snapshot.data!.version;
          final String buildNumber = snapshot.data!.buildNumber;
          String versionText = 'versi $version';

          // Tampilkan build number hanya dalam mode debug
          if (kDebugMode) {
            versionText += ' ($buildNumber)';
          }

          return Text(
            versionText,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
          );
        } else {
          // Tampilkan teks sementara saat memuat
          return const Text(
            'Memuat versi...',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.read<ProfileCubit>().getProfile();

    return BlocBuilder<UserCubit, Bidan?>(
      builder: (context, bidan) {
        if (bidan == null) {
          return Scaffold(
            appBar: PageHeader(
              title: 'Profil',
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => LogoutHandler.handleLogout(context),
                ),
              ],
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return _buildProfileScaffold(context, bidan);
      },
    );
  }

  Widget _buildProfileScaffold(BuildContext context, Bidan user) {
    return Scaffold(
      appBar: PageHeader(
        title: 'Profil Saya',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => LogoutHandler.handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 24),
              _buildSubscriptionCard(
                context,
                status: user.premiumStatus,
                user: user,
              ),
              const SizedBox(height: 24),
              _buildUserInfoCard(user),
              const SizedBox(height: 8),
              _buildVersionInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Bidan user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blue.shade100,
          backgroundImage: user.photoUrl != null
              ? NetworkImage(user.photoUrl!) as ImageProvider
              : null,
          child: user.photoUrl == null
              ? const Icon(Icons.person, size: 50, color: Colors.blueGrey)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          user.nama,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user.role,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context, {
    required PremiumStatus status,
    required Bidan user,
  }) {
    String title;
    Color color;
    IconData icon;
    Widget? descriptionWidget;

    void handleAction(BuildContext context) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Akses ke halaman langganan.")),
      );
    }

    final TextStyle actionTextStyle = TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    switch (status.premiumType) {
      case PremiumType.trial:
        final expiry = user.expiryDate;
        title = "Trial Aktif";
        color = Colors.orange.shade100;
        icon = Icons.star;

        if (expiry != null) {
          final now = DateTime.now();
          final daysLeft = expiry.difference(now).inDays;

          if (daysLeft > 7 || daysLeft < 0) {
            descriptionWidget = Text(
              "Berakhir pada: ${DateFormat('dd MMMM yyyy').format(expiry)}",
            );
          } else {
            descriptionWidget = RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: <TextSpan>[
                  TextSpan(text: "Berakhir dalam $daysLeft hari.\n"),
                  TextSpan(
                    text: "Klik untuk langganan.",
                    style: actionTextStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => handleAction(context),
                  ),
                ],
              ),
            );
          }
        } else {
          descriptionWidget = const Text("Berakhir pada: Tidak diketahui");
        }
        break;

      case PremiumType.subscription:
        final expiry = user.expiryDate;
        title = "Langganan Premium Aktif";
        color = Colors.green.shade100;
        icon = Icons.check_circle;

        if (expiry != null) {
          final now = DateTime.now();
          final daysLeft = expiry.difference(now).inDays;

          if (daysLeft > 7 || daysLeft < 0) {
            descriptionWidget = Text(
              "Berakhir pada: ${DateFormat('dd MMMM yyyy').format(expiry)}",
            );
          } else {
            descriptionWidget = RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: <TextSpan>[
                  TextSpan(text: "Berakhir dalam $daysLeft hari.\n"),
                  TextSpan(
                    text: "Klik untuk perpanjang.",
                    style: actionTextStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => handleAction(context),
                  ),
                ],
              ),
            );
          }
        } else {
          descriptionWidget = const Text("Berakhir pada: Tidak diketahui");
        }
        break;

      default:
        title = "Akses Standar";
        color = Colors.red.shade100;
        icon = Icons.cancel;
        descriptionWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Saat ini Anda tidak memiliki akses ke Statistik."),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => handleAction(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Upgrade Sekarang"),
              ),
            ),
          ],
        );
        break;
    }

    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 40,
              color: color == Colors.red.shade100
                  ? Colors.red.shade700
                  : Colors.blue.shade700,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  descriptionWidget,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(Bidan user) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Informasi Saya",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Aksi untuk mengedit profil
                  },
                  tooltip: "Edit Profil",
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            _buildInfoRow(Icons.email, "Email", user.email),
            _buildInfoRow(Icons.badge, "NIP", user.nip),
            _buildInfoRow(Icons.phone, "Nomor HP", user.noHp),
            _buildInfoRow(Icons.local_hospital, "Puskesmas", user.puskesmas),
            _buildInfoRow(Icons.location_on, "Desa", user.desa),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
