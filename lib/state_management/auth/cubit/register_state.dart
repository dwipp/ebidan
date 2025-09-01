part of 'register_cubit.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterSubmitting extends RegisterState {}

class RegisterSuccess extends RegisterState {}

class RegisterFailure extends RegisterState {
  final String message;

  const RegisterFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Tambahan state untuk pencarian puskesmas
class RegisterSearchLoaded extends RegisterState {
  final List<Map<String, dynamic>> list;

  const RegisterSearchLoaded(this.list);

  @override
  List<Object?> get props => [list];
}
