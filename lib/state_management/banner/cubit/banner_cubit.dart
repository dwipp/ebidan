import 'package:ebidan/common/utility/remote_config_helper.dart';
import 'package:ebidan/common/utility/user_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BannerCubit extends Cubit<bool> {
  BannerCubit() : super(false);

  Future<void> load() async {
    final showBannerDays = RemoteConfigHelper.showBannerDays;
    final ts = await UserPreferences().getInt(UserPrefs.bannerDismissedAt);

    if (ts == null) {
      emit(true);
      return;
    }

    final dismissedAt = DateTime.fromMillisecondsSinceEpoch(ts);
    final shouldShow =
        DateTime.now().difference(dismissedAt).inDays >= showBannerDays;

    emit(shouldShow);
  }

  Future<void> dismiss() async {
    await UserPreferences().setInt(
      UserPrefs.bannerDismissedAt,
      DateTime.now().millisecondsSinceEpoch,
    );
    emit(false);
  }
}
