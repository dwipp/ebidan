import 'package:ebidan/data/models/bidan_model.dart';
import 'package:ebidan/presentation/widgets/logout_handler.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().state;

    if (user == null) {
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
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: PageHeader(
        title: 'Profil Saya',
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => LogoutHandler.handleLogout(context),
            ),
          ],),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 24),
              _buildSubscriptionCard(user.premiumStatus, user: user),
              const SizedBox(height: 24),
              _buildUserInfoCard(user),
              const SizedBox(height: 8),
              Text('versi 1.0.0', 
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,),),
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
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.role,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Inside the ProfileScreen class

  Widget _buildSubscriptionCard(PremiumStatus status, {required Bidan user}) {
    String title;
    String description;
    Color color;
    IconData icon;
    Widget? actionButton; // A new widget for the action button

    switch (status.premiumType) {
      case PremiumType.trial:
        final expiry = user.expiryDate;
        if (expiry == null) {
          title = "Trial Aktif";
          description =
              "Berakhir pada: ${DateFormat('dd MMMM yyyy').format(status.expiryDate!)}";
          color = Colors.orange.shade100;
          icon = Icons.star;
          break;
        }
        final now = DateTime.now();
        final daysLeft = expiry.difference(now).inDays;
        
        if (daysLeft > 7 || daysLeft < 0) {
          title = "Trial Aktif";
          description =
              "Berakhir pada: ${DateFormat('dd MMMM yyyy').format(status.expiryDate!)}";
          color = Colors.orange.shade100;
          icon = Icons.star;
          break;
        }
        title = "Trial Aktif";
        description =
            "Berakhir dalam $daysLeft hari.\nklik untuk langganan";
        color = Colors.orange.shade100;
        icon = Icons.star;
        break;
      case PremiumType.subscription:
        final expiry = user.expiryDate;
        if (expiry == null) {
          title = "Langganan Premium Aktif";
          description =
              "Berakhir pada: ${DateFormat('dd MMMM yyyy').format(status.expiryDate!)}";
          color = Colors.green.shade100;
          icon = Icons.check_circle;
          break;
        }
        final now = DateTime.now();
        final daysLeft = expiry.difference(now).inDays;
        if (daysLeft > 7 || daysLeft < 0) {
          title = "Langganan Premium Aktif";
          description =
              "Berakhir pada: ${DateFormat('dd MMMM yyyy').format(status.expiryDate!)}";
          color = Colors.green.shade100;
          icon = Icons.check_circle;
          break;
        }
        title = "Langganan Premium Aktif";
        description =
            "Berakhir dalam $daysLeft hari.\nklik untuk perpanjang";
        color = Colors.green.shade100;
        icon = Icons.star;
        break;
      default:
        title = "Akses Standar";
        description = "Saat ini Anda tidak memiliki akses ke Statistik.";
        color = Colors.red.shade100;
        icon = Icons.cancel;
        // Add the subscribe button here
        actionButton = ElevatedButton(
          onPressed: () {
            // Action to navigate to the subscription page
            // Example: Navigator.of(context).pushNamed(AppRouter.subscribe);
            // For now, let's show a simple message
            // You need to pass context to this method if you want to use ScaffoldMessenger
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text("Akses ke halaman langganan.")),
            // );
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, 
            backgroundColor: Colors.blue.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text("Upgrade Sekarang"),
        );
        break;
    }

    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 40, color: color == Colors.red.shade100 ? Colors.red.shade700 : Colors.blue.shade700),
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
                      Text(description),
                    ],
                  ),
                ),
              ],
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, // Make the button full width
                child: actionButton,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(Bidan user) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Tambahkan tombol edit profile di sini
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Aksi untuk mengedit profil
                  // Contoh: Navigator.of(context).pushNamed(AppRouter.editProfile);
                  
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
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