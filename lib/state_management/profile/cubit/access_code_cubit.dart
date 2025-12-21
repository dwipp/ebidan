import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/access_code_model.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'access_code_state.dart';

class AccessCodeCubit extends Cubit<AccessCodeState> {
  final UserCubit userCubit;
  AccessCodeCubit({required this.userCubit}) : super(AccessCodeInitial());

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> redeemAccessCode(String code) async {
    emit(AccessCodeLoading());
    try {
      final now = DateTime.now();
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(const AccessCodeFailure('User belum login'));
        return;
      }

      final doc = await _firestore.collection('access_code').doc(code).get();

      // cek kode ada atau tidak
      if (!doc.exists) {
        emit(const AccessCodeFailure('Kode akses tidak ditemukan'));
        return;
      }

      final data = doc.data()!;
      final accessCode = AccessCode.fromFirestore(data);

      // cek apakah kode ini masih valid. expired atau gak
      if (accessCode.expiryDate.isBefore(now)) {
        emit(const AccessCodeFailure('Kode akses telah kedaluwarsa'));
        return;
      }

      // cek apakah kode akses ini sudah mencapai limit
      if (accessCode.maxRedemptions <= accessCode.redeemedCount) {
        emit(const AccessCodeFailure('Kuota penggunaan kode telah habis'));
        return;
      }

      final redemptionDoc = await _firestore
          .collection('access_code')
          .doc(code)
          .collection('redemptions')
          .doc(uid)
          .get();

      // cek apakah user ini sudah pernah pakai kode ini atau belum
      if (redemptionDoc.exists) {
        emit(const AccessCodeFailure('Kode ini sudah pernah Anda gunakan'));
        return;
      }

      // tambah durasi trial user di premium_until berdasarkan access_duration_days
      final premiumUntil = userCubit.state?.premiumUntil;
      var newDuration = now.add(Duration(days: accessCode.accessDurationDays));
      if (premiumUntil != null && premiumUntil.isAfter(now)) {
        // trial masih aktif
        newDuration = premiumUntil.add(
          Duration(days: accessCode.accessDurationDays),
        );
      }
      await _firestore.collection('bidan').doc(uid).update({
        'premium_until': newDuration,
      });
      var newBidan = userCubit.state;
      if (newBidan != null) {
        newBidan.premiumUntil = newDuration;
        userCubit.loggedInUser(newBidan);
      }
      // final newDoc = await _firestore.collection('bidan').doc(uid).get();
      // final newData = newDoc.data()!;
      // final avatar = _auth.currentUser?.photoURL;
      // final refreshedBidan = Bidan.fromFirestore(newData, avatar: avatar);
      // userCubit.loggedInUser(refreshedBidan);

      // tambah record redemptions di access_code
      await _firestore
          .collection('access_code')
          .doc(code)
          .collection('redemptions')
          .doc(uid)
          .set({'redeemed_at': now, 'uid': uid});

      // redeemed_count++
      await _firestore.collection('access_code').doc(code).update({
        'redeemed_count': accessCode.redeemedCount + 1,
      });

      // reload profile page
      // tampilkan popup kalo access code sukses
      emit(
        AccessCodeSuccess(
          accessName: accessCode.accessName,
          desc: accessCode.desc,
        ),
      );
    } catch (e) {
      emit(AccessCodeFailure(e.toString()));
    }
  }
}
