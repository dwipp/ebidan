import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/persalinan_model.dart';
import 'package:ebidan/data/models/riwayat_model.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'add_persalinan_state.dart';

class AddPersalinanCubit extends Cubit<AddPersalinanState> {
  AddPersalinanCubit() : super(AddPersalinanInitial());

  Future<void> addPersalinan(
    List<Persalinan> persalinans, {
    required String bumilId,
    required String kehamilanId,
    required String resti,
  }) async {
    print('nyangkut');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(AddPersalinanFailure('User belum login'));
      return;
    }

    emit(AddPersalinanLoading());
    try {
      final docRef = FirebaseFirestore.instance
          .collection('kehamilan')
          .doc(kehamilanId);

      docRef.update({'persalinan': persalinans.map((e) => e.toMap()).toList()});

      List<Riwayat> riwayats = [];
      for (var persalinan in persalinans) {
        final riwayat = Riwayat(
          tahun: persalinan.tglPersalinan?.year ?? 0,
          beratBayi: int.tryParse(persalinan.beratLahir ?? '0') ?? 0,
          komplikasi: resti,
          panjangBayi: persalinan.panjangBadan ?? '0',
          penolong: persalinan.penolong ?? '-',
          statusBayi: persalinan.statusBayi ?? '-',
          statusLahir: persalinan.cara ?? '-',
          statusTerm: _getStatusKehamilan(
            int.tryParse(persalinan.umurKehamilan ?? '-1') ?? -1,
          ),
          tempat: persalinan.tempat ?? '-',
        );
        riwayats.add(riwayat);
      }
      _tambahRiwayatBumil(bumilId, riwayats);
      emit(AddPersalinanSuccess());
    } catch (e) {
      emit(AddPersalinanFailure(e.toString()));
    }
  }

  void setInitial() => emit(AddPersalinanInitial());

  void _tambahRiwayatBumil(String bumilId, List<Riwayat> riwayats) {
    final docRef = FirebaseFirestore.instance.collection('bumil').doc(bumilId);

    docRef.set({
      'riwayat': FieldValue.arrayUnion(riwayats.map((e) => e.toMap()).toList()),
      'latest_kehamilan_persalinan': true,
    }, SetOptions(merge: true));
  }

  String _getStatusKehamilan(int usiaMinggu) {
    if (usiaMinggu < 37) {
      return "Preterm";
    } else if (usiaMinggu >= 37 && usiaMinggu <= 41) {
      return "Aterm";
    } else if (usiaMinggu >= 42) {
      return "Postterm";
    } else {
      return "-";
    }
  }
}
