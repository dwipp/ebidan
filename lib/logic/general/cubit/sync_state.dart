part of 'sync_cubit.dart';

enum SyncStatus { initial, syncing, success, failed }

class SyncState {
  final SyncStatus status;
  final String? message;

  SyncState({required this.status, this.message});

  factory SyncState.initial() => SyncState(status: SyncStatus.initial);

  SyncState copyWith({SyncStatus? status, String? message}) {
    return SyncState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
