part of 'statistic_cubit.dart';

sealed class StatisticState extends Equatable {
  const StatisticState();

  @override
  List<Object?> get props => [];
}

final class StatisticInitial extends StatisticState {}

class StatisticLoading extends StatisticState {}

class StatisticEmpty extends StatisticState {}

class StatisticSuccess extends StatisticState {
  final Statistic? statistic;
  const StatisticSuccess({required this.statistic});

  @override
  List<Object?> get props => [statistic];
}

class StatisticFailure extends StatisticState {
  final String message;

  const StatisticFailure(this.message);

  @override
  List<Object?> get props => [message];
}
