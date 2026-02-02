import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/wording_model.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'wording_state.dart';

class WordingCubit extends Cubit<WordingState> {
  WordingCubit() : super(WordingInitial());

  Future<void> getSubscriptionWording() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(WordingFailure('User belum login'));
      return;
    }
    emit(WordingLoading());

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('wording')
          .doc('subscription')
          .get();
      if (!snapshot.exists) {
        emit(WordingFailure('data tidak ditemukan'));
        return;
      }
      final wording = WordingSubscription.fromFirebase(snapshot.data()!);
      emit(WordingSuccess(wordingSubscription: wording));
    } catch (e) {
      emit(
        WordingFailure(
          e is Exception
              ? e.toString().replaceAll('Exception: ', '')
              : 'Terjadi kesalahan',
        ),
      );
    }
  }
}
