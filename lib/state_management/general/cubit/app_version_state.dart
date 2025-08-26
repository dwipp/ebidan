part of 'app_version_cubit.dart';

class AppVersionState extends Equatable {
  const AppVersionState({required this.appVersion, required this.buildNumber});
  final String appVersion;
  final int buildNumber;

  @override
  List<Object> get props => [appVersion, buildNumber];

  AppVersionState copyWith({
    String? appVersion,
    int? buildNumber,
  }) {
    return AppVersionState(
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
    );
  }
}
