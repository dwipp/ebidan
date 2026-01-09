import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/selected_bumil_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';

part 'check_bumil_state.dart';

class CheckBumilCubit extends Cubit<CheckBumilState> {
  final SelectedBumilCubit selectedBumilCubit;
  CheckBumilCubit({required this.selectedBumilCubit})
    : super(CheckBumilInitial());

  Future<void> checkNIK(String nik) async {
    emit(CheckBumilLoading());

    final userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    final firestore = FirebaseFirestore.instance;

    try {
      final snapshot = await firestore
          .collection('bumil')
          .where('id_bidan', isEqualTo: userId)
          .where('nik_ibu', isEqualTo: nik.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final bumil = Bumil.fromMap(doc.id, doc.data());
        selectedBumilCubit.selectBumil(bumil);
        emit(CheckBumilFound(nama: bumil.namaIbu));
      } else {
        emit(CheckBumilNotFound());
      }
    } catch (e) {
      emit(CheckBumilError(message: e.toString()));
    }
  }

  void reset() {
    emit(CheckBumilInitial());
  }
}
