import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'add_kunjungan_state.dart';

class AddKunjunganCubit extends Cubit<AddKunjunganState> {
  AddKunjunganCubit() : super(AddKunjunganInitial());

  Future<void> addKunjungan(Kunjungan data, {required bool firstTime}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(AddKunjunganFailure('User belum login'));
      return;
    }

    emit(AddKunjunganLoading());

    try {
      final id = FirebaseFirestore.instance.collection('kunjungan').doc().id;
      FirebaseFirestore.instance.collection('kunjungan').doc(id).set({
        'bb': data.bb,
        'created_at': data.createdAt,
        'keluhan': data.keluhan,
        'lila': data.lila,
        'lp': data.lp,
        'planning': data.planning,
        'status': data.status,
        'td': data.td,
        'tfu': data.tfu,
        'uk': data.uk!.replaceAll(RegExp(r'[^0-9]'), ''),
        'idBidan': user.uid,
        'idKehamilan': data.idKehamilan,
        'idBumil': data.idBumil,
      });

      if (firstTime == true) {
        List<String> resti = [];
        if (data.td != null && data.td!.contains('/')) {
          List<String> parts = data.td!.split("/");
          if (parts.length == 2) {
            int sistolik = int.parse(parts[0]);
            int diastolik = int.parse(parts[1]);

            if (sistolik >= 140 || diastolik >= 90) {
              resti.add('Hipertensi dalam kehamilan ${data.td} mmHg');
            }
          }
        }
        if (data.lila != null) {
          if (int.parse(data.lila!) < 23.5) {
            resti.add('Kekurangan Energi Kronis (lila: ${data.lila} cm)');
          }
        }
        if (resti.isNotEmpty) {
          FirebaseFirestore.instance
              .collection('kehamilan')
              .doc(data.idKehamilan)
              .update({'resti': FieldValue.arrayUnion(resti)});
        }
        FirebaseFirestore.instance.collection('bumil').doc(data.idBumil).update(
          {'latest_kehamilan_kunjungan': true},
        );
      }
      emit(AddKunjunganSuccess());
    } catch (e) {
      emit(AddKunjunganFailure(e.toString()));
    }
  }

  void setInitial() => emit(AddKunjunganInitial());
}
