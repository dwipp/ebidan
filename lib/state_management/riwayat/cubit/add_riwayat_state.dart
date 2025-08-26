part of 'add_riwayat_cubit.dart';

abstract class AddRiwayatState extends Equatable {
  const AddRiwayatState();

  @override
  List<Object?> get props => [];
}

class AddRiwayatInitial extends AddRiwayatState {}

class AddRiwayatLoading extends AddRiwayatState {}

class AddRiwayatEmpty extends AddRiwayatState {}

class AddRiwayatSuccess extends AddRiwayatState {
  final int? latestYear;
  final int jumlahRiwayat;
  final int jumlahPara;
  final int jumlahAbortus;
  final int jumlahBeratRendah;
  final List<Riwayat> listRiwayat;

  const AddRiwayatSuccess({
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

class AddRiwayatFailure extends AddRiwayatState {
  final String message;

  const AddRiwayatFailure(this.message);

  @override
  List<Object?> get props => [message];
}
