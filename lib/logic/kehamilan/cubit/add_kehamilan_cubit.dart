import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_kehamilan_state.dart';

class AddKehamilanCubit extends Cubit<AddKehamilanState> {
  AddKehamilanCubit() : super(AddKehamilanInitial());
}
