part of 'connectivity_cubit.dart';

class ConnectivityState extends Equatable {
  final bool connected;

  const ConnectivityState({required this.connected});

  const ConnectivityState.initial() : connected = true;

  @override
  List<Object?> get props => [connected];
}
