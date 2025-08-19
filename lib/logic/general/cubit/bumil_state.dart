// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'bumil_cubit.dart';

class BumilState extends Equatable {
  final List<Bumil> bumilList;
  final List<Bumil> filteredList;

  BumilState({required this.bumilList, required this.filteredList});

  factory BumilState.initial() {
    return BumilState(bumilList: [], filteredList: []);
  }

  @override
  List<Object> get props => [];

  BumilState copyWith({List<Bumil>? bumilList, List<Bumil>? filteredList}) {
    return BumilState(
      bumilList: bumilList ?? this.bumilList,
      filteredList: filteredList ?? this.filteredList,
    );
  }
}

class BumilLoading extends BumilState {
  BumilLoading({required super.bumilList, required super.filteredList});
}
