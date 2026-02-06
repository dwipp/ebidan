// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'get_banner_cubit.dart';

abstract class GetBannerState {
  final String title;
  final String subtitle;
  final String? content;

  const GetBannerState({
    required this.title,
    required this.subtitle,
    required this.content,
  });
}

class GetBannerInitial extends GetBannerState {
  const GetBannerInitial() : super(title: '', subtitle: '', content: null);
}

class GetBannerLoading extends GetBannerState {
  const GetBannerLoading({
    required super.title,
    required super.subtitle,
    required super.content,
  });
}

class GetBannerSuccess extends GetBannerState {
  const GetBannerSuccess({
    required super.title,
    required super.subtitle,
    required super.content,
  });
}

class GetBannerNoBanner extends GetBannerState {
  const GetBannerNoBanner({
    required super.title,
    required super.subtitle,
    required super.content,
  });
}

class GetBannerError extends GetBannerState {
  final String message;

  const GetBannerError({
    required this.message,
    required super.title,
    required super.subtitle,
    required super.content,
  });
}
