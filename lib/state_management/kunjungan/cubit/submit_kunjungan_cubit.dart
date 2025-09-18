import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/kunjungan/cubit/selected_kunjungan_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'submit_kunjungan_state.dart';

class SubmitKunjunganCubit extends Cubit<SubmitKunjunganState> {
  final SelectedKunjunganCubit selectedKunjunganCubit;
  final SelectedBumilCubit selectedBumilCubit;
  SubmitKunjunganCubit({
    required this.selectedKunjunganCubit,
    required this.selectedBumilCubit,
  }) : super(AddKunjunganInitial());

  Future<void> submitKunjungan(
    Kunjungan data, {
    required bool firstTime,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(AddKunjunganFailure('User belum login'));
      return;
    }

    emit(AddKunjunganLoading());

    try {
      final id = data.id.isNotEmpty
          ? data.id
          : FirebaseFirestore.instance.collection('kunjungan').doc().id;
      final docRef = FirebaseFirestore.instance.collection('kunjungan').doc(id);
      final Map<String, dynamic> kunjungan = {
        'bb': data.bb,
        'created_at': data.createdAt,
        'keluhan': data.keluhan,
        'lila': data.lila,
        'lp': data.lp,
        'planning': data.planning,
        'status': data.status,
        'td': data.td,
        'tfu': data.tfu,
        'uk': data.uk,
        'terapi': data.terapi,
        'id_bidan': user.uid,
        'id_kehamilan': data.idKehamilan,
        'id_bumil': data.idBumil,
      };


      if (firstTime) {
        kunjungan['tgl_periksa_usg'] = selectedBumilCubit.state?.latestKehamilan?.tglPeriksaUsg;//tglPeriksaUsg;
        kunjungan['kontrol_dokter'] = selectedBumilCubit.state?.latestKehamilan?.kontrolDokter;
        
        var bumil = selectedBumilCubit.state;
        final ageRisk = bumil!.age < 20 || bumil.age > 35;
        final gravidaRisk = bumil.statisticRiwayat['gravida']! >= 4;
        final jarakRisk = (bumil.statisticRiwayat['gravida']! > 0) &&
            (DateTime.now().year - (bumil.latestRiwayat?.tahun ?? DateTime.now().year) < 2);

        kunjungan['k1_4t'] = ageRisk || gravidaRisk || jarakRisk;
      }

      await docRef.set(kunjungan, SetOptions(merge: true));
      final snapshot = await docRef.get(const GetOptions(source: Source.cache));
      final newKunjungan = Kunjungan.fromFirestore(snapshot.data()!, id: id);
      selectedKunjunganCubit.selectKunjungan(newKunjungan);

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
              .update({
                'resti': FieldValue.arrayUnion(resti),
                'kunjungan': true,
              });
        }
        final docRefBumil = FirebaseFirestore.instance
            .collection('bumil')
            .doc(data.idBumil);
        await docRefBumil.update({
          'latest_kehamilan_kunjungan': true,
          'latest_kehamilan.kunjungan': true,
        });
        final snapshotBumil = await docRefBumil.get(
          const GetOptions(source: Source.cache),
        );
        final newBumil = Bumil.fromMap(data.idBumil!, snapshotBumil.data()!);
        selectedBumilCubit.selectBumil(newBumil);
      }
      emit(AddKunjunganSuccess());
    } catch (e) {
      emit(AddKunjunganFailure(e.toString()));
    }
  }

  void setInitial() => emit(AddKunjunganInitial());
}
