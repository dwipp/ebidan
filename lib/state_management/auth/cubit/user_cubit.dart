import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:ebidan/data/models/bidan_model.dart';

class UserCubit extends HydratedCubit<Bidan?> {
  UserCubit() : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      emit(state); // ini memicu BlocListener
    }
  }

  void loggedInUser(Bidan bidan) => emit(bidan);
  // void clear() => emit(null);
  Future<void> clearAll() async {
    emit(null);
    await clear(); // ini panggil clear() bawaan HydratedCubit
  }

  @override
  Bidan? fromJson(Map<String, dynamic> json) {
    return json.isNotEmpty ? Bidan.fromJson(json) : null;
  }

  @override
  Map<String, dynamic>? toJson(Bidan? state) {
    return state?.toJson();
  }
}
