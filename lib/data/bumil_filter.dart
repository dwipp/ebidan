import 'package:equatable/equatable.dart';

class FilterModel extends Equatable {
  final bool showHamilOnly;
  final List<String> statuses; // ex: ["K1", "K2"]
  final DateTime? month;

  const FilterModel({
    this.showHamilOnly = false,
    this.statuses = const [],
    this.month,
  });

  FilterModel copyWith({
    bool? showHamilOnly,
    List<String>? statuses,
    DateTime? month,
  }) {
    return FilterModel(
      showHamilOnly: showHamilOnly ?? this.showHamilOnly,
      statuses: statuses ?? this.statuses,
      month: month ?? this.month,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'showHamilOnly': showHamilOnly,
      'statuses': statuses,
      'month': month?.millisecondsSinceEpoch,
    };
  }

  factory FilterModel.fromMap(Map<String, dynamic> map) {
    return FilterModel(
      showHamilOnly: map['showHamilOnly'] as bool? ?? false,
      statuses: List<String>.from(map['statuses'] ?? []),
      month: map['month'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['month'])
          : null,
    );
  }

  @override
  List<Object?> get props => [showHamilOnly, statuses, month];
}
