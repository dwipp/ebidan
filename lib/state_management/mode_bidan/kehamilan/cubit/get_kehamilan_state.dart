part of 'get_kehamilan_cubit.dart';

sealed class GetKehamilanState extends Equatable {
  const GetKehamilanState();

  @override
  List<Object?> get props => [];
}

final class GetKehamilanInitial extends GetKehamilanState {}

class GetKehamilanLoading extends GetKehamilanState {}

class GetKehamilanEmpty extends GetKehamilanState {}

class GetKehamilanSuccess extends GetKehamilanState {
  final List<Kehamilan> kehamilans;
  const GetKehamilanSuccess({required this.kehamilans});

  @override
  List<Object?> get props => [kehamilans];
}

class GetKehamilanFailure extends GetKehamilanState {
  final String message;

  const GetKehamilanFailure(this.message);

  @override
  List<Object?> get props => [message];
}
