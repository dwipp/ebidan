import 'package:bloc/bloc.dart';
import 'package:ebidan/data/models/kehamilan_model.dart';

class SelectedKehamilanCubit extends Cubit<Kehamilan?> {
  SelectedKehamilanCubit() : super(null);

  void selectKehamilan(Kehamilan kehamilan) => emit(kehamilan);
  void clear() => emit(null);
}
