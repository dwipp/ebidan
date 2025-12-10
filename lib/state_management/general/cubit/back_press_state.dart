part of 'back_press_cubit.dart';

class BackPressState extends Equatable {
  final DateTime? lastPressed;

  const BackPressState({this.lastPressed});

  BackPressState copyWith({DateTime? lastPressed}) {
    return BackPressState(lastPressed: lastPressed ?? this.lastPressed);
  }

  @override
  List<Object?> get props => [lastPressed];
}
