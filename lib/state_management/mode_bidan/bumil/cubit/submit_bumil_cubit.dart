import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/selected_bumil_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'submit_bumil_state.dart';

class SubmitBumilCubit extends Cubit<SubmitBumilState> {
  final SelectedBumilCubit selectedBumilCubit;
  SubmitBumilCubit({required this.selectedBumilCubit})
    : super(SubmitBumilState());

  Future<void> submitBumil(Bumil bumil) async {
    emit(state.copyWith(isSubmitting: true, isSuccess: false, error: null));

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: false,
          error: 'User belum login',
        ),
      );
      return;
    }

    if (bumil.nikIbu.isNotEmpty) {
      final registered = await isNikRegistered(
        nik: bumil.nikIbu,
        uid: user.uid,
      );
      if (registered) {
        emit(
          state.copyWith(
            isSubmitting: false,
            isSuccess: false,
            error: 'NIK Ibu sudah terdaftar.',
          ),
        );
        return;
      }
    }

    try {
      final bumilId = bumil.idBumil.isNotEmpty
          ? bumil.idBumil
          : FirebaseFirestore.instance.collection('bumil').doc().id;
      final docRef = FirebaseFirestore.instance
          .collection('bumil')
          .doc(bumilId);

      final Map<String, dynamic> rawBumil = {
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
        "id_bidan": bumil.idBidan.isNotEmpty ? bumil.idBidan : user.uid,
        "birthdate_ibu": bumil.birthdateIbu,
        "birthdate_suami": bumil.birthdateSuami,
        "created_at": bumil.createdAt,
      };
      docRef.set(rawBumil, SetOptions(merge: true));

      final newBumil = Bumil.fromMap(bumilId, rawBumil);
      selectedBumilCubit.selectBumil(newBumil);
      emit(
        state.copyWith(isSubmitting: false, isSuccess: true, bumilId: bumilId),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<bool> isNikRegistered({
    required String nik,
    required String uid,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final snapshot = await firestore
          .collection('bumil')
          .where('id_bidan', isEqualTo: uid)
          .where('nik_ibu', isEqualTo: nik.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void setInitial() => emit(SubmitBumilState());
}
