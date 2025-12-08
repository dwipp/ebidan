import 'package:ebidan/presentation/screens/profile/edit_profile.dart';
import 'package:ebidan/presentation/screens/profile/profile.dart';
import 'package:ebidan/presentation/screens/mode_bidan/bumil/check_bumil.dart';
import 'package:ebidan/presentation/screens/mode_bidan/bumil/data_bumil.dart';
import 'package:ebidan/presentation/screens/mode_bidan/bumil/edit_bumil.dart';
import 'package:ebidan/presentation/screens/mode_bidan/bumil/ringkasan_bumil.dart';
import 'package:ebidan/presentation/screens/mode_bidan/kehamilan/detail_kehamilan.dart';
import 'package:ebidan/presentation/screens/mode_bidan/bumil/detail_bumil.dart';
import 'package:ebidan/presentation/screens/mode_bidan/kehamilan/edit_kehamilan.dart';
import 'package:ebidan/presentation/screens/mode_bidan/kehamilan/update_kehamilan.dart';
import 'package:ebidan/presentation/screens/mode_bidan/kunjungan/detail_kunjungan.dart';
import 'package:ebidan/presentation/screens/mode_bidan/kunjungan/edit_kunjungan.dart';
import 'package:ebidan/presentation/screens/mode_bidan/kunjungan/grafik_kunjungan.dart';
import 'package:ebidan/presentation/screens/mode_bidan/persalinan/add_persalinan.dart';
import 'package:ebidan/presentation/screens/mode_bidan/persalinan/detail_persalinan.dart';
import 'package:ebidan/presentation/screens/mode_bidan/persalinan/edit_persalinan.dart';
import 'package:ebidan/presentation/screens/mode_bidan/persalinan/list_persalinan.dart';
import 'package:ebidan/presentation/screens/mode_bidan/riwayat/detail_riwayat.dart';
import 'package:ebidan/presentation/screens/mode_bidan/kehamilan/list_kehamilan.dart';
import 'package:ebidan/presentation/screens/mode_bidan/kunjungan/list_kunjungan.dart';
import 'package:ebidan/presentation/screens/mode_bidan/riwayat/edit_riwayat.dart';
import 'package:ebidan/presentation/screens/mode_bidan/riwayat/list_riwayat.dart';
import 'package:ebidan/presentation/screens/mode_bidan/kehamilan/add_kehamilan.dart';
import 'package:ebidan/presentation/screens/mode_bidan/riwayat/add_riwayat_bumil.dart';
import 'package:ebidan/presentation/screens/home.dart';
import 'package:ebidan/presentation/screens/mode_bidan/kunjungan/add_kunjungan.dart';
import 'package:ebidan/presentation/screens/mode_bidan/bumil/pilih_bumil.dart';
import 'package:ebidan/presentation/screens/mode_bidan/kunjungan/review_kunjungan.dart';
import 'package:ebidan/presentation/screens/auth/login.dart';
import 'package:ebidan/presentation/screens/auth/register.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/kunjungan/kunjungan_stats.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/kunjungan/list_kunjungan_stats.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/kunjungan/tren_kunjungan_stats.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/persalinan/list_persalinan_stats.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/persalinan/persalinan_stats.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/persalinan/tren_persalinan_stats.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/resti/list_resti_stats.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/resti/resti_stats.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/resti/tren_resti_stats.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/sf/list_sf_stats.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/sf/sf_stats.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/sf/tren_sf_stats.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/statistics.dart';
import 'package:ebidan/presentation/screens/mode_bidan/subscription/subs_status.dart';
import 'package:ebidan/presentation/screens/mode_bidan/subscription/subscription.dart';
import 'package:flutter/material.dart';
import 'package:ebidan/common/exceptions/route_exception.dart';
import 'package:ebidan/presentation/screens/mode_bidan/bumil/add_bumil.dart';

class AppRouter {
  static const String homepage = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String editProfile = '/editprofile';

  static const String addBumil = '/addbumil';
  static const String pilihBumil = '/pilihbumil';
  static const String editBumil = '/editbumil';
  static const String dataBumil = '/databumil';
  static const String detailBumil = '/detailbumil';
  static const String ringkasanBumil = '/ringkasanbumil';
  static const String checkDataBumil = '/checkbumil';

  static const String addKehamilan = '/addkehamilan';
  static const String editKehamilan = '/editkehamilan';
  static const String detailKehamilan = '/detailkehamilan';
  static const String listKehamilan = '/listkehamilan';
  static const String updateKehamilan = '/updatekehamilan';

  static const String kunjungan = '/kunjungan';
  static const String editKunjungan = '/editkunjungan';
  static const String reviewKunjungan = '/reviewkunjungan';
  static const String listKunjungan = '/listkunjungan';
  static const String detailKunjungan = '/detailkunjungan';
  static const String grafikKunjungan = '/grafikkunjungan';

