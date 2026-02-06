import 'package:equatable/equatable.dart';

class FilterModel extends Equatable {
  final bool showHamilOnly;
  final List<String> statuses; // ex: ["K1", "K2"]

  const FilterModel({this.showHamilOnly = false, this.statuses = const []});

  FilterModel copyWith({bool? showHamilOnly, List<String>? statuses}) {
    return FilterModel(
      showHamilOnly: showHamilOnly ?? this.showHamilOnly,
      statuses: statuses ?? this.statuses,
    );
  }

  Map<String, dynamic> toMap() {
    return {'showHamilOnly': showHamilOnly, 'statuses': statuses};
  }

  factory FilterModel.fromMap(Map<String, dynamic> map) {
    return FilterModel(
      showHamilOnly: map['showHamilOnly'] as bool? ?? false,
      statuses: List<String>.from(map['statuses'] ?? []),
    );
  }

  @override
  List<Object?> get props => [showHamilOnly, statuses];
}
