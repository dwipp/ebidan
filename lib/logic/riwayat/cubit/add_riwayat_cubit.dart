import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:ebidan/data/models/riwayat_model.dart';

part 'add_riwayat_state.dart';

class AddRiwayatCubit extends Cubit<AddRiwayatState> {
  AddRiwayatCubit() : super(AddRiwayatInitial());

  Future<void> addRiwayat({
    required String bumilId,
    required List<Map<String, dynamic>> riwayatList,
  }) async {
    emit(AddRiwayatLoading());

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
        AddRiwayatSuccess(
          latestYear: latestYear,
          jumlahRiwayat: riwayatListFinal.length,
          jumlahPara: hidup + mati,
          jumlahAbortus: abortus,
          jumlahBeratRendah: beratRendah,
          listRiwayat: riwayatListFinal,
        ),
      );
    } catch (e) {
      emit(AddRiwayatFailure(e.toString()));
    }
  }

  void setInitial() => emit(AddRiwayatInitial());
}
