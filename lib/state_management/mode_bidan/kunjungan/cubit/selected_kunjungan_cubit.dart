import 'package:bloc/bloc.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';

class SelectedKunjunganCubit extends Cubit<Kunjungan?> {
  SelectedKunjunganCubit() : super(null);

  void selectKunjungan(Kunjungan kunjungan) => emit(kunjungan);
  void clear() => emit(null);
}
