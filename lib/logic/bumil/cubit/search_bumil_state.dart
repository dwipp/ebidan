// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'search_bumil_cubit.dart';

class SearchBumilState extends Equatable {
  final List<Bumil> bumilList;
  final List<Bumil> filteredList;
  final String? error;

  const SearchBumilState({
    required this.bumilList,
    required this.filteredList,
    this.error,
  });

  factory SearchBumilState.initial() {
    return const SearchBumilState(bumilList: [], filteredList: [], error: null);
  }

  @override
  List<Object?> get props => [bumilList, filteredList, error];

  SearchBumilState copyWith({
    List<Bumil>? bumilList,
    List<Bumil>? filteredList,
    String? error,
  }) {
    return SearchBumilState(
      bumilList: bumilList ?? this.bumilList,
      filteredList: filteredList ?? this.filteredList,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bumilList': bumilList.map((x) => x.toMap()).toList(),
      'filteredList': filteredList.map((x) => x.toMap()).toList(),
      'error': error,
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
    );
  }

  String toJson() => json.encode(toMap());

  factory SearchBumilState.fromJson(String source) =>
      SearchBumilState.fromMap(json.decode(source) as Map<String, dynamic>);
}

class BumilLoading extends SearchBumilState {
  BumilLoading({required super.bumilList, required super.filteredList});
}