  static const String addRiwayat = '/addriwayat';
  static const String listRiwayat = '/listriwayat';
  static const String detailRiwayat = '/detailriwayat';
  static const String editRiwayat = '/editriwayat';

  static const String addPersalinan = '/addpersalinan';
  static const String detailPersalinan = '/detailpersalinan';
  static const String listPersalinan = '/listpersalinan';
  static const String editPersalinan = '/editpersalinan';

  // subs
  static const String subs = '/subscription';
  static const String subsStatus = '/subsstatus';

  // statistik
  static const String statistics = '/statistics';
  // stat kunjungan
  static const String kunjunganStats = '/kunjunganstats';
  static const String listKunjunganStats = '/listkunjunganstats';
  static const String trenKunjunganStats = '/trenkunjunganstats';
  // stat rest
  static const String restiStats = '/restistats';
  static const String listRestiStats = '/listrestistats';
  static const String trenRestiStats = '/trenrestistats';
  // stat SF
  static const String sfStats = '/sfstats';
  static const String listSfStats = '/listfsstats';
  static const String trenSfStats = '/trensfstats';
  // stat persalinan
  static const String persalinanStats = '/persalinanstats';
  static const String listPersalinanStats = '/listpersalinanstats';
  static const String trenPersalinanStats = '/trenpersalinanstats';

  const AppRouter._();
  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case homepage:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => EditProfileScreen());
      case pilihBumil:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PilihBumilScreen(pilihState: args['state']),
        );
      case addBumil:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AddBumilScreen(nikIbu: args['nikIbu']),
        );
      case dataBumil:
        return MaterialPageRoute(builder: (_) => DataBumilScreen());
      case detailBumil:
        return MaterialPageRoute(builder: (_) => DetailBumilScreen());
      case ringkasanBumil:
        return MaterialPageRoute(builder: (_) => RingkasanBumilScreen());
      case editBumil:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EditBumilScreen(bumil: args['bumil']),
        );
      case checkDataBumil:
        return MaterialPageRoute(builder: (_) => CheckBumilScreen());
      case addRiwayat:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AddRiwayatBumilScreen(state: args['state']),
        );
      case listRiwayat:
        return MaterialPageRoute(builder: (_) => ListRiwayatBumilScreen());
      case detailRiwayat:
        return MaterialPageRoute(builder: (_) => DetailRiwayatScreen());
      case editRiwayat:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EditRiwayatBumilScreen(state: args['state']),
        );
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
      case editKunjungan:
        return MaterialPageRoute(builder: (_) => EditKunjunganScreen());
      case grafikKunjungan:
        return MaterialPageRoute(builder: (_) => GrafikKunjunganScreen());
      case addPersalinan:
        return MaterialPageRoute(builder: (_) => AddPersalinanScreen());
      case detailPersalinan:
        return MaterialPageRoute(builder: (_) => DetailPersalinanScreen());
      case listPersalinan:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              ListPersalinanScreen(persalinans: args['persalinans']),
        );
      case editPersalinan:
        return MaterialPageRoute(builder: (_) => EditPersalinanScreen());
      case subs:
        return MaterialPageRoute(builder: (_) => SubscriptionScreen());
      case subsStatus:
        return MaterialPageRoute(builder: (_) => SubscriptionStatusPage());
      case statistics:
        return MaterialPageRoute(builder: (_) => StatisticsScreen());
      case kunjunganStats:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => KunjunganStatsScreen(monthKey: args['monthKey']),
        );
      case trenKunjunganStats:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              TrenKunjunganStatsScreen(monthKeys: args['monthKeys']),
        );
      case listKunjunganStats:
        return MaterialPageRoute(builder: (_) => ListKunjunganStatsScreen());
      case restiStats:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RestiStatsScreen(monthKey: args['monthKey']),
        );
      case listRestiStats:
        return MaterialPageRoute(builder: (_) => ListRestiStatsScreen());
      case trenRestiStats:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TrenRestiStatsScreen(monthKeys: args['monthKeys']),
        );
      case sfStats:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => SfStatsScreen(monthKey: args['monthKey']),
        );
      case listSfStats:
        return MaterialPageRoute(builder: (_) => ListSfStatsScreen());
      case trenSfStats:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TrenSfStatsScreen(monthKeys: args['monthKeys']),
        );
      case persalinanStats:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PersalinanStatsScreen(monthKey: args['monthKey']),
        );
      case listPersalinanStats:
        return MaterialPageRoute(builder: (_) => ListPersalinanStatsScreen());
      case trenPersalinanStats:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              TrenPersalinanStatsScreen(monthKeys: args['monthKeys']),
        );
      default:
        throw const RouteException('Route not found!');
    }
  }
}
