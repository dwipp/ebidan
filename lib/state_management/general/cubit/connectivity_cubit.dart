import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final InternetConnection _connectionChecker;
  late final Stream<InternetStatus> _listener;

  ConnectivityCubit({InternetConnection? connectionChecker})
    : _connectionChecker = connectionChecker ?? InternetConnection(),
      super(const ConnectivityState.initial()) {
    // mulai listen status perubahan
    _listener = _connectionChecker.onStatusChange;
    _listener.listen((status) {
      final connected = status == InternetStatus.connected;
      emit(ConnectivityState(connected: connected));
    });
  }

  /// cek status sekali (misal dipanggil saat user masuk home)
  Future<void> checkNow() async {
    final hasInternet = await _connectionChecker.hasInternetAccess;
    emit(ConnectivityState(connected: hasInternet));
  }
}
