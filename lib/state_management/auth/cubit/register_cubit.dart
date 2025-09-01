import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  List<Map<String, dynamic>> _puskesmasList = [];
  List<Map<String, dynamic>> get puskesmasList => _puskesmasList;

  /// Pencarian Puskesmas
  Future<void> searchPuskesmas(String query) async {
    if (query.isEmpty) {
      _puskesmasList = [];
      emit(RegisterSearchLoaded(_puskesmasList));
      return;
    }

    // pecah query ke kata per kata (bukan n-grams)
    final kataKunci = query
        .toLowerCase()
        .trim()
        .split(RegExp(r'\s+'))
        .where((k) => k.isNotEmpty)
        .toList();

    try {
      // ambil kandidat: cocok salah satu kata
      final snapshot = await FirebaseFirestore.instance
          .collection('puskesmas')
          .where('keywords', arrayContainsAny: kataKunci)
          .get();

      // mapping hasil
      final allData = snapshot.docs.map((doc) {
        final data = doc.data();
        data['ref'] = doc.reference;
        return data;
      }).toList();

      // filter: harus mengandung semua kata query
      _puskesmasList = allData.where((data) {
        final keywords = List<String>.from(data['keywords'] ?? []);
        return kataKunci.every((k) => keywords.contains(k));
      }).toList();

      emit(RegisterSearchLoaded(_puskesmasList));
    } catch (e) {
      emit(RegisterFailure('Gagal cari puskesmas: $e'));
    }
  }

  /// Submit form register
  Future<void> submitForm({
    required String nama,
    required String nip,
    required String noHp,
    required String email,
    required String role,
    required String desa,
    required Map<String, dynamic> selectedPuskesmas,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const RegisterFailure('User tidak ditemukan'));
      return;
    }

    emit(RegisterSubmitting());

    try {
      await FirebaseFirestore.instance.collection('bidan').doc(user.uid).set({
        'nama': nama,
        'nip': nip,
        'no_hp': noHp,
        'email': email,
        'role': role,
        'desa': desa,
        'created_at': FieldValue.serverTimestamp(),
        'puskesmas': selectedPuskesmas['nama'],
        'id_puskesmas': selectedPuskesmas['ref'],
        'active': true,
        'premium': false,
      });

      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}
