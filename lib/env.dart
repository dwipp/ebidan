// import 'package:flutter/foundation.dart';
import 'app_env.dart';

const String _env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

AppEnv get appEnv {
  switch (_env) {
    case 'prod':
      return AppEnv.prod;
    case 'dev':
    default:
      return AppEnv.dev;
  }
}

// late final AppEnv appEnv;

// void resolveEnv() {
//   if (kReleaseMode) {
//     appEnv = AppEnv.prod;
//   } else {
//     appEnv = AppEnv.dev;
//   }
// }
