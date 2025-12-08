// lib/subscription_state.dart

part of 'subscription_cubit.dart';

class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

// Saat data produk sedang dimuat
class SubscriptionLoading extends SubscriptionState {}

// Saat produk berhasil dimuat
class SubscriptionLoaded extends SubscriptionState {
  final List<ProductDetails> products;
  final bool isAvailable;

  SubscriptionLoaded({required this.products, required this.isAvailable});
}

// Saat terjadi error dalam pemuatan atau pembelian
class SubscriptionError extends SubscriptionState {
  final String message;

  SubscriptionError(this.message);
}

class SubscriptionPurchaseCancelled extends SubscriptionState {}

// Saat pembelian sedang diproses (menampilkan loading overlay)
class SubscriptionPurchasePending extends SubscriptionState {
  final List<ProductDetails> products;

  SubscriptionPurchasePending({required this.products});
}

// Saat pembelian berhasil (untuk ditampilkan/diproses)
class SubscriptionPurchaseSuccess extends SubscriptionState {
  final PurchaseDetails purchaseDetails;
  final List<ProductDetails> products;

  SubscriptionPurchaseSuccess({
    required this.purchaseDetails,
    required this.products,
  });
}
