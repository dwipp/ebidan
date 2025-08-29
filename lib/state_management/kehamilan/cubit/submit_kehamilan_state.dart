// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'submit_kehamilan_cubit.dart';

abstract class SubmitKehamilanState extends Equatable {
  const SubmitKehamilanState();

  @override
  List<Object?> get props => [];
}

final class AddKehamilanInitial extends SubmitKehamilanState {}

class AddKehamilanLoading extends SubmitKehamilanState {}

class AddKehamilanEmpty extends SubmitKehamilanState {}

class AddKehamilanSuccess extends SubmitKehamilanState {
  final String idKehamilan;
  final bool firstTime;
  const AddKehamilanSuccess({
    required this.idKehamilan,
    required this.firstTime,
  });

  @override
  List<Object?> get props => [idKehamilan, firstTime];
}

class AddKehamilanFailure extends SubmitKehamilanState {
  final String message;

  const AddKehamilanFailure(this.message);

  @override
  List<Object?> get props => [message];
}
