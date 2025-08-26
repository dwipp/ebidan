part of 'add_bumil_cubit.dart';

class AddBumilState extends Equatable {
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;
  final String? bumilId;

  const AddBumilState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
    this.bumilId,
  });

  AddBumilState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
    String? bumilId,
  }) {
    return AddBumilState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      bumilId: bumilId,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, isSuccess, error, bumilId];
}
