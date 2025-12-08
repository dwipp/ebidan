part of 'get_kunjungan_cubit.dart';

sealed class GetKunjunganState extends Equatable {
  const GetKunjunganState();

  @override
  List<Object?> get props => [];
}

final class GetKunjunganInitial extends GetKunjunganState {}

class GetKunjunganLoading extends GetKunjunganState {}

class GetKunjunganEmpty extends GetKunjunganState {}

class GetKunjunganSuccess extends GetKunjunganState {
  final List<Kunjungan> kunjungans;
  const GetKunjunganSuccess({required this.kunjungans});

  @override
  List<Object?> get props => [kunjungans];
}

class GetKunjunganFailure extends GetKunjunganState {
  final String message;

  const GetKunjunganFailure(this.message);

  @override
  List<Object?> get props => [message];
}
