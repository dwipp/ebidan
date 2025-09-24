import 'package:ebidan/firebase_options.dart';
import 'package:ebidan/state_management/general/cubit/connectivity_cubit.dart';
import 'package:ebidan/state_management/app_bloc_observer.dart';
import 'package:ebidan/state_management/bloc_providers.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  // check koneksi internet
  final connectivityCubit = ConnectivityCubit();
  connectivityCubit.checkNow();

  final statisticCubit = StatisticCubit();
  statisticCubit.fetchStatistic();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) => runApp(MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: BlocProviders().providers(),
      child: MaterialApp(
        initialRoute: AppRouter.homepage,
        onGenerateRoute: AppRouter.onGenerateRoute,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system, // otomatis ikut sistem (light/dark)
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, // warna utama
            primary: Colors.blue, // utama
            secondary: Colors.orange, // secondary
            tertiary: Colors.green, // tambahan
            error: Colors.red, // error
            surface: Colors.white, // background kartu, dsb
            onPrimary: Colors.white, // teks/icon di atas primary
            onSecondary: Colors.white, // teks/icon di atas secondary
            onTertiary: Colors.grey.shade100, // teks/icon di atas tertiary
            onSurface: Colors.black87, // teks default
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: Colors.blue.shade300,
            secondary: Colors.orange.shade200,
            tertiary: Colors.green.shade200,
            error: Colors.red.shade300,
            surface: Colors.grey.shade900,
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onTertiary: Colors.black26,
            onSurface: Colors.white,
            brightness: Brightness.dark,
          ),
        ),
      ),
    );
  }
}
