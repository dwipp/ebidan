import 'package:ebidan/presentation/screens/bumil/data_bumil.dart';
import 'package:ebidan/presentation/screens/kehamilan/detail_kehamilan.dart';
import 'package:ebidan/presentation/screens/bumil/detail_bumil.dart';
import 'package:ebidan/presentation/screens/kehamilan/update_kehamilan.dart';
import 'package:ebidan/presentation/screens/kunjungan/detail_kunjungan.dart';
import 'package:ebidan/presentation/screens/persalinan/add_persalinan.dart';
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
  static const String addRiwayatBumil = '/addriwayatbumil';
  static const String pilihBumil = '/pilihbumil';
  static const String pendataanKehamilan = '/pendataankehamilan';
  static const String kunjungan = '/kunjungan';
  static const String reviewKunjungan = '/reviewkunjungan';
  static const String dataBumil = '/databumil';
  static const String detailBumil = '/detailbumil';
  static const String listRiwayat = '/listriwayat';
  static const String detailRiwayat = '/detailriwayat';
  static const String dataKehamilan = '/datakehamilan';
  static const String listKehamilan = '/listkehamilan';
  static const String listKunjungan = '/listkunjungan';
  static const String detailKunjungan = '/detailkunjungan';
  static const String updateKehamilan = '/updatekehamilan';
  static const String addPersalinan = '/addpersalinan';

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
          builder: (_) => AddKehamilanScreen(
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
          builder: (_) => KunjunganScreen(
            kehamilanId: args['kehamilanId'],
            firstTime: args['firstTime'],
          ),
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
      case dataKehamilan:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DetailKehamilanScreen(kehamilan: args['kehamilan']),
        );
      case listKehamilan:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ListKehamilanScreen(
            bidanId: args['bidanId'],
            bumilId: args['bumilId'],
          ),
        );
      case listKunjungan:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ListKunjunganScreen(
            bidanId: args['bidanId'],
            bumilId: args['bumilId'],
          ),
        );
      case detailKunjungan:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DetailKunjunganScreen(kunjungan: args['kunjungan']),
        );
      case updateKehamilan:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => UpdateKehamilanScreen(
            kehamilanId: args['kehamilanId'],
            bumilId: args['bumilId'],
            resti: args['resti'],
          ),
        );
      case addPersalinan:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AddPersalinanScreen(
            kehamilanId: args['kehamilanId'],
            bumilId: args['bumilId'],
            resti: args['resti'],
          ),
        );
      default:
        throw const RouteException('Route not found!');
    }
  }
}
