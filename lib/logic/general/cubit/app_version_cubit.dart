import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'app_version_state.dart';

class AppVersionCubit extends Cubit<AppVersionState> {
  AppVersionCubit()
      : super(const AppVersionState(appVersion: '1.0.0', buildNumber: 1));

  void getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    int buildNumber = int.parse(packageInfo.buildNumber);
    print('verssion: $version - build: $buildNumber');
    emit(state.copyWith(appVersion: version));
    emit(state.copyWith(buildNumber: buildNumber));
  }
}
