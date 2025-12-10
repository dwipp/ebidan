// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'get_bidan_cubit.dart';

class GetBidanState extends Equatable {
  final List<Bidan> bidanList;
  final String? error;
  const GetBidanState({required this.bidanList, this.error});

  factory GetBidanState.initial() {
    return const GetBidanState(bidanList: [], error: null);
  }

  @override
  List<Object?> get props => [bidanList, error];

  GetBidanState copyWith({List<Bidan>? bidanList, String? error}) {
    return GetBidanState(
      bidanList: bidanList ?? this.bidanList,
      error: error ?? this.error,
    );
  }
}

class GetBidanLoading extends GetBidanState {
  const GetBidanLoading({required super.bidanList});
}
