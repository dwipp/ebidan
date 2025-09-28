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
          showHamilOnly: state.showHamilOnly,
        ),
      );
    } else {
      emit(
        state.copyWith(
          bumilList: state.bumilList,
          filteredList: state.filteredList,
          showHamilOnly: state.showHamilOnly,
        ),
      );
    }

    try {
      final snapshot = await firestore
          .collection('bumil')
          .where('id_bidan', isEqualTo: userId)
          .orderBy('nama_ibu')
          .get();

      final list = snapshot.docs
          .map((doc) => Bumil.fromMap(doc.id, doc.data()))
          .toList();

      // apply filter kalau showHamilOnly aktif
      final filtered = state.showHamilOnly
          ? list.where((b) => b.isHamil).toList()
          : list;

      emit(
        state.copyWith(
          bumilList: list,
          filteredList: filtered,
          showHamilOnly: state.showHamilOnly,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(error: e.toString(), showHamilOnly: state.showHamilOnly),
      );
    }
  }

  void search(String query) {
    final lower = query.toLowerCase();

    var filtered = state.bumilList.where((b) {
      final namaMatch = b.namaIbu.toLowerCase().contains(lower);
      final nikMatch = b.nikIbu.toLowerCase().contains(lower);
      return namaMatch || nikMatch;
    }).toList();

    if (state.showHamilOnly) {
      filtered = filtered.where((b) => b.isHamil).toList();
    }

    emit(
      state.copyWith(
        filteredList: filtered,
        showHamilOnly: state.showHamilOnly,
      ),
    );
  }

  void toggleFilterHamil() {
    final newValue = !state.showHamilOnly;

    var filtered = state.bumilList;
    if (newValue) {
      filtered = filtered.where((b) => b.isHamil).toList();
    }

    emit(state.copyWith(showHamilOnly: newValue, filteredList: filtered));
  }

  void resetFilter() {
    emit(
      state.copyWith(
        showHamilOnly: false,
        filteredList: state.bumilList, // tampilkan semua lagi
      ),
    );
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
