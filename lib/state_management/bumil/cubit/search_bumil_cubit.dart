import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/state_management/general/cubit/connectivity_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'dart:convert';
import 'package:ebidan/data/models/bumil_model.dart';

part 'search_bumil_state.dart';

class SearchBumilCubit extends HydratedCubit<SearchBumilState> {
  SearchBumilCubit() : super(SearchBumilState.initial());

  Future<void> fetchData(ConnectivityState connectivity) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    final firestore = FirebaseFirestore.instance;

    if (connectivity.connected) {
      emit(
        BumilLoading(
          bumilList: state.bumilList,
          filteredList: state.filteredList,
        ),
      );
    } else {
      emit(
        state.copyWith(
          bumilList: state.bumilList,
          filteredList: state.filteredList,
        ),
      );
    }

    try {
      final snapshot = await firestore
          .collection('bumil')
          .where('id_bidan', isEqualTo: userId)
          .orderBy('nama_ibu')
          .get();
      print('bumil: ${snapshot.docs.length}');

      final list = snapshot.docs
          .map((doc) => Bumil.fromMap(doc.id, doc.data()))
          .toList();
      print('bumil masuk: ${list.length}');
      emit(state.copyWith(bumilList: list, filteredList: list));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void search(String query) {
    final lower = query.toLowerCase();
    final filtered = state.bumilList.where((b) {
      final namaMatch = b.namaIbu.toLowerCase().contains(lower);
      final nikMatch = b.nikIbu.toLowerCase().contains(lower);
      return namaMatch || nikMatch;
    }).toList();

    emit(state.copyWith(filteredList: filtered));
  }

  // === HYDRATED ===
  @override
  SearchBumilState? fromJson(Map<String, dynamic> json) {
    return SearchBumilState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(SearchBumilState state) {
    return state.toMap();
  }
}
