import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(); // inisialisasi wajib untuk v7
      setState(() => _initialized = true);
    } catch (e) {
      debugPrint('GoogleSignIn init failed: $e');
    }
  }

  Future<UserCredential?> _signInWithGoogle() async {
    if (!_initialized) await _initGoogleSignIn();
    setState(() => _isLoading = true);

    try {
      // Proses autentikasi
      final account = await _googleSignIn.authenticate(scopeHint: ['email']);
      // Get authorization for Firebase scopes if needed
      final authClient = _googleSignIn.authorizationClient;
      final authorization = await authClient.authorizationForScopes(['email']);

      final googleAuth = account.authentication; // sekarang sinkron

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      debugPrint('GoogleSignInException: ${e.code.name} - ${e.description}');
    } catch (e) {
      debugPrint('Google Sign-In failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    return null;
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
    setState(() {}); // agar UI refresh
  }

  Future<bool> checkBidanExists() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false; // user belum login

    final doc = await FirebaseFirestore.instance
        .collection('bidan')
        .doc(uid)
        .get();
    print('statu: ${doc.exists}');
    return doc.exists; // true jika dokumen ditemukan
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: PageHeader(title: 'Login with Google'),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : !_initialized
            ? const Text('Initializing...')
            : user == null
            ? ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
                onPressed: () async {
                  final cred = await _signInWithGoogle();
                  if (cred?.user != null) {
                    // cek apakah data bidan sudah ada di firestore.
                    // jika belum, masuk ke register
                    // jika sudah, masuk ke home
                    final isReg = await checkBidanExists();
                    var text = 'Hi, ${cred!.user!.displayName}';
                    if (isReg) {
                      // masuk ke home
                      text = 'Hi, bidan ${cred.user!.displayName}';
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRouter.homepage);
                    } else {
                      // masuk ke register
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRouter.register);
                    }
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(text)));
                  }
                },
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user.photoURL != null)
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(user.photoURL!),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    user.displayName ?? 'User',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    onPressed: _signOut,
                  ),
                ],
              ),
      ),
    );
  }
}
