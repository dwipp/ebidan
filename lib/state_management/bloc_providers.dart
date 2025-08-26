import 'package:ebidan/state_management/bumil/cubit/add_bumil_cubit.dart';
import 'package:ebidan/state_management/bumil/cubit/search_bumil_cubit.dart';
import 'package:ebidan/state_management/general/cubit/connectivity_cubit.dart';
import 'package:ebidan/state_management/kehamilan/cubit/add_kehamilan_cubit.dart';
import 'package:ebidan/state_management/kunjungan/cubit/add_kunjungan_cubit.dart';
import 'package:ebidan/state_management/riwayat/cubit/add_riwayat_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/state_management/general/cubit/app_version_cubit.dart';

class BlocProviders {
  List<BlocProvider> providers() {
    return [
      BlocProvider<ConnectivityCubit>(create: (context) => ConnectivityCubit()),
      BlocProvider<AppVersionCubit>(create: (context) => AppVersionCubit()),
      BlocProvider<SearchBumilCubit>(create: (context) => SearchBumilCubit()),
      BlocProvider<AddBumilCubit>(create: (context) => AddBumilCubit()),
      BlocProvider<AddRiwayatCubit>(create: (context) => AddRiwayatCubit()),
      BlocProvider<AddKehamilanCubit>(create: (context) => AddKehamilanCubit()),
      BlocProvider<AddKunjunganCubit>(create: (context) => AddKunjunganCubit()),
    ];
  }
}
