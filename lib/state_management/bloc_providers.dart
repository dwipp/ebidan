import 'package:ebidan/state_management/bumil/cubit/submit_bumil_cubit.dart';
import 'package:ebidan/state_management/bumil/cubit/search_bumil_cubit.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/general/cubit/connectivity_cubit.dart';
import 'package:ebidan/state_management/kehamilan/cubit/add_kehamilan_cubit.dart';
import 'package:ebidan/state_management/kehamilan/cubit/get_kehamilan_cubit.dart';
import 'package:ebidan/state_management/kunjungan/cubit/add_kunjungan_cubit.dart';
import 'package:ebidan/state_management/kunjungan/cubit/get_kunjungan_cubit.dart';
import 'package:ebidan/state_management/persalinan/cubit/add_persalinan_cubit.dart';
import 'package:ebidan/state_management/riwayat/cubit/add_riwayat_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/state_management/general/cubit/app_version_cubit.dart';

class BlocProviders {
  List<BlocProvider> providers() {
    return [
      BlocProvider<SelectedBumilCubit>(
        create: (context) => SelectedBumilCubit(),
      ),
      BlocProvider<ConnectivityCubit>(create: (context) => ConnectivityCubit()),
      BlocProvider<AppVersionCubit>(create: (context) => AppVersionCubit()),
      BlocProvider<SearchBumilCubit>(create: (context) => SearchBumilCubit()),
      BlocProvider<SubmitBumilCubit>(
        create: (context) => SubmitBumilCubit(
          selectedBumilCubit: context.read<SelectedBumilCubit>(),
        ),
      ),
      BlocProvider<AddRiwayatCubit>(create: (context) => AddRiwayatCubit()),
      BlocProvider<AddKehamilanCubit>(create: (context) => AddKehamilanCubit()),
      BlocProvider<AddKunjunganCubit>(create: (context) => AddKunjunganCubit()),
      BlocProvider<AddPersalinanCubit>(
        create: (context) => AddPersalinanCubit(),
      ),
      BlocProvider<GetKehamilanCubit>(create: (context) => GetKehamilanCubit()),
      BlocProvider<GetKunjunganCubit>(create: (context) => GetKunjunganCubit()),
    ];
  }
}
