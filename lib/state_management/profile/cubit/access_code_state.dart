part of 'access_code_cubit.dart';

class AccessCodeState extends Equatable {
  const AccessCodeState();

  @override
  List<Object?> get props => [];
}

class AccessCodeInitial extends AccessCodeState {}

class AccessCodeLoading extends AccessCodeState {}

class AccessCodeSuccess extends AccessCodeState {
  final String accessName;
  final String desc;

  const AccessCodeSuccess({required this.accessName, required this.desc});
}

class AccessCodeFailure extends AccessCodeState {
  final String message;

  const AccessCodeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
