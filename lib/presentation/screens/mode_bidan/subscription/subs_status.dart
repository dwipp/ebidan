import 'package:ebidan/common/utility/extensions.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionStatusPage extends StatelessWidget {
  const SubscriptionStatusPage({super.key});

  Future<void> _openPlaySubscriptionPage() async {
    final url = Uri.parse(
      'https://play.google.com/store/account/subscriptions',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak dapat membuka halaman langganan Google Play');
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscription = context.read<UserCubit>().state?.subscription;

    final expiryDate = subscription?.expiryDate != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(subscription!.expiryDate!)
        : '-';

    final autoRenew = subscription?.autoRenew == true;
    final status = subscription?.status;

    return Scaffold(
      appBar: AppBar(title: const Text('Status Langganan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Billing & Auto Renew',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status Auto Renew'),
                      Text(
                        autoRenew ? 'Active' : 'Non Active',
                        style: TextStyle(
                          color: autoRenew ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status Langganan'),
                      Text(
                        status?.capitalizeFirst() ?? 'Non Active',
                        style: TextStyle(
                          color: status == "active" ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tanggal Berakhir'),
                      Text(
                        expiryDate,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Jika auto renew aktif, langganan akan diperpanjang otomatis pada tanggal berakhir. '
                    'Pastikan saldo Google Play cukup untuk perpanjangan.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _openPlaySubscriptionPage,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Page Langganan Google Play'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Informasi Refund & Pembatalan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• Refund dapat diajukan melalui Google Play Store dalam waktu 48 jam setelah pembelian.\n'
                    '• Untuk membatalkan langganan, buka Google Play > Pembayaran & Langganan > Langganan.\n'
                    '• Pembatalan akan menghentikan perpanjangan otomatis, tetapi kamu masih dapat '
                    'menggunakan fitur Premium hingga masa langganan berakhir.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
