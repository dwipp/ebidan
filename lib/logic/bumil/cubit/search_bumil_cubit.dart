import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/hive/bumil_hive.dart';
import 'package:ebidan/logic/general/cubit/connectivity_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'dart:convert';
import 'package:ebidan/data/models/bumil_model.dart';

part 'search_bumil_state.dart';

class SearchBumilCubit extends HydratedCubit<SearchBumilState> {
  final Box<BumilHive> offlineBumilBox;
  final Box<BumilHive> addedBumilBox;
  SearchBumilCubit({required this.addedBumilBox, required this.offlineBumilBox})
    : super(SearchBumilState.initial());

  Future<void> fetchData(ConnectivityCubit connectivityCubit) async {
    if (connectivityCubit.state.connected) {
      // online → fetch dari Firestore
      final userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final firestore = FirebaseFirestore.instance;

      emit(
        BumilLoading(
          bumilList: state.bumilList,
          filteredList: state.filteredList,
        ),
      );

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

        await offlineBumilBox.clear();
        for (final bumil in list) {
          await offlineBumilBox.add(BumilHive.fromModel(bumil));
        }
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    } else {
      // offline → fetch dari Hive
      final offlineList = offlineBumilBox.values
          .map((b) => b.toModel())
          .toList();
      final addedList = addedBumilBox.values.map((b) => b.toModel()).toList();
      final mergedList = [...addedList, ...offlineList];
      emit(state.copyWith(bumilList: mergedList, filteredList: mergedList));
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
