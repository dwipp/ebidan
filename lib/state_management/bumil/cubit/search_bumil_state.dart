// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'search_bumil_cubit.dart';

class SearchBumilState extends Equatable {
  final List<Bumil> bumilList;
  final List<Bumil> filteredList;
  final String? error;
  final FilterModel filter;

  const SearchBumilState({
    required this.bumilList,
    required this.filteredList,
    this.error,
    this.filter = const FilterModel(),
  });

  factory SearchBumilState.initial() {
    return const SearchBumilState(
      bumilList: [],
      filteredList: [],
      error: null,
      filter: FilterModel(),
    );
  }

  @override
  List<Object?> get props => [bumilList, filteredList, error, filter];

  SearchBumilState copyWith({
    List<Bumil>? bumilList,
    List<Bumil>? filteredList,
    String? error,
    FilterModel? filter,
  }) {
    return SearchBumilState(
      bumilList: bumilList ?? this.bumilList,
      filteredList: filteredList ?? this.filteredList,
      error: error ?? this.error,
      filter: filter ?? this.filter,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bumilList': bumilList.map((x) => x.toMap()).toList(),
      'filteredList': filteredList.map((x) => x.toMap()).toList(),
      'error': error,
      'filter': filter.toMap(),
    };
  }

  factory SearchBumilState.fromMap(Map<String, dynamic> map) {
    return SearchBumilState(
      bumilList: List<Bumil>.from(
        (map['bumilList'] as List<dynamic>).map(
          (x) => Bumil.fromJson(x as Map<String, dynamic>),
        ),
      ),
      filteredList: List<Bumil>.from(
        (map['filteredList'] as List<dynamic>).map(
          (x) => Bumil.fromJson(x as Map<String, dynamic>),
        ),
      ),
      error: map['error'] != null ? map['error'] as String : null,
      filter: FilterModel.fromMap(map['filter'] ?? {}),
    );
  }
}

class BumilLoading extends SearchBumilState {
  BumilLoading({
    required super.bumilList,
    required super.filteredList,
    super.filter,
  });
}
