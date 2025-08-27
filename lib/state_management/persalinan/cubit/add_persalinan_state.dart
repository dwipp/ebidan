part of 'add_persalinan_cubit.dart';

sealed class AddPersalinanState extends Equatable {
  const AddPersalinanState();

  @override
  List<Object?> get props => [];
}

final class AddPersalinanInitial extends AddPersalinanState {}

class AddPersalinanLoading extends AddPersalinanState {}

class AddPersalinanEmpty extends AddPersalinanState {}

class AddPersalinanSuccess extends AddPersalinanState {}

class AddPersalinanFailure extends AddPersalinanState {
  final String message;

  const AddPersalinanFailure(this.message);

  @override
  List<Object?> get props => [message];
}
