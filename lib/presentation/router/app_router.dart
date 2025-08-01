import 'package:ebidan/presentation/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:ebidan/common/exceptions/route_exception.dart';
import 'package:ebidan/main.dart';
import 'package:ebidan/presentation/screens/detail.dart';

class AppRouter {
  static const String homepage = '/';
  static const String detail = '/detail';

  const AppRouter._();
  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case homepage:
        return MaterialPageRoute(builder: (_) => Register());
      case detail:
        return MaterialPageRoute(builder: (_) => Detail());
      default:
        throw const RouteException('Route not found!');
    }
  }
}
