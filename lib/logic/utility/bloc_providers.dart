import 'package:ebidan/logic/bumil/cubit/add_bumil_cubit.dart';
import 'package:ebidan/logic/bumil/cubit/search_bumil_cubit.dart';
import 'package:ebidan/logic/general/cubit/connectivity_cubit.dart';
import 'package:ebidan/logic/kehamilan/cubit/add_kehamilan_cubit.dart';
import 'package:ebidan/logic/riwayat/cubit/add_riwayat_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/logic/general/cubit/app_version_cubit.dart';

class BlocProviders {
  List<BlocProvider> providers() {
    return [
      BlocProvider<ConnectivityCubit>(create: (context) => ConnectivityCubit()),
      BlocProvider<AppVersionCubit>(create: (context) => AppVersionCubit()),
      BlocProvider<SearchBumilCubit>(create: (context) => SearchBumilCubit()),
      BlocProvider<AddBumilCubit>(create: (context) => AddBumilCubit()),
      BlocProvider<AddRiwayatCubit>(create: (context) => AddRiwayatCubit()),
      BlocProvider<AddKehamilanCubit>(create: (context) => AddKehamilanCubit()),
    ];
  }
}
