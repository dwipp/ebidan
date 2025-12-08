import 'package:bloc/bloc.dart';
import 'package:ebidan/data/models/riwayat_model.dart';

class SelectedRiwayatCubit extends Cubit<Riwayat?> {
  SelectedRiwayatCubit() : super(null);

  void selectRiwayat(Riwayat riwayat) => emit(riwayat);
  void clear() => emit(null);
}
