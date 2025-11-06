import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionHelper {
  /// 🔹 Jalankan setiap kali app dibuka, untuk memastikan status terkini
  static Future<void> verify({
    required String productId,
    required String purchaseToken,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final FirebaseFunctions functions = FirebaseFunctions.instanceFor(
      region: 'asia-southeast2',
    );
    try {
      final callable = functions.httpsCallable('verifySubscription');

      final result = await callable.call({
        'userId': uid,
        'packageName': 'id.ebidan.aos',
        'productId': productId,
        'purchaseToken': purchaseToken,
      });

      final data = result.data;
      if (data == null) return;

      final subscriptionData = {
        'status': data['status'],
        'expiry_date': data['expiry_date'],
        'auto_renew': data['auto_renew'],
        'last_verified': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('bidan').doc(uid).update({
        'subscription': subscriptionData,
      });

      print('✅ Subscription diverifikasi dan disimpan ulang.');
    } catch (e) {
      print('verifySubscription error: $e');
    }
  }
}
