import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/common/utility/remote_config_helper.dart';
import 'package:ebidan/data/models/bidan_model.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final UserCubit user;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;

  LoginCubit({required this.user}) : super(LoginInitial());

  Future<void> initGoogleSignIn() async {
    if (_initialized) return;
    try {
      await _googleSignIn.initialize();
      _initialized = true;
    } catch (e) {
      emit(const LoginFailure('GoogleSignIn init failed'));
    }
  }

  Future<void> signInWithGoogle() async {
    await initGoogleSignIn();
    emit(LoginLoading());
    try {
      final account = await _googleSignIn.authenticate(scopeHint: ['email']);
      final authClient = _googleSignIn.authorizationClient;
      final authorization = await authClient.authorizationForScopes(['email']);

      final googleAuth = await account.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final auth = userCred.user;
      if (auth == null) {
        emit(const LoginFailure('User not found'));
        return;
      }

      // cek apakah bidan sudah terdaftar
      final doc = await _firestore.collection('bidan').doc(auth.uid).get();
      final isReg = doc.exists;

      // set user yang login di cubit
      if (isReg) {
        user.loggedInUser(
          Bidan.fromFirestore(doc.data()!, avatar: auth.photoURL),
        );
      }

      emit(LoginSuccess(auth, isReg));
    } on GoogleSignInException catch (e) {
      emit(LoginFailure('${e.code.name} - ${e.description}'));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> signInForReviewer() async {
    final userCred = await _auth.signInWithEmailAndPassword(
      email: RemoteConfigHelper.reviewerEmail,
      password: RemoteConfigHelper.reviewerPass,
    );
    final auth = userCred.user;
    if (auth == null) {
      emit(const LoginFailure('User not found'));
      return;
    }
    // cek apakah bidan sudah terdaftar
    final doc = await _firestore.collection('bidan').doc(auth.uid).get();
    final isReg = doc.exists;

    // set user yang login di cubit
    if (isReg) {
      user.loggedInUser(
        Bidan.fromFirestore(doc.data()!, avatar: auth.photoURL),
      );
    }

    emit(LoginSuccess(auth, isReg));
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    user.clear();
    emit(LogoutSuccess());
  }
}
