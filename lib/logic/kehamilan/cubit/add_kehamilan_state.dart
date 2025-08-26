// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'add_kehamilan_cubit.dart';

abstract class AddKehamilanState extends Equatable {
  const AddKehamilanState();

  @override
  List<Object?> get props => [];
}

final class AddKehamilanInitial extends AddKehamilanState {}

class AddKehamilanLoading extends AddKehamilanState {}

class AddKehamilanEmpty extends AddKehamilanState {}

class AddKehamilanSuccess extends AddKehamilanState {
  final String idKehamilan;
  final bool firstTime;
  const AddKehamilanSuccess({
    required this.idKehamilan,
    required this.firstTime,
  });

  @override
  List<Object?> get props => [idKehamilan, firstTime];
}

class AddKehamilanFailure extends AddKehamilanState {
  final String message;

  const AddKehamilanFailure(this.message);

  @override
  List<Object?> get props => [message];
}
