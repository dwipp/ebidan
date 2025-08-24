import 'package:ebidan/data/hive/bumil_hive.dart';
import 'package:ebidan/logic/bumil/cubit/add_bumil_cubit.dart';
import 'package:ebidan/logic/bumil/cubit/search_bumil_cubit.dart';
import 'package:ebidan/logic/general/cubit/sync_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/logic/general/cubit/app_version_cubit.dart';
import 'package:ebidan/logic/general/cubit/internet_cubit.dart';
import 'package:hive/hive.dart';

class BlocProviders {
  final Box<BumilHive> bumilBox;

  BlocProviders({required this.bumilBox});

  List<BlocProvider> providers() {
    return [
      BlocProvider<InternetCubit>(create: (context) => InternetCubit()),
      BlocProvider<AppVersionCubit>(create: (context) => AppVersionCubit()),
      BlocProvider<SearchBumilCubit>(create: (context) => SearchBumilCubit()),
      BlocProvider<AddBumilCubit>(
        create: (context) => AddBumilCubit(bumilBox: bumilBox),
      ),
      BlocProvider<SyncCubit>(
        create: (context) => SyncCubit(bumilBox: bumilBox),
      ),
    ];
  }
}
