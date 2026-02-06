part of 'wording_cubit.dart';

sealed class WordingState extends Equatable {
  const WordingState();

  @override
  List<Object?> get props => [];
}

final class WordingInitial extends WordingState {}

class WordingLoading extends WordingState {}

class WordingSuccess extends WordingState {
  final WordingSubscription wordingSubscription;
  const WordingSuccess({required this.wordingSubscription});

  @override
  List<Object?> get props => [wordingSubscription];
}

class WordingFailure extends WordingState {
  final String message;

  const WordingFailure(this.message);

  @override
  List<Object?> get props => [message];
}
