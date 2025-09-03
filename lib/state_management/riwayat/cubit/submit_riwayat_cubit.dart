import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:ebidan/data/models/riwayat_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'submit_riwayat_state.dart';

class SubmitRiwayatCubit extends Cubit<SubmitiwayatState> {
  SubmitRiwayatCubit() : super(SubmitRiwayatInitial());

  Future<void> addRiwayat({
    required String bumilId,
    required List<Map<String, dynamic>> riwayatList,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(SubmitRiwayatFailure('User belum login'));
      return;
    }
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
        if (item['tahun'] != '') {
          final tahun = int.tryParse(item['tahun']);
          if (tahun == null) continue;

          if (item['status_bayi'] == 'Hidup') {
            hidup++;
          } else if (item['status_bayi'] == 'Mati') {
            mati++;
          } else if (item['status_bayi'] == 'Abortus') {
            abortus++;
          }

          final beratBayi = int.parse(item['berat_bayi']);
          if (beratBayi < 2500) beratRendah++;

          riwayatListFinal.add(
            Riwayat(
              tahun: tahun,
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

          if (latestYear == null || tahun > latestYear) {
            latestYear = tahun;
          }
        }
      }

      if (riwayatListFinal.isEmpty) {
        emit(AddRiwayatEmpty());
        return;
      }

      docRef.update({
        'riwayat': FieldValue.arrayUnion(
          riwayatListFinal.map((riwayat) => riwayat.toMap()).toList(),
        ),
      });

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
      emit(SubmitRiwayatFailure(e.toString()));
    }
  }

  Future<void> editRiwayat({
    required String bumilId,
    required int index,
    required Map<String, dynamic> updatedData,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(SubmitRiwayatFailure('User belum login'));
      return;
    }
    emit(SubmitRiwayatLoading());

    try {
      final docRef = FirebaseFirestore.instance
          .collection('bumil')
          .doc(bumilId);

      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        emit(SubmitRiwayatFailure('Data bumil tidak ditemukan'));
        return;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final List<dynamic> riwayat = List.from(data['riwayat'] ?? []);

      if (index < 0 || index >= riwayat.length) {
        emit(SubmitRiwayatFailure('Index tidak valid'));
        return;
      }

      // Replace data di index tertentu
      riwayat[index] = {...riwayat[index], ...updatedData};

      await docRef.update({'riwayat': riwayat});

      // Hitung ulang summary
      int hidup = 0;
      int mati = 0;
      int abortus = 0;
      int beratRendah = 0;
      int? latestYear;

      List<Riwayat> riwayatListFinal = [];

      for (var item in riwayat) {
        final tahun = int.tryParse(item['tahun'].toString());
        if (tahun == null) continue;

        if (item['status_bayi'] == 'Hidup') {
          hidup++;
        } else if (item['status_bayi'] == 'Mati') {
          mati++;
        } else if (item['status_bayi'] == 'Abortus') {
          abortus++;
        }

        final beratBayi = int.tryParse(item['berat_bayi'].toString()) ?? 0;
        if (beratBayi < 2500) beratRendah++;

        riwayatListFinal.add(Riwayat.fromMap(Map<String, dynamic>.from(item)));

        if (latestYear == null || tahun > latestYear) {
          latestYear = tahun;
        }
      }

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
      emit(SubmitRiwayatFailure(e.toString()));
    }
  }

  void setInitial() => emit(SubmitRiwayatInitial());
}
