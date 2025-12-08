import 'package:bloc/bloc.dart';
import 'package:ebidan/data/models/persalinan_model.dart';

class SelectedPersalinanCubit extends Cubit<Persalinan?> {
  SelectedPersalinanCubit() : super(null);

  void selectPersalinan(Persalinan persalinan) => emit(persalinan);
  void clear() => emit(null);
}
