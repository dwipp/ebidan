import 'package:ebidan/data/hive/bumil_hive.dart';
import 'package:ebidan/firebase_options.dart';
import 'package:ebidan/logic/general/cubit/connectivity_cubit.dart';
import 'package:ebidan/logic/utility/app_bloc_observer.dart';
import 'package:ebidan/logic/utility/bloc_providers.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('firebase init error: $e');
  }

  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(appDocumentDirectory.path),
  );

  Bloc.observer = AppBlocObserver();

  await Hive.initFlutter();

  Hive.registerAdapter(BumilHiveAdapter());
  final offlineBumilBox = await Hive.openBox<BumilHive>('offline_bumil');
  final addedBumilBox = await Hive.openBox<BumilHive>('added_bumil');

  // check koneksi internet
  final connectivityCubit = ConnectivityCubit();
  connectivityCubit.checkNow();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(
      MainApp(addedBumilBox: addedBumilBox, offlineBumilBox: offlineBumilBox),
    ),
  );
}

class MainApp extends StatefulWidget {
  final Box<BumilHive> addedBumilBox;
  final Box<BumilHive> offlineBumilBox;
  const MainApp({
    super.key,
    required this.addedBumilBox,
    required this.offlineBumilBox,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: BlocProviders(
        addedBumilBox: widget.addedBumilBox,
        offlineBumilBox: widget.offlineBumilBox,
      ).providers(),
      child: const MaterialApp(
        initialRoute: AppRouter.homepage,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
