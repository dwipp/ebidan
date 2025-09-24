part of 'statistic_cubit.dart';

sealed class StatisticState extends Equatable {
  final Statistic? statistic;
  const StatisticState({required this.statistic});

  @override
  List<Object?> get props => [statistic];
}

final class StatisticInitial extends StatisticState {
  const StatisticInitial({required super.statistic});
}

class StatisticLoading extends StatisticState {
  const StatisticLoading({required super.statistic});
}

class StatisticEmpty extends StatisticState {
  const StatisticEmpty({required super.statistic});
}

class StatisticSuccess extends StatisticState {
  const StatisticSuccess({required super.statistic});

  @override
  List<Object?> get props => [statistic];
}

class StatisticNoAccount extends StatisticState {
  const StatisticNoAccount({required super.statistic});
}

class StatisticFailure extends StatisticState {
  final String message;

  const StatisticFailure({required this.message, required super.statistic});

  @override
  List<Object?> get props => [message];
}
