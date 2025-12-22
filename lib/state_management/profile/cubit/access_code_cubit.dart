import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/access_code_model.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:ebidan/state_management/general/cubit/connectivity_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'access_code_state.dart';

class AccessCodeCubit extends Cubit<AccessCodeState> {
  final UserCubit userCubit;
  AccessCodeCubit({required this.userCubit}) : super(AccessCodeInitial());

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> redeemAccessCode(
    String code, {
    required ConnectivityState connectivity,
  }) async {
    if (connectivity.connected) {
      emit(AccessCodeLoading());
    } else {
      emit(AccessCodeFailure('Tidak ada koneksi internet'));
      return;
    }

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(const AccessCodeFailure('User belum login'));
        return;
      }

      final now = DateTime.now();
      final codeRef = _firestore.collection('access_code').doc(code);
      final userRef = _firestore.collection('bidan').doc(uid);

      final codeSnap = await codeRef.get();
      if (!codeSnap.exists) {
        emit(const AccessCodeFailure('Kode akses tidak ditemukan'));
        return;
      }

      final accessCode = AccessCode.fromFirestore(codeSnap.data()!);

      if (accessCode.expiryDate.isBefore(now)) {
        emit(const AccessCodeFailure('Kode akses telah kedaluwarsa'));
        return;
      }

      final redemptionRef = codeRef.collection('redemptions').doc(uid);
      final redemptionSnap = await redemptionRef.get();

      if (redemptionSnap.exists) {
        emit(const AccessCodeFailure('Kode ini sudah pernah Anda gunakan'));
        return;
      }

      final currentPremiumUntil = userCubit.state?.premiumUntil;

      var newPremiumUntil = now.add(
        Duration(days: accessCode.accessDurationDays),
      );

      if (currentPremiumUntil != null && currentPremiumUntil.isAfter(now)) {
        newPremiumUntil = currentPremiumUntil.add(
          Duration(days: accessCode.accessDurationDays),
        );
      }

      await _firestore.runTransaction((tx) async {
        final freshCodeSnap = await tx.get(codeRef);
        final redeemedCount = freshCodeSnap['redeemed_count'] ?? 0;

        if (redeemedCount >= accessCode.maxRedemptions) {
          throw Exception('Kuota penggunaan kode telah habis');
        }

        tx.update(codeRef, {'redeemed_count': redeemedCount + 1});

        tx.set(redemptionRef, {'uid': uid, 'redeemed_at': now});

        tx.update(userRef, {
          'premium_until': newPremiumUntil.millisecondsSinceEpoch,
        });
      });

      final currentUser = userCubit.state;
      if (currentUser != null) {
        userCubit.loggedInUser(
          currentUser.copyWith(premiumUntil: newPremiumUntil),
        );
      }

      emit(
        AccessCodeSuccess(
          accessName: accessCode.accessName,
          desc: accessCode.desc,
        ),
      );
    } catch (e) {
      emit(
        AccessCodeFailure(
          e is Exception
              ? e.toString().replaceAll('Exception: ', '')
              : 'Terjadi kesalahan',
        ),
      );
    }
  }

  void reset() => emit(AccessCodeInitial());
}
