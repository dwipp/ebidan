import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/persalinan_model.dart';
import 'package:ebidan/data/models/riwayat_model.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/kehamilan/cubit/selected_kehamilan_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/persalinan/cubit/selected_persalinan_cubit.dart';
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
      final batch = FirebaseFirestore.instance.batch();

      final docRefKehamilan = FirebaseFirestore.instance
          .collection('kehamilan')
          .doc(kehamilanId);

      // 1. Tambah ke batch untuk update kehamilan
      batch.update(docRefKehamilan, {
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
          statusTerm: _getStatusKehamilan(persalinan.umurKehamilan ?? '-'),
          tempat: persalinan.tempat ?? '-',
        );
        riwayats.add(riwayat);
      }

      // 2. Tambah ke batch untuk update bumil
      final docRefBumil = FirebaseFirestore.instance
          .collection('bumil')
          .doc(bumilId);
      batch.update(docRefBumil, {
        'riwayat': FieldValue.arrayUnion(
          riwayats.map((e) => e.toFirestore()).toList(),
        ),
        'latest_kehamilan_persalinan': true,
        'latest_kehamilan.persalinan': persalinans
            .map((e) => e.toFirestore())
            .toList(),
        'is_hamil': false,
      });

      // 3. Eksekusi Batch
      batch.commit();

      // lokal
      // update persalinan di dalam doc kehamilan
      var currentKehamilan = selectedKehamilanCubit.state;
      if (currentKehamilan != null) {
        currentKehamilan.persalinan = persalinans;
        selectedKehamilanCubit.selectKehamilan(currentKehamilan);
      }

      // update riwayat di dalam doc bumil
      var currentBumil = selectedBumilCubit.state;
      if (currentBumil != null) {
        currentBumil.riwayat = riwayats;
        selectedBumilCubit.selectBumil(currentBumil);
      }

      emit(AddPersalinanSuccess());
    } catch (e) {
      emit(
        AddPersalinanFailure(
          e is Exception
              ? e.toString().replaceAll('Exception: ', '')
              : 'Terjadi kesalahan. Mohon coba kembali.',
        ),
      );
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

    final List<Persalinan> oldPersalinans = currentKehamilan.persalinan ?? [];

    final List<Persalinan> newPersalinans = oldPersalinans.map((r) {
      if (r.id == updatedPersalinan.id) {
        return updatedPersalinan;
      }
      return r;
    }).toList();

    try {
      final batch = FirebaseFirestore.instance.batch();

      final docRefKehamilan = FirebaseFirestore.instance
          .collection('kehamilan')
          .doc(currentKehamilan.id);

      // 1. Tambah update kehamilan ke batch
      batch.update(docRefKehamilan, {
        'persalinan': newPersalinans
            .map((persalinan) => persalinan.toFirestore())
            .toList(),
      });

      var currentBumil = selectedBumilCubit.state;
      if (currentBumil == null) return;

      final List<Riwayat> newRiwayats = currentBumil.riwayat!.map((r) {
        if (r.id == updatedPersalinan.id) {
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

      // 2. Tambah update bumil ke batch
      final docRefBumil = FirebaseFirestore.instance
          .collection('bumil')
          .doc(currentBumil.idBumil);

      batch.update(docRefBumil, {
        'riwayat': newRiwayats.map((e) => e.toFirestore()).toList(),
        'latest_kehamilan_persalinan': true,
        'latest_kehamilan.persalinan': newPersalinans
            .map((persalinan) => persalinan.toFirestore())
            .toList(),
        'is_hamil': false,
      });

      // 3. Eksekusi batch
      batch.commit();

      // update cubit state biar langsung sinkron
      currentKehamilan.persalinan = newPersalinans;
      selectedKehamilanCubit.selectKehamilan(currentKehamilan);
      selectedPersalinanCubit.selectPersalinan(updatedPersalinan);

      currentBumil.riwayat = newRiwayats;
      selectedBumilCubit.selectBumil(currentBumil);

      emit(AddPersalinanSuccess());
    } catch (e) {
      emit(
        AddPersalinanFailure(
          e is Exception
              ? e.toString().replaceAll('Exception: ', '')
              : 'Terjadi kesalahan. Mohon coba kembali.',
        ),
      );
    }
  }

  void setInitial() => emit(AddPersalinanInitial());

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
