import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ebidan/data/models/bidan_model.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserCubit userCubit;
  ProfileCubit({required this.userCubit}) : super(ProfileInitial());

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> getProfile() async {
    emit(ProfileLoading());
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(const ProfileFailure('User belum login'));
        return;
      }

      final doc = await _firestore.collection('bidan').doc(uid).get();

      if (!doc.exists) {
        emit(const ProfileFailure('Data bidan tidak ditemukan'));
        return;
      }

      final data = doc.data()!;
      final avatar = _auth.currentUser?.photoURL;

      final bidan = Bidan.fromFirestore(data, avatar: avatar);
      userCubit.loggedInUser(bidan);

      emit(ProfileLoaded(bidan));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }
}
