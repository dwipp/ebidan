import 'package:bloc/bloc.dart';
import 'package:ebidan/data/models/bidan_model.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final UserCubit user;
  RegisterCubit({required this.user}) : super(RegisterInitial());

  List<Map<String, dynamic>> _puskesmasList = [];
  List<Map<String, dynamic>> get puskesmasList => _puskesmasList;

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    final v0 = List<int>.generate(t.length + 1, (i) => i);
    final v1 = List<int>.filled(t.length + 1, 0);

    for (var i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (var j = 0; j < t.length; j++) {
        final cost = s[i] == t[j] ? 0 : 1;
        v1[j + 1] = [
          v1[j] + 1,
          v0[j + 1] + 1,
          v0[j] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
      for (var j = 0; j <= t.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[t.length];
  }

  /// cek apakah dua string mirip dengan toleransi `maxDistance`
  bool _isFuzzyMatch(String a, String b, {int maxDistance = 1}) {
    return _levenshtein(a.toLowerCase(), b.toLowerCase()) <= maxDistance;
  }

  Future<void> searchPuskesmas(String query) async {
    final cleanedQuery = query
        .toLowerCase()
        .replaceAll(RegExp(r'\bpuskesmas\b', caseSensitive: false), '')
        .trim();

    final kataKunci = cleanedQuery
        .toLowerCase()
        .trim()
        .split(RegExp(r'\s+'))
        .where((k) => k.isNotEmpty)
        .toList();

    if (kataKunci.isEmpty) {
      _puskesmasList = [];
      emit(RegisterSearchLoaded(_puskesmasList));
      return;
    }

    try {
      // ambil kandidat dari Firestore (cocok salah satu kata)
      final snapshot = await FirebaseFirestore.instance
          .collection('puskesmas')
          .where('keywords', arrayContainsAny: kataKunci)
          .limit(200)
          .get();

      final allData = snapshot.docs.map((doc) {
        final data = doc.data();
        data['ref'] = doc.reference;
        return data;
      }).toList();

      // filter di client: semua kata harus cocok (exact atau typo <= 1 huruf)
      _puskesmasList = allData.where((data) {
        final keywords = List<String>.from(data['keywords'] ?? []);
        return kataKunci.every(
          (q) => keywords.any(
            (k) => k == q || _isFuzzyMatch(k, q, maxDistance: 1),
          ),
        );
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
    final auth = FirebaseAuth.instance.currentUser;
    if (auth == null) {
      emit(const RegisterFailure('User tidak ditemukan'));
      return;
    }

    emit(RegisterSubmitting());

    try {
      final puskesmasRef = selectedPuskesmas['ref'] as DocumentReference;
      final bidan = Bidan(
        photoUrl: auth.photoURL,
        active: true,
        createdAt: DateTime.now(),
        desa: desa,
        email: email,
        idPuskesmas: puskesmasRef.path,
        nama: nama,
        nip: nip,
        noHp: noHp,
        puskesmas: selectedPuskesmas['nama'],
        role: role,
        subscription: Subscription(),
        trial: Trial(
          expiryDate: DateTime.now().add(const Duration(days: 30)),
          startDate: DateTime.now(),
          used: true,
        ),
      );
      await FirebaseFirestore.instance
          .collection('bidan')
          .doc(auth.uid)
          .set(bidan.toFirestore());
      user.loggedInUser(bidan);

      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}

class requried {}
