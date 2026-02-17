part of 'check_access_code_cubit.dart';

sealed class CheckAccessCodeState extends Equatable {
  const CheckAccessCodeState();

  @override
  List<Object?> get props => [];
}

final class CheckAccessCodeInitial extends CheckAccessCodeState {}

class CheckAccessCodeLoading extends CheckAccessCodeState {}

class CheckAccessCodeSuccess extends CheckAccessCodeState {}

class CheckAccessCodeFailure extends CheckAccessCodeState {
  final String message;

  const CheckAccessCodeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
