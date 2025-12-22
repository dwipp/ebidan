import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/data/models/access_code_model.dart';
import 'package:ebidan/data/models/bidan_model.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/browser_launcher.dart';
import 'package:ebidan/presentation/widgets/logout_handler.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/general/cubit/connectivity_cubit.dart';
import 'package:ebidan/state_management/profile/cubit/access_code_cubit.dart';
import 'package:ebidan/state_management/profile/cubit/profile_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _getKategori(Bidan user) {
    if (user.role.toLowerCase() == 'koordinator') {
      return user.role;
    } else {
      return user.kategoriBidan ?? user.role;
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<ProfileCubit>().getProfile();

    return BlocBuilder<UserCubit, Bidan?>(
      builder: (context, bidan) {
        if (bidan == null) {
          return Scaffold(
            appBar: PageHeader(
              title: Text('Profil'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => LogoutHandler.handleLogout(context),
                ),
              ],
            ),
            body: Center(
              child: CircularProgressIndicator(
                color: context.themeColors.tertiary,
              ),
            ),
          );
        }

        return _buildProfileScaffold(context, bidan);
      },
    );
  }

  Widget _buildProfileScaffold(BuildContext context, Bidan user) {
    return Scaffold(
      appBar: PageHeader(
        title: Text('Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => LogoutHandler.handleLogout(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: "complaintFab",
        backgroundColor: context.themeColors.complaint,
        onPressed: () {
          BrowserLauncher.openInApp("https://forms.gle/2SR34kx1xjMgA3G27");
        },
        child: const Icon(Icons.feedback, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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
              if (user.premiumSource != PremiumType.subscription.name) ...[
                const SizedBox(height: 16),
                _buildAccessCodeTrigger(context, user),
              ],
              const SizedBox(height: 16),
              _buildUserInfoCard(context, user),
              const SizedBox(height: 8),
              _buildVersionInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Bidan user) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.blue.shade100,
            backgroundImage: user.photoUrl != null
                ? NetworkImage(user.photoUrl!)
                : null,
            child: user.photoUrl == null
                ? const Icon(Icons.person, size: 28, color: Colors.blueGrey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getKategori(user),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
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

    final textTheme = Theme.of(context).textTheme;

    final TextStyle actionTextStyle = TextStyle(
      color: context.themeColors.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    Widget buildInfoSection() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Divider(
            height: 16,
            thickness: 0.5,
            color: context.themeColors.outline.withOpacity(0.3),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRouter.subsStatus),
            child: Text(
              "Lihat Detail Billing & Auto Renew",
              style: actionTextStyle,
            ),
          ),
        ],
      );
    }

    switch (status.premiumType) {
      case PremiumType.trial:
        final expiry = user.expiryDate;
        title = "Akses Gratis";
        color = context.themeColors.trialBg;
        icon = Icons.star;

        if (expiry != null) {
          final now = DateTime.now();
          final daysLeft = expiry.difference(now).inDays;

          descriptionWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                daysLeft >= 0
                    ? daysLeft == 0
                          ? "Berakhir hari ini"
                          : "Berakhir dalam $daysLeft hari (${DateFormat('dd MMMM yyyy').format(expiry)})"
                    : "Berakhir pada: ${DateFormat('dd MMMM yyyy').format(expiry)}",
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRouter.subs),
                child: Text(
                  "Klik untuk langganan penuh",
                  style: actionTextStyle,
                ),
              ),
            ],
          );
        } else {
          descriptionWidget = const Text("Berakhir pada: Tidak diketahui");
        }
        break;

      case PremiumType.subscription:
        final expiry = user.expiryDate;
        title = "Langganan Premium Aktif";
        color = context.themeColors.premiumBg;
        icon = Icons.verified;

        descriptionWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (expiry != null) ...[
              () {
                final now = DateTime.now();
                final daysLeft = expiry.difference(now).inDays;
                String expiryText;

                if (daysLeft > 0) {
                  expiryText =
                      "Berakhir dalam $daysLeft hari (${DateFormat('dd MMMM yyyy').format(expiry)})";
                } else if (daysLeft == 0) {
                  expiryText = "Berakhir hari ini";
                } else {
                  expiryText =
                      "Berakhir pada: ${DateFormat('dd MMMM yyyy').format(expiry)}";
                }

                return Text(expiryText, style: textTheme.bodyMedium);
              }(),
            ] else
              const Text("Berakhir pada: Tidak diketahui"),
            const SizedBox(height: 4),
            buildInfoSection(),
          ],
        );
        break;

      default:
        title = "Akses Standar";
        color = context.themeColors.nonPremiumBg;
        icon = Icons.lock_outline;
        descriptionWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Saat ini Anda tidak memiliki akses ke Statistik."),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.subs);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: context.themeColors.onPrimary,
                  backgroundColor: context.themeColors.primary,
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
              color: color == context.themeColors.nonPremiumBg
                  ? context.themeColors.error
                  : context.themeColors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
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

  Widget _buildAccessCodeTrigger(BuildContext context, Bidan user) {
    final bool isEligible =
        user.premiumStatus.premiumType != PremiumType.subscription;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 1,
      child: ListTile(
        leading: Icon(Icons.vpn_key, color: context.themeColors.primary),
        title: const Text(
          "Punya Kode Akses?",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isEligible
              ? "Masukkan kode untuk menambah Akses Gratis"
              : "Tidak tersedia untuk langganan aktif",
        ),
        trailing: const Icon(Icons.chevron_right),
        enabled: isEligible,
        onTap: isEligible
            ? () => _showAccessCodeBottomSheet(context, user)
            : null,
      ),
    );
  }

  void _showAccessCodeBottomSheet(BuildContext parentContext, Bidan user) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    parentContext.read<AccessCodeCubit>().reset();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: BlocConsumer<AccessCodeCubit, AccessCodeState>(
              listener: (context, state) {
                if (state is AccessCodeSuccess) {
                  Navigator.pop(context);

                  showDialog(
                    context: parentContext,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: const Text("Berhasil"),
                      content: Text("${state.accessName}\n${state.desc}"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(parentContext).pop();
                            parentContext.read<ProfileCubit>().getProfile();
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is AccessCodeLoading;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      "Masukkan Kode Akses",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Kode akan menambahkan durasi Akses Gratis Anda",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: controller,
                      autofocus: true,
                      textCapitalization: TextCapitalization.characters,
                      enabled: !isLoading,
                      validator: (value) {
                        final code = value?.trim() ?? '';

                        if (code.isEmpty) {
                          return "Kode tidak boleh kosong";
                        }

                        if (user.premiumSource ==
                            PremiumType.subscription.name) {
                          return "Tidak berlaku untuk pengguna berlangganan.";
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "XXXXXX",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    if (state is AccessCodeFailure)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 12),
                        child: Text(
                          state.message,
                          style: TextStyle(
                            color: context.themeColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.read<AccessCodeCubit>().reset();
                                final isValid =
                                    formKey.currentState?.validate() ?? false;
                                if (!isValid) return;

                                context
                                    .read<AccessCodeCubit>()
                                    .redeemAccessCode(
                                      controller.text.trim(),
                                      connectivity: context
                                          .read<ConnectivityCubit>()
                                          .state,
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.themeColors.primary,
                          foregroundColor: context.themeColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Gunakan Kode"),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfoCard(BuildContext context, Bidan user) {
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
                    Navigator.of(context).pushNamed(AppRouter.editProfile);
                  },
                  tooltip: "Edit Profil",
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            _buildInfoRow(Icons.email, "Email", user.email),
            _buildInfoRow(Icons.phone, "Nomor HP", user.noHp),
            if (user.kategoriBidan?.toLowerCase() == 'bidan desa' ||
                user.role.toLowerCase() == 'koordinator') ...[
              _buildInfoRow(Icons.badge, "NIP", user.nip ?? '-'),
              _buildInfoRow(
                Icons.local_hospital,
                "Puskesmas",
                user.puskesmas ?? '-',
              ),
              if (user.role.toLowerCase() == 'bidan') ...[
                _buildInfoRow(Icons.location_on, "Desa", user.desa ?? '-'),
              ],
            ] else ...[
              _buildInfoRow(
                Icons.house_sharp,
                "Nama Praktik",
                user.namaPraktik ?? '-',
              ),
              _buildInfoRow(
                Icons.near_me,
                "Alamat Praktik",
                user.alamatPraktik ?? '-',
              ),
            ],
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
}
