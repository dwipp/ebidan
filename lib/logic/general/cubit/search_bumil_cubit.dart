import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/bumil_model.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'search_bumil_state.dart';

class SearchBumilCubit extends Cubit<SearchBumilState> {
  SearchBumilCubit() : super(SearchBumilState.initial());

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
      print('jumlah data bumil mentab: ${snapshot.docs.length}');
      final list = snapshot.docs
          .map((doc) => Bumil.fromMap(doc.id, doc.data()))
          .toList();
      print('jumlah data bumil: ${list.length}');
      emit(state.copyWith(bumilList: list, filteredList: list));
    } catch (e) {
      emit(SearchBumilState.initial());
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
