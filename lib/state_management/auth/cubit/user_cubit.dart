import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:ebidan/data/models/bidan_model.dart';

class UserCubit extends HydratedCubit<Bidan?> {
  UserCubit() : super(null);

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
