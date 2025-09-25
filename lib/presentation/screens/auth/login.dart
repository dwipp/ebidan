import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/state_management/auth/cubit/login_cubit.dart';
import 'package:ebidan/state_management/general/cubit/back_press_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../router/app_router.dart';
import '../../widgets/page_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final allowExit = context.read<BackPressCubit>().onBackPressed();
        if (!allowExit) {
          Snackbar.show(context, message: 'Tekan sekali lagi untuk keluar');
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: const PageHeader(title: 'Login eBidan', hideBackButton: true),
        body: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              final isRegistered = state.isRegistered;

              if (isRegistered) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.homepage,
                  (route) => false,
                );
              } else {
                Navigator.of(context).pushReplacementNamed(AppRouter.register);
              }
            } else if (state is LoginFailure) {
              Snackbar.show(
                context,
                message: state.message,
                type: SnackbarType.error,
              );
            }
          },
          builder: (context, state) {
            final user = FirebaseAuth.instance.currentUser;

            if (state is LoginLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (user == null) {
              return Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                  onPressed: () {
                    context.read<LoginCubit>().signInWithGoogle();
                  },
                ),
              );
            }

            return Center(
              child: Column(
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
                    onPressed: () {
                      context.read<LoginCubit>().signOut();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
