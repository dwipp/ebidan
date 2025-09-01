import 'package:ebidan/state_management/auth/cubit/login_cubit.dart';
import 'package:ebidan/state_management/bumil/cubit/submit_bumil_cubit.dart';
import 'package:ebidan/state_management/bumil/cubit/search_bumil_cubit.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/general/cubit/connectivity_cubit.dart';
import 'package:ebidan/state_management/kehamilan/cubit/submit_kehamilan_cubit.dart';
import 'package:ebidan/state_management/kehamilan/cubit/get_kehamilan_cubit.dart';
import 'package:ebidan/state_management/kehamilan/cubit/selected_kehamilan_cubit.dart';
import 'package:ebidan/state_management/kunjungan/cubit/add_kunjungan_cubit.dart';
import 'package:ebidan/state_management/kunjungan/cubit/get_kunjungan_cubit.dart';
import 'package:ebidan/state_management/kunjungan/cubit/selected_kunjungan_cubit.dart';
import 'package:ebidan/state_management/persalinan/cubit/add_persalinan_cubit.dart';
import 'package:ebidan/state_management/persalinan/cubit/selected_persalinan_cubit.dart';
import 'package:ebidan/state_management/riwayat/cubit/add_riwayat_cubit.dart';
import 'package:ebidan/state_management/riwayat/cubit/selected_riwayat_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/state_management/general/cubit/app_version_cubit.dart';

class BlocProviders {
  List<BlocProvider> providers() {
    return [
      BlocProvider<SelectedBumilCubit>(
        create: (context) => SelectedBumilCubit(),
      ),
      BlocProvider<SelectedKehamilanCubit>(
        create: (context) => SelectedKehamilanCubit(),
      ),
      BlocProvider<SelectedRiwayatCubit>(
        create: (context) => SelectedRiwayatCubit(),
      ),
      BlocProvider<SelectedKunjunganCubit>(
        create: (context) => SelectedKunjunganCubit(),
      ),
      BlocProvider<SelectedPersalinanCubit>(
        create: (context) => SelectedPersalinanCubit(),
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
      BlocProvider<SubmitKehamilanCubit>(
        create: (context) => SubmitKehamilanCubit(
          selectedKehamilanCubit: context.read<SelectedKehamilanCubit>(),
          selectedBumilCubit: context.read<SelectedBumilCubit>(),
        ),
      ),
      BlocProvider<AddKunjunganCubit>(create: (context) => AddKunjunganCubit()),
      BlocProvider<AddPersalinanCubit>(
        create: (context) => AddPersalinanCubit(),
      ),
      BlocProvider<GetKehamilanCubit>(create: (context) => GetKehamilanCubit()),
      BlocProvider<GetKunjunganCubit>(create: (context) => GetKunjunganCubit()),
      BlocProvider<LoginCubit>(create: (context) => LoginCubit()),
    ];
  }
}
