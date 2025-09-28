import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/persalinan_model.dart';
import 'package:ebidan/data/models/riwayat_model.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/kehamilan/cubit/selected_kehamilan_cubit.dart';
import 'package:ebidan/state_management/persalinan/cubit/selected_persalinan_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'submit_persalinan_state.dart';

class SubmitPersalinanCubit extends Cubit<SubmitPersalinanState> {
  final SelectedBumilCubit selectedBumilCubit;
  final SelectedKehamilanCubit selectedKehamilanCubit;
  final SelectedPersalinanCubit selectedPersalinanCubit;
  SubmitPersalinanCubit({
    required this.selectedBumilCubit,
    required this.selectedKehamilanCubit,
    required this.selectedPersalinanCubit,
  }) : super(AddPersalinanInitial());

  Future<void> addPersalinan(
    List<Persalinan> persalinans, {
    required String bumilId,
    required String kehamilanId,
    required String resti,
  }) async {
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

      docRef.update({
        'persalinan': persalinans.map((e) => e.toFirestore()).toList(),
      });

      List<Riwayat> riwayats = [];
      for (var persalinan in persalinans) {
        final riwayat = Riwayat(
          id: persalinan.id,
          tglLahir: persalinan.tglPersalinan ?? DateTime.now(),
          beratBayi: int.tryParse(persalinan.beratLahir ?? '0') ?? 0,
          komplikasi: resti,
          panjangBayi: persalinan.panjangBadan ?? '0',
          penolong: persalinan.penolong ?? '-',
          statusBayi: persalinan.statusBayi ?? '-',
          statusLahir: persalinan.cara ?? '-',
          statusTerm: _getStatusKehamilan(
            persalinan.umurKehamilan ?? '-',
          ),
          tempat: persalinan.tempat ?? '-',
        );
        riwayats.add(riwayat);
      }
      _tambahRiwayatBumil(
        bumilId,
        riwayatList: riwayats,
        persalinanList: persalinans,
      );
      emit(AddPersalinanSuccess());
    } catch (e) {
      emit(AddPersalinanFailure(e.toString()));
    }
  }

  Future<void> editPersalinan({required Persalinan updatedPersalinan}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(AddPersalinanFailure('User belum login'));
      return;
    }
    emit(AddPersalinanLoading());

    var currentKehamilan = selectedKehamilanCubit.state;
    if (currentKehamilan == null) return;

    // ambil riwayat lama
    final List<Persalinan> oldPersalinans = currentKehamilan.persalinan ?? [];

    // update sesuai id
    final List<Persalinan> newPersalinans = oldPersalinans.map((r) {
      if (r.id == updatedPersalinan.id) {
        return updatedPersalinan;
      }
      return r;
    }).toList();

    try {
      // simpan ke Firestore
      await FirebaseFirestore.instance
          .collection('kehamilan')
          .doc(currentKehamilan.id)
          .update({
            'persalinan': newPersalinans
                .map((persalinan) => persalinan.toFirestore())
                .toList(),
          });

      // update cubit state biar langsung sinkron
      currentKehamilan.persalinan = newPersalinans;
      selectedKehamilanCubit.selectKehamilan(currentKehamilan);
      selectedPersalinanCubit.selectPersalinan(updatedPersalinan);

      // PERLU UPDATE RIWAYAT JUGA
      // ID RIWAYAT DAN ID PERSALINAN ADALAH SAMA
      var currentBumil = selectedBumilCubit.state;
      if (currentBumil == null) return;

      final List<Riwayat> newRiwayats = currentBumil.riwayat!.map((r) {
        if (r.id == updatedPersalinan.id) {
          // bikin object riwayat baru
          final updatedRiwayat = Riwayat(
            id: updatedPersalinan.id,
            tglLahir: updatedPersalinan.tglPersalinan ?? DateTime.now(),
            beratBayi: int.tryParse(updatedPersalinan.beratLahir ?? '0') ?? 0,
            komplikasi: currentKehamilan.resti!.join(", "),
            panjangBayi: updatedPersalinan.panjangBadan ?? '0',
            penolong: updatedPersalinan.penolong ?? '-',
            statusBayi: updatedPersalinan.statusBayi ?? '-',
            statusLahir: updatedPersalinan.cara ?? '-',
            statusTerm: _getStatusKehamilan(
              updatedPersalinan.umurKehamilan ?? "-",
            ),
            tempat: updatedPersalinan.tempat ?? '-',
          );
          return updatedRiwayat;
        }
        return r;
      }).toList();

      _updateRiwayatBumil(
        currentBumil.idBumil,
        riwayatList: newRiwayats,
        persalinanList: newPersalinans,
      );

      // update cubit state biar langsung sinkron
      currentBumil.riwayat = newRiwayats;
      selectedBumilCubit.selectBumil(currentBumil);

      emit(AddPersalinanSuccess());
    } catch (e) {
      emit(AddPersalinanFailure(e.toString()));
    }
  }

  void setInitial() => emit(AddPersalinanInitial());

  void _tambahRiwayatBumil(
    String bumilId, {
    required List<Riwayat> riwayatList,
    required List<Persalinan> persalinanList,
  }) {
    final docRef = FirebaseFirestore.instance.collection('bumil').doc(bumilId);

    docRef.update({
      'riwayat': FieldValue.arrayUnion(
        riwayatList.map((e) => e.toFirestore()).toList(),
      ),
      'latest_kehamilan_persalinan': true,
      'latest_kehamilan.persalinan': persalinanList
          .map((e) => e.toFirestore())
          .toList(),
      'is_hamil': false,
    });
  }

  void _updateRiwayatBumil(
    String bumilId, {
    required List<Riwayat> riwayatList,
    required List<Persalinan> persalinanList,
  }) {
    final docRef = FirebaseFirestore.instance.collection('bumil').doc(bumilId);

    docRef.update({
      'riwayat': riwayatList.map((e) => e.toFirestore()).toList(),
      'latest_kehamilan_persalinan': true,
      'latest_kehamilan.persalinan': persalinanList
          .map((persalinan) => persalinan.toFirestore())
          .toList(),
      'is_hamil': false,
    });
  }

  String _getStatusKehamilan(String input) {
    // Parsing string "X minggu Y hari"
    final regex = RegExp(r'(\d+)\s*minggu(?:\s*(\d+)\s*hari)?');
    final match = regex.firstMatch(input.toLowerCase());

    if (match == null) return "-";

    final minggu = int.parse(match.group(1)!);
    final hari = match.group(2) != null ? int.parse(match.group(2)!) : 0;

    // Konversi ke total hari
    final totalHari = (minggu * 7) + hari;

    if (totalHari < 259) {
      return "Preterm";
    } else if (totalHari >= 259 && totalHari <= 293) {
      return "Aterm";
    } else if (totalHari >= 294) {
      return "Postterm";
    } else {
      return "-";
    }
  }

}
