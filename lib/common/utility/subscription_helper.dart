import 'package:cloud_functions/cloud_functions.dart';
import 'package:ebidan/data/models/bidan_model.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionHelper {
  /// 🔹 Jalankan setiap kali app dibuka, untuk memastikan status terkini
  static Future<void> verify({
    required String productId,
    required String purchaseToken,
    required UserCubit user,
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

      if (data['success'] == true) {
        print('✅ Subscription diverifikasi dan disimpan ulang.');
      } else {
        print('❌ Verifikasi Subscription gagal');
      }

      final subs = data['subscription'];
      // update UserCubit disini
      var bidan = user.state;
      if (bidan != null) {
        final newSubs = Subscription(
          autoRenew: subs['auto_renew'] ?? false,
          expiryDate: DateTime.fromMillisecondsSinceEpoch(subs['expiry_date']),
          status: subs['status'],
          lastVerified: DateTime.fromMillisecondsSinceEpoch(
            subs['last_verified'],
          ),
          orderId: subs['order_id'],
          productId: subs['product_id'],
          purchaseToken: subs['purchase_token'],
          startDate: DateTime.fromMillisecondsSinceEpoch(subs['start_date']),
          platform: subs['platform'],
          updatedAt: DateTime.fromMillisecondsSinceEpoch(subs['updated_at']),
        );
        final newBidan = Bidan(
          photoUrl: bidan.photoUrl,
          active: bidan.active,
          createdAt: bidan.createdAt,
          desa: bidan.desa,
          email: bidan.email,
          idPuskesmas: bidan.idPuskesmas,
          nama: bidan.nama,
          nip: bidan.nip,
          noHp: bidan.noHp,
          puskesmas: bidan.puskesmas,
          role: bidan.role,
          subscription: newSubs,
          trial: bidan.trial,
          bidanIds: bidan.bidanIds,
        );
        user.loggedInUser(newBidan);
      }
    } catch (e) {
      print('verifySubscription error: $e');
    }
  }
}
