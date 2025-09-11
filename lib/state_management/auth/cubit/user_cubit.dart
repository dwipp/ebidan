import 'package:bloc/bloc.dart';
import 'package:ebidan/data/models/bidan_model.dart';

class UserCubit extends Cubit<Bidan?> {
  UserCubit() : super(null);

  void loggedInUser(Bidan bidan) => emit(bidan);
  void clear() => emit(null);
}
