import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/bidan_model.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:ebidan/state_management/general/cubit/connectivity_cubit.dart';
import 'package:equatable/equatable.dart';

part 'get_bidan_state.dart';

class GetBidanCubit extends Cubit<GetBidanState> {
  final UserCubit user;
  GetBidanCubit({required this.user}) : super(GetBidanState.initial());

  Future<void> fetchBidanList(ConnectivityState connectivity) async {
    final firestore = FirebaseFirestore.instance;

    if (connectivity.connected) {
      emit(GetBidanLoading(bidanList: state.bidanList));
    } else {
      emit(state.copyWith(bidanList: state.bidanList));
    }

    final bidanIds = user.state?.bidanIds ?? [];
    if (bidanIds.isEmpty) {
      emit(state.copyWith(bidanList: []));
      return;
    }

    try {
      final List<Bidan> bidanList = [];
      const int batchSize = 10; // Batas maksimal untuk query 'whereIn'

      // 4. Loop untuk memecah ID menjadi batch-batch kecil
      for (int i = 0; i < bidanIds.length; i += batchSize) {
        final end = (i + batchSize < bidanIds.length)
            ? i + batchSize
            : bidanIds.length;
        final batch = bidanIds.sublist(i, end);

        // 5. Lakukan query untuk setiap batch
        final querySnapshot = await firestore
            .collection('bidan')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        // 6. Ubah setiap dokumen menjadi objek Bidan dan tambahkan ke list
        final bidans = querySnapshot.docs
            .map((doc) => Bidan.fromFirestore(doc.data(), avatar: ''))
            .toList();

        bidanList.addAll(bidans);
      }
      emit(GetBidanState(bidanList: bidanList));
    } catch (e) {
      emit(
        state.copyWith(
          bidanList: [],
          error: e is Exception
              ? e.toString().replaceAll('Exception: ', '')
              : 'Terjadi kesalahan. Mohon coba kembali.',
        ),
      );
    }
  }
}
