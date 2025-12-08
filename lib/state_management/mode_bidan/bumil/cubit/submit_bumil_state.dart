part of 'submit_bumil_cubit.dart';

class SubmitBumilState extends Equatable {
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;
  final String? bumilId;

  const SubmitBumilState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
    this.bumilId,
  });

  SubmitBumilState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
    String? bumilId,
  }) {
    return SubmitBumilState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      bumilId: bumilId,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, isSuccess, error, bumilId];
}
