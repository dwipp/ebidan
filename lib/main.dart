import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/configs/app_env.dart';
import 'package:ebidan/configs/auth_gate.dart';
import 'package:ebidan/common/utility/remote_config_helper.dart';
import 'package:ebidan/configs/env.dart';
import 'package:ebidan/configs/firebase_dev_options.dart';
import 'package:ebidan/configs/firebase_prod_options.dart';
import 'package:ebidan/state_management/app_bloc_observer.dart';
import 'package:ebidan/state_management/bloc_providers.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  try {
    await initFirebase();
  } catch (e) {
    print('firebase init error: $e');
  }
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  await RemoteConfigHelper.initialize();

  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(appDocumentDirectory.path),
  );

  Bloc.observer = AppBlocObserver();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) => runApp(MainApp()));
}

Future<void> initFirebase() async {
  // resolveEnv();
  if (appEnv == AppEnv.prod) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptionsProd.currentPlatform,
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptionsDev.currentPlatform,
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: BlocProviders().providers(),
      child: MaterialApp(
        home: AuthGate(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system, // otomatis ikut sistem (light/dark)
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.cyan, // warna utama
            primary: Colors.blue, // utama
            secondary: Colors.orange, // secondary
            tertiary: Colors.cyan, // tambahan
            error: Colors.red, // error
            surface: Colors.white, // background kartu, dsb
            onPrimary: Colors.white, // teks/icon di atas primary
            onSecondary: Colors.white, // teks/icon di atas secondary
            onTertiary: Colors.grey.shade100, // teks/icon di atas tertiary
            onSurface: Colors.black87, // teks default
            brightness: Brightness.light,
            secondaryContainer: Colors.cyan,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.cyan,
            primary: Colors.blue.shade300,
            secondary: Colors.orange.shade200,
            tertiary: Colors.cyan.shade200,
            error: Colors.red.shade300,
            surface: Colors.grey.shade900,
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onTertiary: Colors.black26,
            onSurface: Colors.white,
            brightness: Brightness.dark,
            secondaryContainer: Colors.cyan,
          ),
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          MonthYearPickerLocalizations.delegate, // untuk month_year_picker
        ],
        supportedLocales: const [Locale('en', 'US'), Locale('id', 'ID')],
        locale: const Locale('id', 'ID'),
      ),
    );
  }
}
