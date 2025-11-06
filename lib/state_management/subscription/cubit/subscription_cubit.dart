// lib/subscription_cubit.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/common/constants.dart';
import 'package:ebidan/data/models/bidan_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

part 'subscription_state.dart';

// Asumsikan Anda memiliki mekanisme untuk menyimpan status langganan saat ini
// Ini harusnya terintegrasi dengan backend Anda untuk verifikasi yang aman.
// Untuk contoh, kita asumsikan tidak ada langganan lama.
GooglePlayPurchaseDetails? _currentOldSubscription() {
  // LOGIC ANDROID: Anda harus mengambil langganan yang aktif saat ini dari server Anda
  // dan mengembalikannya sebagai GooglePlayPurchaseDetails.
  // Jika tidak ada langganan lama, kembalikan null.
  return null;
}

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;
  List<ProductDetails> _products = [];

  SubscriptionCubit() : super(SubscriptionInitial()) {
    initStoreInfo();
  }

  void _listenToPurchaseUpdates() {
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        for (var purchase in purchaseDetailsList) {
          print('purchase status: ${purchase.status}');
        }
        _handlePurchaseUpdates(purchaseDetailsList);
      },
      onDone: () {
        print('_purchaseSubscription.cancel');
        _purchaseSubscription.cancel();
        emit(SubscriptionPurchaseCancelled());
      },
      onError: (Object error) {
        print('purchase error');
        if (error is IAPError) {
          emit(SubscriptionError('Purchase error: ${error.message}'));
        } else {
          emit(SubscriptionError('An unknown error occurred during purchase.'));
        }
        initStoreInfo(); // Coba inisialisasi ulang
      },
    );
  }

  Future<void> initStoreInfo() async {
    emit(SubscriptionLoading());
    final bool isAvailable = await _inAppPurchase.isAvailable();

    if (!isAvailable) {
      print('satu1');
      emit(SubscriptionLoaded(products: [], isAvailable: false));
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      // Opsional: atur delegate jika diperlukan, seperti dalam contoh
      // await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final ProductDetailsResponse productDetailResponse = await _inAppPurchase
        .queryProductDetails(Constants.kProductIds.toSet());

    if (productDetailResponse.error != null) {
      emit(SubscriptionError(productDetailResponse.error!.message));
      return;
    }

    _products = productDetailResponse.productDetails;
    print(
      'satu2: ${_products.map((p) => {'id': p.id, 'lain': p.title}).toList()}',
    );
    _listenToPurchaseUpdates();
    emit(SubscriptionLoaded(products: _products, isAvailable: isAvailable));
  }

  void buySubscription(ProductDetails productDetails) async {
    if (state is! SubscriptionLoaded) return;
    final currentState = state as SubscriptionLoaded;

    emit(SubscriptionPurchasePending(products: currentState.products));

    late PurchaseParam purchaseParam;

    if (Platform.isAndroid) {
      final GooglePlayPurchaseDetails? oldSubscription =
          _currentOldSubscription();

      purchaseParam = GooglePlayPurchaseParam(
        productDetails: productDetails,
        changeSubscriptionParam: (oldSubscription != null)
            ? ChangeSubscriptionParam(
                oldPurchaseDetails: oldSubscription,
                // Gunakan ReplacementMode yang sesuai (e.g., WITH_TIME_PRORATION)
                replacementMode: ReplacementMode.withTimeProration,
              )
            : null,
      );
    } else {
      purchaseParam = PurchaseParam(productDetails: productDetails);
    }

    // Panggil buyNonConsumable untuk langganan
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          // Tampilkan loading overlay
          if (state is SubscriptionLoaded) {
            emit(
              SubscriptionPurchasePending(
                products: (state as SubscriptionLoaded).products,
              ),
            );
          }
          break;

        case PurchaseStatus.canceled:
        case PurchaseStatus.error:
          // final message = (purchaseDetails.error?.code == 'purchase_canceled')
          //     ? 'Purchase canceled by user.'
          //     : purchaseDetails.error?.message ?? 'Unknown purchase error.';

          // // Tampilkan error dulu
          // emit(SubscriptionError(message));
          emit(SubscriptionPurchaseCancelled());

          // Load data product lagi
          emit(SubscriptionLoaded(products: _products, isAvailable: true));
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final bool valid = await _verifyPurchase(purchaseDetails);

          if (valid) {
            // simpan ke firestore bidan.
            // start date
            // expired date
            // product id
            // purchase id
            // type => quarterly, semiannual, annual
            // status = active
            // auto renew
            await updateBidan(purchaseDetails);
            emit(
              SubscriptionPurchaseSuccess(
                purchaseDetails: purchaseDetails,
                products: _products,
              ),
            );
          } else {
            emit(SubscriptionError('Invalid purchase verification.'));
          }

          // Kembalikan ke loaded setelah delay supaya snackbar/feedback bisa muncul
          // await Future.delayed(const Duration(milliseconds: 500));
          emit(SubscriptionLoaded(products: _products, isAvailable: true));
          break;
      }

      // Selesaikan pembelian tertunda
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  // Hanya contoh verifikasi, HARUS dilakukan di server nyata.
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    return Future<bool>.value(true);
  }

  Future<void> updateBidan(PurchaseDetails purchaseDetails) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      emit(SubscriptionError('Pastikan Anda sudah login'));
      return;
    }
    final startDate = DateTime.fromMillisecondsSinceEpoch(
      int.tryParse(purchaseDetails.transactionDate ?? '') ??
          DateTime.now().millisecondsSinceEpoch,
    );

    // Tentukan expiry date berdasarkan product id
    DateTime expiryDate;
    String type;
    switch (purchaseDetails.productID) {
      case 'subscription_quarterly':
        expiryDate = startDate.add(const Duration(days: 90));
        type = 'quarterly';
        break;
      case 'subscription_semiannual':
        expiryDate = startDate.add(const Duration(days: 180));
        type = 'semiannual';
        break;
      case 'subscription_annual':
        expiryDate = startDate.add(const Duration(days: 365));
        type = 'annual';
        break;
      default:
        expiryDate = startDate.add(const Duration(days: 90));
        type = 'quarterly';
    }

    bool autoRenew = false;
    String? purchaseToken;
    String? orderId;

    if (purchaseDetails is GooglePlayPurchaseDetails) {
      final data = jsonDecode(
        purchaseDetails.billingClientPurchase.originalJson,
      );
      autoRenew = data['autoRenewing'] ?? false;
      purchaseToken = data['purchaseToken'];
      orderId = data['orderId'];
    }

    final sub = Subscription(
      productId: purchaseDetails.productID,
      orderId: purchaseDetails.purchaseID ?? orderId ?? '',
      startDate: startDate,
      expiryDate: expiryDate,
      autoRenew: autoRenew,
      purchaseToken: purchaseToken,
      type: type,
      status: 'active',
    );

    await FirebaseFirestore.instance.collection('bidan').doc(uid).update({
      'subscription': sub.toFirestore(),
    });

    emit(
      SubscriptionPurchaseSuccess(
        purchaseDetails: purchaseDetails,
        products: _products,
      ),
    );
  }

  // Bersihkan stream saat Cubit dibuang
  @override
  Future<void> close() {
    _purchaseSubscription.cancel();
    return super.close();
  }
}
