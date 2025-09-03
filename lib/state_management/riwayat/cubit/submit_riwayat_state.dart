part of 'submit_riwayat_cubit.dart';

abstract class SubmitiwayatState extends Equatable {
  const SubmitiwayatState();

  @override
  List<Object?> get props => [];
}

class SubmitRiwayatInitial extends SubmitiwayatState {}

class SubmitRiwayatLoading extends SubmitiwayatState {}

class AddRiwayatEmpty extends SubmitiwayatState {}

class SubmitRiwayatSuccess extends SubmitiwayatState {
  final int? latestYear;
  final int jumlahRiwayat;
  final int jumlahPara;
  final int jumlahAbortus;
  final int jumlahBeratRendah;
  final List<Riwayat> listRiwayat;

  const SubmitRiwayatSuccess({
    required this.latestYear,
    required this.jumlahRiwayat,
    required this.jumlahPara,
    required this.jumlahAbortus,
    required this.jumlahBeratRendah,
    required this.listRiwayat,
  });

  @override
  List<Object?> get props => [
    latestYear,
    jumlahRiwayat,
    jumlahPara,
    jumlahAbortus,
    jumlahBeratRendah,
    listRiwayat,
  ];
}

class SubmitRiwayatFailure extends SubmitiwayatState {
  final String message;

  const SubmitRiwayatFailure(this.message);

  @override
  List<Object?> get props => [message];
}
