import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'back_press_state.dart';

class BackPressCubit extends Cubit<BackPressState> {
  BackPressCubit() : super(const BackPressState());

  /// cek apakah user perlu tekan 2x untuk keluar
  bool onBackPressed() {
    final now = DateTime.now();
    if (state.lastPressed == null ||
        now.difference(state.lastPressed!) > const Duration(seconds: 2)) {
      emit(state.copyWith(lastPressed: now));
      return false; // jangan keluar dulu
    }
    return true; // boleh keluar
  }
}
