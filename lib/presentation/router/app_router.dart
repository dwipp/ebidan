import 'package:ebidan/presentation/screens/bumil/data_bumil.dart';
import 'package:ebidan/presentation/screens/bumil/edit_bumil.dart';
import 'package:ebidan/presentation/screens/kehamilan/detail_kehamilan.dart';
import 'package:ebidan/presentation/screens/bumil/detail_bumil.dart';
import 'package:ebidan/presentation/screens/kehamilan/edit_kehamilan.dart';
import 'package:ebidan/presentation/screens/kehamilan/update_kehamilan.dart';
import 'package:ebidan/presentation/screens/kunjungan/detail_kunjungan.dart';
import 'package:ebidan/presentation/screens/persalinan/add_persalinan.dart';
import 'package:ebidan/presentation/screens/persalinan/detail_persalinan.dart';
import 'package:ebidan/presentation/screens/persalinan/list_persalinan.dart';
import 'package:ebidan/presentation/screens/riwayat/detail_riwayat.dart';
import 'package:ebidan/presentation/screens/kehamilan/list_kehamilan.dart';
import 'package:ebidan/presentation/screens/kunjungan/list_kunjungan.dart';
import 'package:ebidan/presentation/screens/riwayat/list_riwayat.dart';
import 'package:ebidan/presentation/screens/kehamilan/add_kehamilan.dart';
import 'package:ebidan/presentation/screens/riwayat/add_riwayat_bumil.dart';
import 'package:ebidan/presentation/screens/home.dart';
import 'package:ebidan/presentation/screens/kunjungan/add_kunjungan.dart';
import 'package:ebidan/presentation/screens/bumil/pilih_bumil.dart';
import 'package:ebidan/presentation/screens/kunjungan/review_kunjungan.dart';
import 'package:ebidan/presentation/screens/login.dart';
import 'package:ebidan/presentation/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:ebidan/common/exceptions/route_exception.dart';
import 'package:ebidan/presentation/screens/bumil/add_bumil.dart';

class AppRouter {
  static const String homepage = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String addBumil = '/addbumil';
  static const String addRiwayat = '/addriwayat';
  static const String pilihBumil = '/pilihbumil';
  static const String editBumil = '/editbumil';
  static const String addKehamilan = '/addkehamilan';
  static const String editKehamilan = '/editkehamilan';
  static const String kunjungan = '/kunjungan';
  static const String reviewKunjungan = '/reviewkunjungan';
  static const String dataBumil = '/databumil';
  static const String detailBumil = '/detailbumil';
  static const String listRiwayat = '/listriwayat';
  static const String detailRiwayat = '/detailriwayat';
  static const String detailKehamilan = '/detailkehamilan';
  static const String listKehamilan = '/listkehamilan';
  static const String listKunjungan = '/listkunjungan';
  static const String detailKunjungan = '/detailkunjungan';
  static const String updateKehamilan = '/updatekehamilan';
  static const String addPersalinan = '/addpersalinan';
  static const String detailPersalinan = '/detailpersalinan';
  static const String listPersalinan = '/listpersalinan';

  const AppRouter._();
  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case homepage:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case pilihBumil:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PilihBumilScreen(pilihState: args['state']),
        );
      case addBumil:
        return MaterialPageRoute(builder: (_) => AddBumilScreen());
      case dataBumil:
        return MaterialPageRoute(builder: (_) => DataBumilScreen());
      case detailBumil:
        return MaterialPageRoute(builder: (_) => DetailBumilScreen());
      case editBumil:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EditBumilScreen(bumil: args['bumil']),
        );
      case addRiwayat:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AddRiwayatBumilScreen(state: args['state']),
        );
      case listRiwayat:
        return MaterialPageRoute(builder: (_) => ListRiwayatBumilScreen());
      case detailRiwayat:
        return MaterialPageRoute(builder: (_) => DetailRiwayatScreen());
      case addKehamilan:
        return MaterialPageRoute(builder: (_) => AddKehamilanScreen());
      case detailKehamilan:
        return MaterialPageRoute(builder: (_) => DetailKehamilanScreen());
      case listKehamilan:
        return MaterialPageRoute(builder: (_) => ListKehamilanScreen());
      case updateKehamilan:
        return MaterialPageRoute(builder: (_) => UpdateKehamilanScreen());
      case editKehamilan:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EditKehamilanScreen(kehamilan: args['kehamilan']),
        );
      case kunjungan:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => KunjunganScreen(firstTime: args['firstTime']),
        );
      case reviewKunjungan:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReviewKunjunganScreen(
            data: args['data'],
            firstTime: args['firstTime'],
          ),
        );
      case listKunjungan:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ListKunjunganScreen(docId: args['docId']),
        );
      case detailKunjungan:
        return MaterialPageRoute(builder: (_) => DetailKunjunganScreen());
      case addPersalinan:
        return MaterialPageRoute(builder: (_) => AddPersalinanScreen());
      case detailPersalinan:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              DetailPersalinanScreen(persalinan: args['persalinan']),
        );
      case listPersalinan:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              ListPersalinanScreen(persalinans: args['persalinans']),
        );
      default:
        throw const RouteException('Route not found!');
    }
  }
}
