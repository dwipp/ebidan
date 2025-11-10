import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:ebidan/state_management/subscription/cubit/subscription_cubit.dart';
import 'package:intl/intl.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  String _getPlanName(String productId) {
    if (productId.contains('_annual')) return 'Annual Plan';
    if (productId.contains('semiannual')) return 'Semi Annual Plan';
    if (productId.contains('quarterly')) return 'Quarterly Plan';
    if (productId.contains('monthly')) return 'Monthly Plan';
    return 'Premium Access';
  }

  String _getLifespan(String productId) {
    if (productId.contains('_annual')) return 'tahun';
    if (productId.contains('semiannual')) return '6 bulan';
    if (productId.contains('quarterly')) return '3 bulan';
    if (productId.contains('monthly')) return 'bulan';
    return 'bulan';
  }

  String _getNormalPrice(String productId) {
    var basicPrice = 50000; // cari cara agar tidak hardcode
    if (productId.contains('_annual')) basicPrice *= 12;
    if (productId.contains('semiannual')) basicPrice *= 6;
    if (productId.contains('quarterly')) basicPrice *= 3;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return formatter.format(basicPrice);
  }

  String _getPlanHighlight(String productId) {
    if (productId.contains('_annual')) {
      return 'Super Hemat \nPaling populer di kalangan bidan!';
    }
    if (productId.contains('semiannual')) {
      return 'Hemat dibanding Quarterly Plan';
    }
    if (productId.contains('quarterly')) return 'Coba dulu untuk 3 bulan';
    return 'Langganan fleksibel setiap bulan';
  }

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
              message: 'Error: ${state.message}',
              type: SnackbarType.error,
            );
          } else if (state is SubscriptionPurchaseSuccess) {
            Snackbar.show(
              context,
              message: 'Langganan berhasil diaktifkan!',
              type: SnackbarType.success,
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<SubscriptionCubit>();
          List<ProductDetails> products = [];
          bool isLoading = false;

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

          Widget buildCard(ProductDetails product) {
            final bool isBest = product.id.toLowerCase().endsWith('_annual');

            final gradient = isBest ? colors.pinkGradient : colors.blueGradient;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: isBest ? gradient : null,
                // color: isBest ? null : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isBest ? Colors.transparent : Colors.grey.shade300,
                  width: isBest ? 0 : 1,
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
                        shadowColor: context.themeColors.onSurface,
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
                                color: Colors.white.withOpacity(0.7),
                                decoration: TextDecoration.lineThrough,
                                decorationThickness: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            product.price,
                            style: TextStyle(
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

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tingkatkan ke Premium',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Nikmati akses penuh fitur statistik, laporan bulanan, dan konten profesional untuk bidan.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.suffixText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...products.map(buildCard),
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
                  const SizedBox(height: 40),
                ],
              ),
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
