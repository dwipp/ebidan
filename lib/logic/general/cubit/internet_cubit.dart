import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

part 'internet_state.dart';

class InternetCubit extends Cubit<InternetState> {
  StreamSubscription? connectivityStreamSubscription;

  InternetCubit() : super(InternetInitial()) {
    monitorInternetConnection();
  }

  StreamSubscription monitorInternetConnection() {
    return connectivityStreamSubscription =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          // The internet is now connected
          emit(InternetConnected());
          Future.delayed(
            const Duration(milliseconds: 1000),
            () {
              emit(InternetStatusDismiss());
            },
          );
          break;
        case InternetStatus.disconnected:
          // The internet is now disconnected
          emit(InternetDisconnected());
          break;
      }
    });
  }
}
