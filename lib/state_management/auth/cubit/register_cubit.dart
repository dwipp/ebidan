import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  Future<List<Map<String, dynamic>>> searchPuskesmas(String query) async {
    if (query.isEmpty) return [];
    final kataKunci = query
        .toLowerCase()
        .split(' ')
        .where((kata) => kata.trim().isNotEmpty)
        .toList();

    final snapshot = await FirebaseFirestore.instance
        .collection('puskesmas')
        .where('keywords', arrayContainsAny: kataKunci)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['ref'] = doc.reference;
      return data;
    }).toList();
  }

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
        'created_at': FieldValue.serverTimestamp(),
        'puskesmas': selectedPuskesmas['nama'],
        'id_puskesmas': selectedPuskesmas['ref'],
        'active': true,
        'premium': false,
        'desa': desa,
      });

      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}
