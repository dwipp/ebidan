import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/common/utility/remote_config_helper.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/state_management/mode_bidan/subscription/cubit/subscription_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  // ================================
  // MARK: - Helpers
  // ================================
  String _getPlanName(String id) {
    if (id.contains('_annual')) {
      return RemoteConfigHelper.promoActive ? 'Tahunan Promo' : 'Tahunan';
    }
    if (id.contains('semiannual')) {
      return RemoteConfigHelper.promoActive ? '6 Bulanan Promo' : '6 Bulanan';
    }
    if (id.contains('quarterly')) {
      return RemoteConfigHelper.promoActive ? '3 Bulanan Promo' : '3 Bulanan';
    }
    if (id.contains('monthly')) return 'Bulanan';
    return 'Premium Access';
  }

  String _getLifespan(String id) {
    if (id.contains('_annual')) return 'tahun';
    if (id.contains('semiannual')) return '6 bulan';
    if (id.contains('quarterly')) return '3 bulan';
    if (id.contains('monthly')) return 'bulan';
    return 'bulan';
  }

  String _getNormalPrice(String id) {
    num base = 50000; // TODO: sebaiknya nanti ambil dari server / config
    if (id.contains('_annual')) base *= 12;
    if (id.contains('semiannual')) base *= 6;
    if (id.contains('quarterly')) base *= 3;
    if (id.contains('monthly')) base *= 1;

    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(base);
  }

  String _getPlanHighlight(String id) {
    if (id.contains('_annual')) {
      return RemoteConfigHelper.promoActive
          ? 'Hemat Besar!\nHarga spesial terbatas\npilihan favorit para bidan.'
          : 'Super Hemat!\nPaling populer di kalangan bidan.';
    }
    if (id.contains('semiannual')) {
      return RemoteConfigHelper.promoActive
          ? 'Nilai terbaik!\nDiskon periode menengah, pas untuk pemakaian rutin.'
          : 'Pilihan cerdas untuk penggunaan jangka menengah.';
    }
    if (id.contains('quarterly')) {
      return RemoteConfigHelper.promoActive
          ? 'Coba lebih lama dengan harga promo!\nFleksibel dan terjangkau.'
          : 'Coba dulu selama 3 bulan sebelum berkomitmen lebih lama.';
    }
    return 'Langganan fleksibel setiap bulan';
  }

  // ================================
  // MARK: - UI
  // ================================
  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PageHeader(title: const Text('Langganan Premium')),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionError) {
            Snackbar.show(
              context,
              message: state.message,
              type: SnackbarType.error,
            );
          } else if (state is SubscriptionPurchaseSuccess) {
            Snackbar.show(
              context,
              message: 'Langganan berhasil diaktifkan!',
              type: SnackbarType.success,
            );
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          final cubit = context.read<SubscriptionCubit>();
          bool isLoading = state is SubscriptionPurchasePending;
          List<ProductDetails> products = [];

          if (state is SubscriptionLoading || state is SubscriptionInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SubscriptionLoaded) {
            products = state.products;
            if (!state.isAvailable) {
              return const Center(
                child: Text('In-App Purchase tidak tersedia.'),
              );
            }
          } else if (state is SubscriptionPurchasePending) {
            products = state.products;
            isLoading = true;
          } else if (state is SubscriptionPurchaseSuccess) {
            products = state.products;
          }

          // Sorting products
          products.sort((a, b) {
            int getOrder(String id) {
              if (id.contains('monthly')) return 1;
              if (id.contains('_annual')) return 2;
              if (id.contains('semiannual')) return 3;
              if (id.contains('quarterly')) return 4;
              return 5;
            }

            return getOrder(a.id).compareTo(getOrder(b.id));
          });

          // ================================
          // MARK: - Build Package Card
          // ================================
          Widget buildCard(ProductDetails product) {
            final bool isBest = product.id.toLowerCase().endsWith('_annual');
            final gradient = isBest ? colors.pinkGradient : colors.blueGradient;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: isBest ? gradient : null,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isBest ? Colors.transparent : Colors.grey.shade300,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBest)
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Paling Populer 💖',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _getPlanName(product.id),
                    style: TextStyle(
                      fontSize: isBest ? 26 : 18,
                      fontWeight: isBest ? FontWeight.bold : FontWeight.w600,
                      color: isBest ? Colors.white : colors.secondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getPlanHighlight(product.id),
                    style: TextStyle(
                      fontSize: 14,
                      color: isBest ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(
                      color: isBest ? Colors.white70 : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ======= BUTTON =======
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => cubit.buySubscription(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.secondaryContainer,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!product.id.contains('monthly') &&
                              !product.id.contains('quarterly')) ...[
                            Text(
                              _getNormalPrice(product.id),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[100],
                                decoration: TextDecoration.lineThrough,
                                decorationThickness: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            product.price,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'per ${_getLifespan(product.id)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // ================================
          // MARK: - Layout
          // ================================
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ======= Header =======
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          RemoteConfigHelper.promoActive
                              ? 'Premium Promo'
                              : 'Tingkatkan ke Premium',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          RemoteConfigHelper.promoActive
                              ? 'Akses lengkap untuk bidan kini lebih terjangkau. Manfaatkan kesempatan spesial ini sebelum berakhir.'
                              : 'Nikmati fitur lengkap seperti statistik, laporan bulanan, dan konten profesional untuk bidan.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.suffixText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ======= Cards =======
                  const SizedBox(height: 4),
                  ...products.map(buildCard),

                  // ======= Restore =======
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () => cubit.restoreSubscription(),
                      child: Text(
                        'Sudah berlangganan? Pulihkan langganan',
                        style: TextStyle(
                          color: colors.secondaryContainer,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  // ======= Info Section =======
                  const SizedBox(height: 36),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'Informasi Billing & Pembatalan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Langganan diperpanjang otomatis melalui Google Play kecuali dibatalkan sebelum periode berikutnya. '
                    'Anda dapat mengelola atau membatalkan langganan kapan saja melalui Play Store > Pembayaran & Langganan.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.suffixText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),

              // ======= Loading Overlay =======
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.25),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Memproses pembelian...'),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
