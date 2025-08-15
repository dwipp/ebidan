import 'package:ebidan/presentation/screens/bumil/riwayat_bumil.dart';
import 'package:ebidan/presentation/screens/home.dart';
import 'package:ebidan/presentation/screens/login.dart';
import 'package:ebidan/presentation/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:ebidan/common/exceptions/route_exception.dart';
import 'package:ebidan/main.dart';
import 'package:ebidan/presentation/screens/bumil/add_bumil.dart';

class AppRouter {
  static const String homepage = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String addBumil = '/addbumil';
  static const String riwayatBumil = '/riwayatbumil';

  const AppRouter._();
  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case homepage:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case addBumil:
        return MaterialPageRoute(builder: (_) => AddBumilScreen());
      // case riwayatBumil:
      //   return MaterialPageRoute(
      //     builder: (_) => RiwayatBumilScreen(bumilId: '123'),
      //   );
      case riwayatBumil:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RiwayatBumilScreen(bumilId: args['bumilId']),
        );
      default:
        throw const RouteException('Route not found!');
    }
  }
}
