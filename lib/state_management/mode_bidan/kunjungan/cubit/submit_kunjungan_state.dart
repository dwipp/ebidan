part of 'submit_kunjungan_cubit.dart';

abstract class SubmitKunjunganState extends Equatable {
  const SubmitKunjunganState();

  @override
  List<Object?> get props => [];
}

final class AddKunjunganInitial extends SubmitKunjunganState {}

class AddKunjunganLoading extends SubmitKunjunganState {}

class AddKunjunganEmpty extends SubmitKunjunganState {}

class AddKunjunganSuccess extends SubmitKunjunganState {}

class AddKunjunganFailure extends SubmitKunjunganState {
  final String message;

  const AddKunjunganFailure(this.message);

  @override
  List<Object?> get props => [message];
}
