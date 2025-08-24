import 'package:ebidan/data/hive/bumil_hive.dart';
import 'package:ebidan/logic/bumil/cubit/add_bumil_cubit.dart';
import 'package:ebidan/logic/bumil/cubit/search_bumil_cubit.dart';
import 'package:ebidan/logic/general/cubit/connectivity_cubit.dart';
import 'package:ebidan/logic/general/cubit/sync_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/logic/general/cubit/app_version_cubit.dart';
import 'package:hive/hive.dart';

class BlocProviders {
  final Box<BumilHive> addedBumilBox;
  final Box<BumilHive> offlineBumilBox;

  BlocProviders({required this.addedBumilBox, required this.offlineBumilBox});

  List<BlocProvider> providers() {
    return [
      BlocProvider<ConnectivityCubit>(create: (context) => ConnectivityCubit()),
      BlocProvider<AppVersionCubit>(create: (context) => AppVersionCubit()),
      BlocProvider<SearchBumilCubit>(
        create: (context) => SearchBumilCubit(
          addedBumilBox: addedBumilBox,
          offlineBumilBox: offlineBumilBox,
        ),
      ),
      BlocProvider<AddBumilCubit>(
        create: (context) => AddBumilCubit(addedBumilBox: addedBumilBox),
      ),
      BlocProvider<SyncCubit>(
        create: (context) => SyncCubit(addedBumilBox: addedBumilBox),
      ),
    ];
  }
}
