// lib/subscription_cubit.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ebidan/common/constants.dart';
import 'package:ebidan/common/utility/remote_config_helper.dart';
import 'package:ebidan/common/utility/subscription_helper.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
// import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

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
  final UserCubit user;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'asia-southeast2',
  );
  late StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;
  List<ProductDetails> _products = [];

  SubscriptionCubit({required this.user}) : super(SubscriptionInitial());

  void _listenToPurchaseUpdates() {
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        for (var purchase in purchaseDetailsList) {
          print('purchase status: ${purchase.status}');
        }
        _handlePurchaseUpdates(purchaseDetailsList);
      },
      onDone: () {
        _purchaseSubscription.cancel();
        emit(SubscriptionPurchaseCancelled());
      },
      onError: (Object error) {
        if (error is IAPError) {
          emit(SubscriptionError('Purchase error: ${error.message}'));
        } else {
          emit(SubscriptionError('An unknown error occurred during purchase.'));
        }
        emit(SubscriptionPurchaseCancelled());
        initStoreInfo(); // Coba inisialisasi ulang
      },
    );
  }

  Future<void> initStoreInfo() async {
    emit(SubscriptionLoading());
    final bool isAvailable = await _inAppPurchase.isAvailable();

    if (!isAvailable) {
      print('erro SubscriptionLoaded');
      emit(SubscriptionLoaded(products: [], isAvailable: false));
      return;
    }

    /*if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      // Opsional: atur delegate jika diperlukan, seperti dalam contoh
      // await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }*/

    final ProductDetailsResponse productDetailResponse = await _inAppPurchase
        .queryProductDetails(
          RemoteConfigHelper.activePromo
              ? Constants.productPromoIds.toSet()
              : Constants.productIds.toSet(),
        );

    if (productDetailResponse.error != null) {
      print('erro SubscriptionError');
      emit(SubscriptionError(productDetailResponse.error!.message));
      return;
    }

    _products = productDetailResponse.productDetails;
    // print(
    //   'satu2: ${_products.map((p) => {'id': p.id, 'lain': p.title}).toList()}',
    // );
    _listenToPurchaseUpdates();

    // 🔹 Jalankan verifikasi otomatis saat app dibuka
    final subs = user.state?.subscription;
    if (subs?.productId != null && subs?.purchaseToken != null) {
      await SubscriptionHelper.verify(
        productId: subs!.productId!,
        purchaseToken: subs.purchaseToken!,
        user: user,
      );
    }

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
          emit(SubscriptionPurchaseCancelled());
          // Load data product lagi
          emit(SubscriptionLoaded(products: _products, isAvailable: true));
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            try {
              // Simpan ke backend menggunakan Cloud Function saveSubscription
              await _saveSubscription(purchaseDetails);
              emit(
                SubscriptionPurchaseSuccess(
                  purchaseDetails: purchaseDetails,
                  products: _products,
                ),
              );
            } catch (e) {
              print('error: $e');
              emit(SubscriptionError('Gagal menyimpan ke server: $e'));
            }
          } else {
            emit(SubscriptionError('Invalid purchase verification.'));
          }

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

  /// 🔹 Simpan subscription ke Firestore lewat saveSubscription.js (Firebase Function)
  Future<void> _saveSubscription(PurchaseDetails purchaseDetails) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User belum login');

    String? purchaseToken;
    String? orderId;
    String platform = Platform.isAndroid ? 'android' : 'ios';

    if (purchaseDetails is GooglePlayPurchaseDetails) {
      final data = jsonDecode(
        purchaseDetails.billingClientPurchase.originalJson,
      );
      purchaseToken = data['purchaseToken'];
      orderId = data['orderId'];
    }

    final callable = _functions.httpsCallable('saveSubscription');

    await callable.call({
      'userId': uid,
      'productId': purchaseDetails.productID,
      'purchaseToken': purchaseToken,
      'orderId': orderId ?? purchaseDetails.purchaseID,
      'platform': platform,
    });

    print('✅ Subscription tersimpan di backend.');

    await SubscriptionHelper.verify(
      productId: purchaseDetails.productID,
      purchaseToken: purchaseToken!,
      user: user,
    );
  }

  // 🔹 Tambahkan fungsi restore tanpa ubah kode lain
  Future<void> restoreSubscription() async {
    try {
      emit(SubscriptionLoading());

      if (Platform.isAndroid) {
        final InAppPurchaseAndroidPlatformAddition androidAddition =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

        final QueryPurchaseDetailsResponse response = await androidAddition
            .queryPastPurchases();

        if (response.error != null) {
          emit(SubscriptionError(response.error!.message));
          emit(SubscriptionLoaded(products: _products, isAvailable: true));
          return;
        }

        if (response.pastPurchases.isEmpty) {
          emit(SubscriptionError("Tidak ada langganan yang ditemukan."));
          emit(SubscriptionLoaded(products: _products, isAvailable: true));
          return;
        }

        for (final purchase in response.pastPurchases) {
          await _handlePurchaseUpdates([purchase]);
        }
      } else if (Platform.isIOS) {
        // Jika nanti ditambahkan dukungan iOS
        emit(SubscriptionError("Restore belum didukung untuk iOS."));
      }
      emit(SubscriptionLoaded(products: _products, isAvailable: true));
    } catch (e) {
      emit(SubscriptionError("Gagal memulihkan langganan: $e"));
      emit(SubscriptionLoaded(products: _products, isAvailable: true));
    }
  }

  // Bersihkan stream saat Cubit dibuang
  @override
  Future<void> close() {
    _purchaseSubscription.cancel();
    return super.close();
  }
}
