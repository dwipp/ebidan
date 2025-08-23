import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'add_bumil_state.dart';

class AddBumilCubit extends Cubit<AddBumilState> {
  AddBumilCubit() : super(AddBumilState());

  Future<void> submitBumil(Bumil bumil) async {
    emit(state.copyWith(isSubmitting: true, error: null));

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User belum login');

      final docRef = await FirebaseFirestore.instance.collection('bumil').add({
        "nama_ibu": bumil.namaIbu,
        "nama_suami": bumil.namaSuami,
        "alamat": bumil.alamat,
        "no_hp": bumil.noHp,
        "agama_ibu": bumil.agamaIbu,
        "agama_suami": bumil.agamaSuami,
        "blood_ibu": bumil.bloodIbu,
        "blood_suami": bumil.bloodSuami,
        "job_ibu": bumil.jobIbu,
        "job_suami": bumil.jobSuami,
        "nik_ibu": bumil.nikIbu,
        "nik_suami": bumil.nikSuami,
        "kk_ibu": bumil.kkIbu,
        "kk_suami": bumil.kkSuami,
        "pendidikan_ibu": bumil.pendidikanIbu,
        "pendidikan_suami": bumil.pendidikanSuami,
        "id_bidan": user.uid,
        "birthdate_ibu": bumil.birthdateIbu,
        "birthdate_suami": bumil.birthdateSuami,
        "created_at": DateTime.now(),
      });

      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          bumilId: docRef.id,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isSubmitting: false, error: e.toString(), bumilId: null),
      );
    }
  }
}
