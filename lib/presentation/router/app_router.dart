import 'package:ebidan/presentation/screens/bumil/data_bumil.dart';
import 'package:ebidan/presentation/screens/bumil/detail_bumil.dart';
import 'package:ebidan/presentation/screens/bumil/detail_riwayat.dart';
import 'package:ebidan/presentation/screens/bumil/list_riwayat.dart';
import 'package:ebidan/presentation/screens/bumil/pendataan_kehamilan.dart';
import 'package:ebidan/presentation/screens/bumil/add_riwayat_bumil.dart';
import 'package:ebidan/presentation/screens/home.dart';
import 'package:ebidan/presentation/screens/kunjungan/add_kunjungan.dart';
import 'package:ebidan/presentation/screens/kunjungan/pilih_bumil.dart';
import 'package:ebidan/presentation/screens/kunjungan/review_kunjungan.dart';
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
  static const String addRiwayatBumil = '/addriwayatbumil';
  static const String pilihBumil = '/pilihbumil';
  static const String pendataanKehamilan = '/pendataankehamilan';
  static const String kunjungan = '/kunjungan';
  static const String reviewKunjungan = '/reviewkunjungan';
  static const String dataBumil = '/databumil';
  static const String detailBumil = '/detailbumil';
  static const String listRiwayat = '/listriwayat';
  static const String detailRiwayat = '/detailriwayat';

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
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PilihBumilScreen(pilihState: args['state']),
        );
      case addRiwayatBumil:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              AddRiwayatBumilScreen(bumilId: args['bumilId'], age: args['age']),
        );
      case pendataanKehamilan:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PendataanKehamilanScreen(
            bumilId: args['bumilId'],
            age: args['age'],
            latestHistoryYear: args['latestHistoryYear'] as int?,
            jumlahRiwayat: args['jumlahRiwayat'],
            jumlahPara: args['jumlahPara'],
            jumlahAbortus: args['jumlahAbortus'],
            jumlahLahirBeratRendah: args['jumlahBeratRendah'],
          ),
        );
      case kunjungan:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => KunjunganScreen(kehamilanId: args['kehamilanId']),
        );
      case reviewKunjungan:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReviewKunjunganScreen(data: args['data']),
        );
      case dataBumil:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DataBumilScreen(bumil: args['bumil']),
        );
      case detailBumil:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DetailBumilScreen(bumil: args['bumil']),
        );
      case listRiwayat:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              ListRiwayatBumilScreen(riwayatList: args['riwayatList']),
        );
      case detailRiwayat:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DetailRiwayatScreen(riwayat: args['riwayat']),
        );
      default:
        throw const RouteException('Route not found!');
    }
  }
}
