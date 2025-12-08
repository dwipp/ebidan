import 'package:bloc/bloc.dart';
import 'package:ebidan/data/models/bumil_model.dart';

class SelectedBumilCubit extends Cubit<Bumil?> {
  SelectedBumilCubit() : super(null);

  void selectBumil(Bumil bumil) => emit(bumil);
  void clear() => emit(null);
}
