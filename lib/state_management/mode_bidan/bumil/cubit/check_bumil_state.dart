part of 'check_bumil_cubit.dart';

abstract class CheckBumilState extends Equatable {
  const CheckBumilState();

  @override
  List<Object?> get props => [];
}

class CheckBumilInitial extends CheckBumilState {}

class CheckBumilLoading extends CheckBumilState {}

class CheckBumilFound extends CheckBumilState {
  final String nama;
  const CheckBumilFound({required this.nama});

  @override
  List<Object?> get props => [nama];
}

class CheckBumilNotFound extends CheckBumilState {}

class CheckBumilError extends CheckBumilState {
  final String message;
  const CheckBumilError({required this.message});

  @override
  List<Object?> get props => [message];
}
