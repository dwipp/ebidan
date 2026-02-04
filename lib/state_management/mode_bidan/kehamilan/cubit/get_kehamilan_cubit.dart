import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/kehamilan_model.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'get_kehamilan_state.dart';

class GetKehamilanCubit extends Cubit<GetKehamilanState> {
  GetKehamilanCubit() : super(GetKehamilanInitial());

  Future<void> getKehamilan({required String bumilId}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(GetKehamilanFailure('User belum login'));
      return;
    }
    emit(GetKehamilanLoading());

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('kehamilan')
          .where('id_bumil', isEqualTo: bumilId)
          .where('id_bidan', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .get();

      final List<Kehamilan> list = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();

        list.add(Kehamilan.fromFirestore(doc.id, data));
      }
      emit(GetKehamilanSuccess(kehamilans: list));
    } catch (e) {
      emit(
        GetKehamilanFailure(
          e is Exception
              ? e.toString().replaceAll('Exception: ', '')
              : 'Terjadi kesalahan. Mohon coba kembali.',
        ),
      );
    }
  }

  void setInitial() => emit(GetKehamilanInitial());
}
