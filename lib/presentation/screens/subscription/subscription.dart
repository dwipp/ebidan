// lib/subscription_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:ebidan/state_management/subscription/cubit/subscription_cubit.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  // Helper untuk mendapatkan nama plan dari ID produk
  String _getPlanName(String productId) {
    if (productId.contains('semiannual')) return 'Semi Annual Plan';
    if (productId.contains('quarterly')) return 'Quarterly Plan';
    if (productId.contains('annual')) return 'Annual Plan';
    return 'Premium Access';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Subscriptions')),
      body: BlocProvider(
        create: (_) => SubscriptionCubit(),
        child: BlocConsumer<SubscriptionCubit, SubscriptionState>(
          listener: (context, state) {
            if (state is SubscriptionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            } else if (state is SubscriptionPurchaseSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Subscription Successful!')),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<SubscriptionCubit>();

            // Loading dan initial state
            if (state is SubscriptionLoading || state is SubscriptionInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state
            if (state is SubscriptionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Failed to load subscriptions: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: cubit.initStoreInfo,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            // Ambil produk dari state
            List<ProductDetails> products = [];
            bool isLoading = false;

            if (state is SubscriptionLoaded) {
              products = state.products;
              if (!state.isAvailable) {
                return const Center(
                  child: Text('In-App Purchase is not available.'),
                );
              }
            } else if (state is SubscriptionPurchasePending) {
              products = state.products;
              isLoading = true;
            } else if (state is SubscriptionPurchaseSuccess) {
              products = state.products;
            }

            // Build UI produk
            Widget productList = ListView(
              padding: const EdgeInsets.all(16),
              children: products.map((product) {
                return Card(
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: Text(
                      _getPlanName(product.id),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(product.description),
                    trailing: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => cubit.buySubscription(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(product.price),
                    ),
                  ),
                );
              }).toList(),
            );

            // Overlay loading saat purchase pending
            if (isLoading) {
              return Stack(
                children: [
                  productList,
                  const Opacity(
                    opacity: 0.8,
                    child: ModalBarrier(
                      dismissible: false,
                      color: Colors.black12,
                    ),
                  ),
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text(
                          'Processing Purchase...',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return productList;
            }
          },
        ),
      ),
    );
  }
}
