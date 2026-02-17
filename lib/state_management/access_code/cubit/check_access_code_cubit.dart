import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/access_code_model.dart';
import 'package:ebidan/state_management/general/cubit/connectivity_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'check_access_code_state.dart';

class CheckAccessCodeCubit extends Cubit<CheckAccessCodeState> {
  CheckAccessCodeCubit() : super(CheckAccessCodeInitial());

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> checkAccessCode(
    String code, {
    required ConnectivityState connectivity,
  }) async {
    if (connectivity.connected) {
      emit(CheckAccessCodeLoading());
    } else {
      emit(CheckAccessCodeFailure('Tidak ada koneksi internet'));
      return;
    }

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(const CheckAccessCodeFailure('User belum login'));
        return;
      }

      final now = DateTime.now();
      final codeRef = _firestore.collection('access_code').doc(code);

      final codeSnap = await codeRef.get();
      if (!codeSnap.exists) {
        emit(const CheckAccessCodeFailure('Kode akses tidak ditemukan'));
        return;
      }

      final accessCode = AccessCode.fromFirestore(codeSnap.data()!);

      if (accessCode.expiryDate.isBefore(now)) {
        emit(const CheckAccessCodeFailure('Kode akses telah kedaluwarsa'));
        return;
      }

      final redemptionRef = codeRef.collection('redemptions').doc(uid);
      final redemptionSnap = await redemptionRef.get();

      if (redemptionSnap.exists) {
        emit(
          const CheckAccessCodeFailure('Kode ini sudah pernah Anda gunakan'),
        );
        return;
      }

      if (accessCode.redeemedCount >= accessCode.maxRedemptions) {
        emit(const CheckAccessCodeFailure('Kuota penggunaan kode telah habis'));
        return;
      }
      emit(CheckAccessCodeSuccess());
    } catch (e) {
      emit(
        CheckAccessCodeFailure(
          e is Exception
              ? e.toString().replaceAll('Exception: ', '')
              : 'Terjadi kesalahan',
        ),
      );
    }
  }
}
