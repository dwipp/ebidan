import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/logic/general/cubit/app_version_cubit.dart';
import 'package:ebidan/logic/general/cubit/internet_cubit.dart';

class BlocProviders {
  List<BlocProvider> providers() {
    return [
      BlocProvider<InternetCubit>(create: (context) => InternetCubit()),
      BlocProvider<AppVersionCubit>(create: (context) => AppVersionCubit()),
    ];
  }
}
