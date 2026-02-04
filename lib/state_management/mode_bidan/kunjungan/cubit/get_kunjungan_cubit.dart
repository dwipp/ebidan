import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'get_kunjungan_state.dart';

class GetKunjunganCubit extends Cubit<GetKunjunganState> {
  GetKunjunganCubit() : super(GetKunjunganInitial());

  Future<void> getKunjungan({required String kehamilanId}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(GetKunjunganFailure('User belum login'));
      return;
    }
    emit(GetKunjunganLoading());

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('kunjungan')
          .where('id_bidan', isEqualTo: user.uid)
          .where('id_kehamilan', isEqualTo: kehamilanId)
          .orderBy('created_at', descending: true)
          .get();

      final kunjunganList = snapshot.docs
          .map((e) => Kunjungan.fromFirestore(e.data(), id: e.id))
          .toList();
      emit(GetKunjunganSuccess(kunjungans: kunjunganList));
    } catch (e) {
      emit(
        GetKunjunganFailure(
          e is Exception
              ? e.toString().replaceAll('Exception: ', '')
              : 'Terjadi kesalahan. Mohon coba kembali.',
        ),
      );
    }
  }

  void setInitial() => emit(GetKunjunganInitial());
}
