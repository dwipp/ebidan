part of 'add_kunjungan_cubit.dart';

abstract class AddKunjunganState extends Equatable {
  const AddKunjunganState();

  @override
  List<Object?> get props => [];
}

final class AddKunjunganInitial extends AddKunjunganState {}

class AddKunjunganLoading extends AddKunjunganState {}

class AddKunjunganEmpty extends AddKunjunganState {}

class AddKunjunganSuccess extends AddKunjunganState {}

class AddKunjunganFailure extends AddKunjunganState {
  final String message;

  const AddKunjunganFailure(this.message);

  @override
  List<Object?> get props => [message];
}
