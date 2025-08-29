import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/kehamilan_model.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'add_kehamilan_state.dart';

class AddKehamilanCubit extends Cubit<AddKehamilanState> {
  AddKehamilanCubit() : super(AddKehamilanInitial());

  Future<void> addKehamilan(Kehamilan data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(AddKehamilanFailure('User belum login'));
      return;
    }

    emit(AddKehamilanLoading());

    try {
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
        "id_bidan": user.uid,
        "created_at": data.createdAt,
        "id_bumil": data.idBumil,
        "resti": data.resti,
        'kunjungan': false,
      };
      final id = FirebaseFirestore.instance.collection('kehamilan').doc().id;
      FirebaseFirestore.instance.collection('kehamilan').doc(id).set(kehamilan);

      FirebaseFirestore.instance.collection('bumil').doc(data.idBumil).update({
        'latest_kehamilan_id': id,
        'latest_kehamilan_hpht': data.hpht,
        'latest_kehamilan_resti': data.resti,
        'latest_kehamilan_persalinan': false,
        'latest_kehamilan_kunjungan': false,
        'latest_kehamilan': kehamilan,
      });

      emit(AddKehamilanSuccess(idKehamilan: id, firstTime: true));
    } catch (e) {
      emit(AddKehamilanFailure(e.toString()));
    }
  }

  void setInitial() => emit(AddKehamilanInitial());
}
