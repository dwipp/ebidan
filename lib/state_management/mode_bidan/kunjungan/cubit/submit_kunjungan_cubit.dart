import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/data/models/kehamilan_model.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/kehamilan/cubit/selected_kehamilan_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/kunjungan/cubit/selected_kunjungan_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'submit_kunjungan_state.dart';

class SubmitKunjunganCubit extends Cubit<SubmitKunjunganState> {
  final SelectedKunjunganCubit selectedKunjunganCubit;
  final SelectedBumilCubit selectedBumilCubit;
  final SelectedKehamilanCubit selectedKehamilanCubit;
  SubmitKunjunganCubit({
    required this.selectedKunjunganCubit,
    required this.selectedBumilCubit,
    required this.selectedKehamilanCubit,
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
        'tb': data.tb,
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
        'next_sf': data.nextSf,
        'periksa_usg': data.periksaUsg,
      };

      var kehamilan = selectedKehamilanCubit.state;
      if (firstTime) {
        kunjungan['tgl_periksa_usg'] = selectedBumilCubit
            .state
            ?.latestKehamilan
            ?.tglPeriksaUsg; //tglPeriksaUsg;
        kunjungan['kontrol_dokter'] =
            selectedBumilCubit.state?.latestKehamilan?.kontrolDokter;

        var bumil = selectedBumilCubit.state;
        kehamilan ??= bumil?.latestKehamilan;
        final ageRisk = bumil!.age < 20 || bumil.age > 35;
        final gravidaRisk = bumil.statisticRiwayat['gravida']! >= 4;
        final jarakRisk =
            (bumil.statisticRiwayat['gravida']! > 0) &&
            _cekJarakKehamilan(bumil.latestRiwayat?.tglLahir);

        kunjungan['k1_4t'] = ageRisk || gravidaRisk || jarakRisk;
      }

      await docRef.set(kunjungan, SetOptions(merge: true));
      final snapshot = await docRef.get(const GetOptions(source: Source.cache));
      final newKunjungan = Kunjungan.fromFirestore(snapshot.data()!, id: id);
      selectedKunjunganCubit.selectKunjungan(newKunjungan);

      final Map<String, dynamic> updatedKehamilan = {
        'sf_count': (kehamilan?.sfCount ?? 0) + (data.nextSf ?? 0),
        'kunjungan': true,
      };
      final Map<String, dynamic> bumilKunjungan = {};
      List<String> resti = [];
      if (firstTime == true) {
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
          if (num.parse(data.lila!) < 23.5) {
            resti.add('Kekurangan Energi Kronis (lila: ${data.lila} cm)');
          }
        }
        if (resti.isNotEmpty) {
          updatedKehamilan['resti'] = FieldValue.arrayUnion(resti);
        }
      }
      bumilKunjungan['latest_kehamilan_kunjungan'] = true;
      bumilKunjungan['latest_kehamilan.kunjungan'] = true;

      final docRefKehamilan = FirebaseFirestore.instance
          .collection('kehamilan')
          .doc(data.idKehamilan);
      await docRefKehamilan.update(updatedKehamilan);
      final snapshotKehamilan = await docRefKehamilan.get(
        const GetOptions(source: Source.cache),
      );
      final newKehamilan = Kehamilan.fromFirestore(
        data.idKehamilan!,
        snapshotKehamilan.data()!,
      );
      selectedKehamilanCubit.selectKehamilan(newKehamilan);

      bumilKunjungan['latest_kunjungan_id'] = id;
      bumilKunjungan['latest_kunjungan'] = kunjungan;
      bumilKunjungan['latest_kehamilan'] = newKehamilan.toFirestore();
      final docRefBumil = FirebaseFirestore.instance
          .collection('bumil')
          .doc(data.idBumil);
      await docRefBumil.update(bumilKunjungan);
      final snapshotBumil = await docRefBumil.get(
        const GetOptions(source: Source.cache),
      );
      final newBumil = Bumil.fromMap(data.idBumil!, snapshotBumil.data()!);
      selectedBumilCubit.selectBumil(newBumil);

      emit(AddKunjunganSuccess());
    } catch (e) {
      emit(AddKunjunganFailure(e.toString()));
    }
  }

  void setInitial() => emit(AddKunjunganInitial());

  bool _cekJarakKehamilan(DateTime? tglLahirAnak) {
    if (tglLahirAnak == null) return false;

    final sekarang = DateTime.now();

    // Hitung selisih total bulan
    int selisihBulan =
        (sekarang.year - tglLahirAnak.year) * 12 +
        (sekarang.month - tglLahirAnak.month);

    // Koreksi jika tanggal hari sekarang < tanggal lahir anak (belum genap sebulan)
    if (sekarang.day < tglLahirAnak.day) {
      selisihBulan -= 1;
    }

    // risiko jika selisih < 24 bulan
    return selisihBulan < 24;
  }
}
