import 'package:ebidan/presentation/screens/bumil/pendataan_kehamilan.dart';
import 'package:ebidan/presentation/screens/bumil/riwayat_bumil.dart';
import 'package:ebidan/presentation/screens/home.dart';
import 'package:ebidan/presentation/screens/kunjungan/pilih_bumil.dart';
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
  static const String pilihBumil = '/pilihbumil';
  static const String pendataanKehamilan = '/pendataankehamilan';

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
      case pilihBumil:
        return MaterialPageRoute(builder: (_) => PilihBumilScreen());
      case riwayatBumil:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RiwayatBumilScreen(bumilId: args['bumilId']),
        );
      case pendataanKehamilan:
        return MaterialPageRoute(builder: (_) => PendataanKehamilan());
      default:
        throw const RouteException('Route not found!');
    }
  }
}
