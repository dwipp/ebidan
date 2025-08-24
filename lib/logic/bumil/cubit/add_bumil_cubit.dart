import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/hive/bumil_hive.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/logic/utility/connection_util.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

part 'add_bumil_state.dart';

class AddBumilCubit extends Cubit<AddBumilState> {
  final Box<BumilHive> addedBumilBox;
  AddBumilCubit({required this.addedBumilBox}) : super(AddBumilState());

  Future<void> submitBumil(Bumil bumil) async {
    emit(state.copyWith(isSubmitting: true, error: null));

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(state.copyWith(isSubmitting: false, error: 'User belum login'));
      return;
    }

    await ConnectionUtil.checkConnection(
      onConnected: () async {
        // Jika online, simpan langsung ke Firestore
        try {
          final docRef = await FirebaseFirestore.instance
              .collection('bumil')
              .add({
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
          emit(state.copyWith(isSubmitting: false, error: e.toString()));
        }
      },
      onDisconnected: () async {
        // Jika offline, simpan lokal menggunakan Hive
        await addedBumilBox.add(
          BumilHive(
            namaIbu: bumil.namaIbu,
            namaSuami: bumil.namaSuami,
            alamat: bumil.alamat,
            noHp: bumil.noHp,
            agamaIbu: bumil.agamaIbu,
            agamaSuami: bumil.agamaSuami,
            bloodIbu: bumil.bloodIbu,
            bloodSuami: bumil.bloodSuami,
            jobIbu: bumil.jobIbu,
            jobSuami: bumil.jobSuami,
            nikIbu: bumil.nikIbu,
            nikSuami: bumil.nikSuami,
            kkIbu: bumil.kkIbu,
            kkSuami: bumil.kkSuami,
            pendidikanIbu: bumil.pendidikanIbu,
            pendidikanSuami: bumil.pendidikanSuami,
            birthdateIbu: bumil.birthdateIbu!,
            birthdateSuami: bumil.birthdateSuami!,
            idBidan: user.uid,
            createdAt: DateTime.now(),
          ),
        );

        emit(
          state.copyWith(
            isSubmitting: false,
            isSuccess: true,
            error: 'Offline: Data tersimpan sementara',
          ),
        );
      },
    );
  }
}
