import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'bumil_state.dart';

class BumilCubit extends Cubit<BumilState> {
  BumilCubit() : super(BumilState.initial());

  Future<void> fetchData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    final firestore = FirebaseFirestore.instance;
    emit(
      BumilLoading(
        bumilList: state.bumilList,
        filteredList: state.filteredList,
      ),
    );
    print("uid: $userId}");
    try {
      final snapshot = await firestore
          .collection('bumil')
          .where('id_bidan', isEqualTo: userId)
          .orderBy('nama_ibu')
          .get();

      final list = snapshot.docs
          .map((doc) => Bumil.fromMap(doc.id, doc.data()))
          .toList();

      emit(state.copyWith(bumilList: list, filteredList: list));
    } catch (e) {
      emit(BumilState.initial());
    }
  }

  void search(String query) {
    emit(
      BumilLoading(
        bumilList: state.bumilList,
        filteredList: state.filteredList,
      ),
    );
    final lower = query.toLowerCase();
    final filtered = state.bumilList
        .where((b) => b.namaIbu.toLowerCase().contains(lower))
        .toList();
    // print('search: $filtered');
    emit(state.copyWith(filteredList: filtered));
  }
}
