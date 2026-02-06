import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/riwayat/cubit/selected_riwayat_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:ebidan/data/models/riwayat_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

part 'submit_riwayat_state.dart';

class SubmitRiwayatCubit extends Cubit<SubmitiwayatState> {
  final SelectedBumilCubit selectedBumilCubit;
  final SelectedRiwayatCubit selectedRiwayatCubit;
  SubmitRiwayatCubit({
    required this.selectedBumilCubit,
    required this.selectedRiwayatCubit,
  }) : super(SubmitRiwayatInitial());

  Future<void> addRiwayat({
    required String bumilId,
    required List<Map<String, dynamic>> riwayatList,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(SubmitRiwayatFailure('User belum login'));
      return;
    }

    var currentBumil = selectedBumilCubit.state;
    if (currentBumil == null) return;

    emit(SubmitRiwayatLoading());

    try {
      final docRef = FirebaseFirestore.instance
          .collection('bumil')
          .doc(bumilId);

      int hidup = 0;
      int mati = 0;
      int abortus = 0;
      int beratRendah = 0;
      int? latestYear;

      List<Riwayat> riwayatListFinal = [];

      for (var item in riwayatList) {
        if (item['tgl_lahir'] != '') {
          final tglLahir = item['tgl_lahir'] as DateTime;
          // if (tglLahir == null) continue;

          if (item['status_bayi'] == 'Hidup') {
            hidup++;
          } else if (item['status_bayi'] == 'Mati') {
            mati++;
          } else if (item['status_bayi'] == 'Abortus') {
            abortus++;
          }

          final beratBayi = int.parse(
            item['berat_bayi'] == '' ? '0' : item['berat_bayi'],
          );
          if (beratBayi > 0 && beratBayi < 2500) beratRendah++;

          riwayatListFinal.add(
            Riwayat(
              id: Uuid().v4(),
              tglLahir: tglLahir,
              beratBayi: beratBayi,
              komplikasi: item['komplikasi'],
              panjangBayi: item['panjang_bayi'],
              penolong: item['penolong'] == 'Lainnya'
                  ? item['penolongLainnya']
                  : item['penolong'],
              statusBayi: item['status_bayi'],
              statusLahir: item['status_lahir'],
              statusTerm: item['status_term'],
              tempat: item['tempat'],
            ),
          );

          if (latestYear == null || tglLahir.year > latestYear) {
            latestYear = tglLahir.year;
          }
        }
      }

      if (riwayatListFinal.isEmpty) {
        emit(AddRiwayatEmpty());
        return;
      }

      docRef.update({
        'riwayat': FieldValue.arrayUnion(
          riwayatListFinal.map((riwayat) => riwayat.toFirestore()).toList(),
        ),
      });

      currentBumil.riwayat = riwayatListFinal;
      selectedBumilCubit.selectBumil(currentBumil);

      emit(
        SubmitRiwayatSuccess(
          latestYear: latestYear,
          jumlahRiwayat: riwayatListFinal.length,
          jumlahPara: hidup + mati,
          jumlahAbortus: abortus,
          jumlahBeratRendah: beratRendah,
          listRiwayat: riwayatListFinal,
        ),
      );
    } catch (e) {
      emit(
        SubmitRiwayatFailure(
          e is Exception
              ? e.toString().replaceAll('Exception: ', '')
              : 'Terjadi kesalahan. Mohon coba kembali.',
        ),
      );
    }
  }

  Future<void> editRiwayat({required Riwayat updatedRiwayat}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(SubmitRiwayatFailure('User belum login'));
      return;
    }
    emit(SubmitRiwayatLoading());

    var currentBumil = selectedBumilCubit.state;
    if (currentBumil == null) return;

    // ambil riwayat lama
    final List<Riwayat> oldRiwayats = currentBumil.riwayat ?? [];

    // update sesuai id
    final List<Riwayat> newRiwayats = oldRiwayats.map((r) {
      if (r.id == updatedRiwayat.id) {
        return updatedRiwayat;
      }
      return r;
    }).toList();

    try {
      // simpan ke Firestore
      FirebaseFirestore.instance
          .collection('bumil')
          .doc(currentBumil.idBumil)
          .update({
            'riwayat': newRiwayats
                .map((riwayat) => riwayat.toFirestore())
                .toList(),
          });

      // update cubit state biar langsung sinkron
      currentBumil.riwayat = newRiwayats;
      selectedBumilCubit.selectBumil(currentBumil);
      selectedRiwayatCubit.selectRiwayat(updatedRiwayat);

      // hitung summary
      int? latestYear = newRiwayats.isNotEmpty
          ? newRiwayats
                .map((e) => e.tglLahir.year)
                .reduce((a, b) => a > b ? a : b)
          : null;

      emit(
        SubmitRiwayatSuccess(
          latestYear: latestYear,
          jumlahRiwayat: currentBumil.statisticRiwayat['gravida']!,
          jumlahPara: currentBumil.statisticRiwayat['para']!,
          jumlahAbortus: currentBumil.statisticRiwayat['abortus']!,
          jumlahBeratRendah: currentBumil.statisticRiwayat['beratRendah']!,
          listRiwayat: newRiwayats,
        ),
      );
    } catch (e) {
      emit(
        SubmitRiwayatFailure(
          e is Exception
              ? e.toString().replaceAll('Exception: ', '')
              : 'Terjadi kesalahan. Mohon coba kembali.',
        ),
      );
    }
  }

  void setInitial() => emit(SubmitRiwayatInitial());
}
