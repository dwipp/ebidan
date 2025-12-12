import 'package:ebidan/data/models/statistic_model.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'statistic_state.dart';

class StatisticCubit extends HydratedCubit<StatisticState> {
  StatisticCubit() : super(StatisticInitial(statistic: null));

  Future<void> fetchStatistic() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(StatisticNoAccount(statistic: null));
      return;
    }
    emit(StatisticLoading(statistic: null));

    try {
      final doc = await FirebaseFirestore.instance
          .collection("statistics")
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = Statistic.fromMap(doc.data()!);
        emit(StatisticSuccess(statistic: data));
      } else {
        emit(StatisticSuccess(statistic: null));
      }
    } catch (e) {
      emit(StatisticFailure(message: e.toString(), statistic: null));
    }
  }

  void updateLocalKehamilan() {}
  void updateLocalKunjungan() {}
  void updateLocalBumil() {
    // contoh
    final current = state.statistic;
    if (current == null) return;

    final updated = current.copyWith(
      kehamilan: current.kehamilan.copyWith(
        allBumilCount: current.kehamilan.allBumilCount + 1,
      ),
    );

    emit(StatisticSuccess(statistic: updated));
  }

  void updateLocalPersalinan() {}

  @override
  StatisticState? fromJson(Map<String, dynamic> json) {
    try {
      return StatisticSuccess(
        statistic: json['statistic'] != null
            ? Statistic.fromMap(json['statistic'])
            : null,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(StatisticState state) {
    return {'statistic': state.statistic?.toMap()};
  }
}
