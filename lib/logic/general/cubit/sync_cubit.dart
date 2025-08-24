import 'package:ebidan/data/hive/bumil_hive.dart';
import 'package:ebidan/logic/utility/sync_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

part 'sync_state.dart';

class SyncCubit extends Cubit<SyncState> {
  final Box<BumilHive> addedBumilBox;
  SyncCubit({required this.addedBumilBox}) : super(SyncState.initial());

  Future<void> syncAll() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(state.copyWith(status: SyncStatus.failed, message: "login dahulu"));
      return;
    }
    emit(
      state.copyWith(
        status: SyncStatus.syncing,
        message: "Mulai sinkronisasi...",
      ),
    );

    try {
      // 1. Sync Bumil
      try {
        // final addBumil = await Hive.openBox<BumilHive>('offline_bumil');
        print('bumilBox.isNotEmpty: ${addedBumilBox.isNotEmpty}');
        if (addedBumilBox.isNotEmpty) {
          await SyncService.syncAddBumil(addedBumilBox);
          emit(state.copyWith(message: "Berhasil sync bumil"));
        }
      } catch (e) {
        emit(
          state.copyWith(
            status: SyncStatus.failed,
            message: "Gagal sync bumil: $e",
          ),
        );
        return; // hentikan sync berikutnya
      }

      // TODO: sync data lain, misalnya syncAddRiwayat, syncAddAnak, dll.
      // Prinsip sama seperti di atas:
      // - Bungkus try-catch
      // - Emit pesan berhasil jika sukses
      // - Emit status failed + pesan error jika gagal lalu return

      emit(
        state.copyWith(
          status: SyncStatus.success,
          message: "Semua data berhasil disinkronkan.",
        ),
      );
      Future.delayed(Duration(seconds: 2), () {
        emit(state.copyWith(status: SyncStatus.initial, message: "Sync"));
      });
    } catch (e) {
      emit(
        state.copyWith(
          status: SyncStatus.failed,
          message: "Sinkronisasi gagal: $e",
        ),
      );
    }
  }
}
