import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/banner_model.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'get_banner_state.dart';

class GetBannerCubit extends HydratedCubit<GetBannerState> {
  GetBannerCubit() : super(GetBannerInitial());

  void getBanner() async {
    emit(
      GetBannerLoading(
        title: state.title,
        subtitle: state.subtitle,
        content: state.content,
      ),
    );
    final firestore = FirebaseFirestore.instance;

    try {
      final snapshot = await firestore
          .collection('banners')
          .where('is_active', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final banner = BannerModel.fromFirestore(doc);
        emit(
          GetBannerSuccess(
            title: banner.title,
            subtitle: banner.subtitle,
            content: banner.content,
          ),
        );
      } else {
        emit(
          GetBannerNoBanner(
            title: state.title,
            subtitle: state.subtitle,
            content: state.content,
          ),
        );
      }
    } catch (e) {
      print('banner error: ${e.toString()}');
      emit(
        GetBannerError(
          message: e.toString(),
          title: state.title,
          subtitle: state.subtitle,
          content: state.content,
        ),
      );
    }
  }

  @override
  GetBannerState? fromJson(Map<String, dynamic> json) {
    try {
      return GetBannerSuccess(
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        content: json['content'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(GetBannerState state) {
    if (state is GetBannerSuccess) {
      return {
        'title': state.title,
        'subtitle': state.subtitle,
        'content': state.content,
      };
    }
    return null;
  }
}
