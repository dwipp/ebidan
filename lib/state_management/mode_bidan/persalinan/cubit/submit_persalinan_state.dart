part of 'submit_persalinan_cubit.dart';

sealed class SubmitPersalinanState extends Equatable {
  const SubmitPersalinanState();

  @override
  List<Object?> get props => [];
}

final class AddPersalinanInitial extends SubmitPersalinanState {}

class AddPersalinanLoading extends SubmitPersalinanState {}

class AddPersalinanEmpty extends SubmitPersalinanState {}

class AddPersalinanSuccess extends SubmitPersalinanState {}

class AddPersalinanFailure extends SubmitPersalinanState {
  final String message;

  const AddPersalinanFailure(this.message);

  @override
  List<Object?> get props => [message];
}
