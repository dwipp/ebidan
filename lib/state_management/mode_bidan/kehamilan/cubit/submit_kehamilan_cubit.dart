import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/kehamilan_model.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/kehamilan/cubit/selected_kehamilan_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'submit_kehamilan_state.dart';

class SubmitKehamilanCubit extends Cubit<SubmitKehamilanState> {
  final SelectedKehamilanCubit selectedKehamilanCubit;
  final SelectedBumilCubit selectedBumilCubit;
  SubmitKehamilanCubit({
    required this.selectedKehamilanCubit,
    required this.selectedBumilCubit,
  }) : super(AddKehamilanInitial());

  Future<void> submitKehamilan(Kehamilan data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(AddKehamilanFailure('User belum login'));
      return;
    }

    emit(AddKehamilanLoading());
    // print('data.id: ${data.id}');
    try {
      final batch = FirebaseFirestore.instance.batch();

      final id =
          data.id ??
          FirebaseFirestore.instance.collection('kehamilan').doc().id;
      final docRef = FirebaseFirestore.instance.collection('kehamilan').doc(id);
      final docRefBumil = FirebaseFirestore.instance
          .collection('bumil')
          .doc(data.idBumil);

      final Map<String, dynamic> kehamilan = {
        "tb": data.tb,
        "hemoglobin": data.hemoglobin,
        "bpjs": data.bpjs,
        "no_kohort_ibu": data.noKohortIbu,
        "no_reka_medis": data.noRekaMedis,
        "gpa": data.gpa,
        "kontrasepsi_sebelum_hamil": data.kontrasepsiSebelumHamil,
        "riwayat_alergi": data.riwayatAlergi,
        "riwayat_penyakit": data.riwayatPenyakit,
        "status_resti": data.statusResti,
        "status_tt": data.statusTt,
        "hasil_lab": data.hasilLab,
        "hpht": data.hpht,
        "htp": data.htp,
        "tgl_periksa_usg": data.tglPeriksaUsg,
        'kontrol_dokter': data.kontrolDokter,
        "id_bidan": user.uid,
        "created_at": data.createdAt,
        "id_bumil": data.idBumil,
        "resti": data.resti,
        'usia': data.usia,
      };

      // 1. Tambahkan ke batch
      batch.set(docRef, kehamilan, SetOptions(merge: true));

      // 2. Update status Bumil di batch yang sama
      final updateBumilData = {
        'is_hamil': true,
        'latest_kehamilan_id': id,
        'latest_kehamilan_hpht': data.hpht,
        'latest_kehamilan_resti': data.resti,
        'latest_kehamilan': kehamilan,
        'latest_kehamilan_persalinan': false,
        'latest_kehamilan_kunjungan': false,
      };
      batch.update(docRefBumil, updateBumilData);

      // 3. Commit batch (Ini akan tersimpan di local cache dulu jika offline)
      batch.commit();

      // Update State UI
      final newKehamilan = Kehamilan.fromFirestore(id, kehamilan);
      selectedKehamilanCubit.selectKehamilan(newKehamilan);

      var currentBumil = selectedBumilCubit.state;
      if (currentBumil != null) {
        currentBumil.isHamil = true;
        currentBumil.latestKehamilanId = id;
        currentBumil.latestKehamilanHpht = data.hpht;
        currentBumil.latestKehamilanResti = data.resti;
        currentBumil.latestKehamilan = newKehamilan;
        currentBumil.latestKehamilanPersalinan = false;
        currentBumil.latestKehamilanKunjungan = false;
        selectedBumilCubit.selectBumil(currentBumil);
      }

      emit(AddKehamilanSuccess(idKehamilan: id, firstTime: true));
    } catch (e) {
      emit(AddKehamilanFailure(e.toString()));
    }
  }

  void setInitial() => emit(AddKehamilanInitial());
}
