// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'search_bumil_cubit.dart';

class SearchBumilState extends Equatable {
  final List<Bumil> bumilList;
  final List<Bumil> filteredList;

  SearchBumilState({required this.bumilList, required this.filteredList});

  factory SearchBumilState.initial() {
    return SearchBumilState(bumilList: [], filteredList: []);
  }

  @override
  List<Object> get props => [];

  SearchBumilState copyWith({
    List<Bumil>? bumilList,
    List<Bumil>? filteredList,
  }) {
    return SearchBumilState(
      bumilList: bumilList ?? this.bumilList,
      filteredList: filteredList ?? this.filteredList,
    );
  }
}

class BumilLoading extends SearchBumilState {
  BumilLoading({required super.bumilList, required super.filteredList});
}
