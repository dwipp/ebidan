import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/bumil_filter.dart';
import 'package:ebidan/state_management/general/cubit/connectivity_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
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
          filter: state.filter,
        ),
      );
    } else {
      emit(
        state.copyWith(
          bumilList: state.bumilList,
          filteredList: state.filteredList,
          filter: state.filter,
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

      // apply semua filter lewat helper
      final filtered = _applyFilters(list);

      emit(
        state.copyWith(
          bumilList: list,
          filteredList: filtered,
          filter: state.filter,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString(), filter: state.filter));
    }
  }

  void search(String query) {
    final lower = query.toLowerCase();

    var filtered = state.bumilList.where((b) {
      final namaMatch = b.namaIbu.toLowerCase().contains(lower);
      final nikMatch = b.nikIbu.toLowerCase().contains(lower);
      return namaMatch || nikMatch;
    }).toList();

    filtered = _applyFilters(filtered);

    emit(state.copyWith(filteredList: filtered, filter: state.filter));
  }

  // == FILTER ==
  // apply semua filter
  List<Bumil> _applyFilters(List<Bumil> list, {FilterModel? filter}) {
    final f = filter ?? state.filter;
    var result = list;

    if (f.showHamilOnly) {
      result = result.where((b) => b.isHamil).toList();
    }

    if (f.statuses.isNotEmpty) {
      result = result
          .where((b) => f.statuses.contains(b.latestKunjungan?.status))
          .toList();
    }

    if (f.month != null) {
      result = result
          .where(
            (b) =>
                (b.latestKunjungan?.createdAt?.year == f.month!.year) &&
                (b.latestKunjungan?.createdAt?.month == f.month!.month),
          )
          .toList();
    }

    return result;
  }

  void toggleFilterHamil() {
    final newFilter = state.filter.copyWith(
      showHamilOnly: !state.filter.showHamilOnly,
    );

    emit(
      state.copyWith(
        filter: newFilter,
        filteredList: _applyFilters(state.bumilList, filter: newFilter),
      ),
    );
  }

  void setStatuses(List<String> statuses) {
    final newFilter = state.filter.copyWith(statuses: statuses);
    emit(
      state.copyWith(
        filter: newFilter,
        filteredList: _applyFilters(state.bumilList, filter: newFilter),
      ),
    );
  }

  void setMonth(DateTime? month) {
    final newFilter = state.filter.copyWith(month: month);
    emit(
      state.copyWith(
        filter: newFilter,
        filteredList: _applyFilters(state.bumilList, filter: newFilter),
      ),
    );
  }

  void resetFilter() {
    emit(
      state.copyWith(
        filter: const FilterModel(),
        filteredList: state.bumilList,
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
