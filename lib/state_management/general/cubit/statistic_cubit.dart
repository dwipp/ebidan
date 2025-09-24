import 'package:bloc/bloc.dart';
import 'package:ebidan/data/models/statistic_model.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'statistic_state.dart';

class StatisticCubit extends Cubit<StatisticState> {
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
}
