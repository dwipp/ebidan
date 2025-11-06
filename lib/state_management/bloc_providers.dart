import 'package:ebidan/state_management/auth/cubit/login_cubit.dart';
import 'package:ebidan/state_management/profile/cubit/profile_cubit.dart';
import 'package:ebidan/state_management/auth/cubit/register_cubit.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:ebidan/state_management/bumil/cubit/check_bumil_cubit.dart';
import 'package:ebidan/state_management/bumil/cubit/submit_bumil_cubit.dart';
import 'package:ebidan/state_management/bumil/cubit/search_bumil_cubit.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/general/cubit/back_press_cubit.dart';
import 'package:ebidan/state_management/general/cubit/connectivity_cubit.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:ebidan/state_management/kehamilan/cubit/submit_kehamilan_cubit.dart';
import 'package:ebidan/state_management/kehamilan/cubit/get_kehamilan_cubit.dart';
import 'package:ebidan/state_management/kehamilan/cubit/selected_kehamilan_cubit.dart';
import 'package:ebidan/state_management/kunjungan/cubit/submit_kunjungan_cubit.dart';
import 'package:ebidan/state_management/kunjungan/cubit/get_kunjungan_cubit.dart';
import 'package:ebidan/state_management/kunjungan/cubit/selected_kunjungan_cubit.dart';
import 'package:ebidan/state_management/persalinan/cubit/submit_persalinan_cubit.dart';
import 'package:ebidan/state_management/persalinan/cubit/selected_persalinan_cubit.dart';
import 'package:ebidan/state_management/riwayat/cubit/submit_riwayat_cubit.dart';
import 'package:ebidan/state_management/riwayat/cubit/selected_riwayat_cubit.dart';
import 'package:ebidan/state_management/subscription/cubit/subscription_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/state_management/general/cubit/app_version_cubit.dart';

class BlocProviders {
  List<BlocProvider> providers() {
    return [
      BlocProvider<UserCubit>(create: (context) => UserCubit()),
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
      BlocProvider<CheckBumilCubit>(
        create: (context) => CheckBumilCubit(
          selectedBumilCubit: context.read<SelectedBumilCubit>(),
        ),
      ),
      BlocProvider<SubmitRiwayatCubit>(
        create: (context) => SubmitRiwayatCubit(
          selectedBumilCubit: context.read<SelectedBumilCubit>(),
          selectedRiwayatCubit: context.read<SelectedRiwayatCubit>(),
        ),
      ),
      BlocProvider<SubmitKehamilanCubit>(
        create: (context) => SubmitKehamilanCubit(
          selectedKehamilanCubit: context.read<SelectedKehamilanCubit>(),
          selectedBumilCubit: context.read<SelectedBumilCubit>(),
        ),
      ),
      BlocProvider<SubmitKunjunganCubit>(
        create: (context) => SubmitKunjunganCubit(
          selectedBumilCubit: context.read<SelectedBumilCubit>(),
          selectedKunjunganCubit: context.read<SelectedKunjunganCubit>(),
          selectedKehamilanCubit: context.read<SelectedKehamilanCubit>(),
        ),
      ),
      BlocProvider<SubmitPersalinanCubit>(
        create: (context) => SubmitPersalinanCubit(
          selectedBumilCubit: context.read<SelectedBumilCubit>(),
          selectedKehamilanCubit: context.read<SelectedKehamilanCubit>(),
          selectedPersalinanCubit: context.read<SelectedPersalinanCubit>(),
        ),
      ),
      BlocProvider<GetKehamilanCubit>(create: (context) => GetKehamilanCubit()),
      BlocProvider<GetKunjunganCubit>(create: (context) => GetKunjunganCubit()),
      BlocProvider<LoginCubit>(
        create: (context) => LoginCubit(user: context.read<UserCubit>()),
      ),
      BlocProvider<RegisterCubit>(
        create: (context) => RegisterCubit(user: context.read<UserCubit>()),
      ),
      BlocProvider<ProfileCubit>(
        create: (context) => ProfileCubit(userCubit: context.read<UserCubit>()),
      ),
      BlocProvider<SubscriptionCubit>(
        create: (context) =>
            SubscriptionCubit(user: context.read<UserCubit>())..initStoreInfo(),
      ),
      BlocProvider<StatisticCubit>(create: (context) => StatisticCubit()),
      BlocProvider(
        create: (_) => StatisticCubit()..fetchStatistic(),
      ), // fetch statistic
      BlocProvider(
        create: (_) => ConnectivityCubit()..checkNow(),
      ), //. check internet
      BlocProvider<BackPressCubit>(create: (context) => BackPressCubit()),
    ];
  }
}
