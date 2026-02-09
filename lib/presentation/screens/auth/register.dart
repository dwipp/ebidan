import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/state_management/auth/cubit/register_cubit.dart';
import 'package:ebidan/state_management/general/cubit/back_press_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nipController = TextEditingController();
  final _noHpController = TextEditingController();
  final _emailController = TextEditingController();
  final _desaController = TextEditingController();
  final _namaPraktikController = TextEditingController();
  final _alamatPraktikController = TextEditingController();
  final _puskesmasTextController = TextEditingController();

  final _scrollController = ScrollController();

  String _role = 'Bidan';
  String _bidanKind = 'Bidan Desa';
  Map<String, dynamic>? _selectedPuskesmas;

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _namaController.text = user!.displayName ?? '';
      _noHpController.text = user!.phoneNumber ?? '';
      _emailController.text = user!.email ?? '';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _puskesmasTextController.dispose();
    _desaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _nipController.dispose();
    _namaController.dispose();
    _namaPraktikController.dispose();
    _alamatPraktikController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // if ((_isKoordinator() || _isBidanDesa()) && _selectedPuskesmas == null) {
    //   return;
    // }

    context.read<RegisterCubit>().submitForm(
      nama: _namaController.text,
      nip: _nipController.text,
      noHp: _noHpController.text,
      email: _emailController.text,
      role: _role,
      desa: _desaController.text,
      selectedPuskesmas: _selectedPuskesmas,
      bidanKind: _bidanKind,
      namaPraktik: _namaPraktikController.text,
      alamatPraktik: _alamatPraktikController.text,
    );
  }

  bool _isKoordinator() {
    return _role.toLowerCase() == 'koordinator';
  }

  bool _isBidanDesa() {
    if (_role.toLowerCase() == 'bidan' &&
        _bidanKind.toLowerCase() == 'bidan desa') {
      return true;
    } else {
      return false;
    }
  }

  String _getKategori() {
    if (_role.toLowerCase() == 'koordinator') {
      return _role;
    } else {
      return _bidanKind;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final allowExit = context.read<BackPressCubit>().onBackPressed();
        if (!allowExit) {
          Snackbar.show(context, message: 'Tekan sekali lagi untuk keluar');
        } else {
          await FirebaseAuth.instance.signOut();
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: PageHeader(
          title: Text("Tentukan Role Anda"),
          hideBackButton: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
        body: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => PopScope(
                  canPop: false,
                  child: AlertDialog(
                    title: const Text('Mulai dari 1 Data Ibu Hamil'),
                    content: const Text(
                      'Data ini akan menjadi dasar pembuatan laporan otomatis Anda.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pushNamed(
                            context,
                            AppRouter.addBumil,
                            arguments: {'fromReg': true},
                          ).then((_) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRouter.homepage,
                              (route) => false,
                            );
                          });
                        },
                        child: const Text('Tambah Ibu Hamil'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is RegisterFailure) {
              Snackbar.show(
                context,
                message: state.message,
                type: SnackbarType.error,
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is RegisterSubmitting;

            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (user?.photoURL != null)
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(user!.photoURL!),
                      ),
                    const SizedBox(height: 12),
                    _buildSectionTitle('Data Pribadi'),
                    CustomTextField(
                      label: 'Nama Lengkap',
                      icon: Icons.person,
                      controller: _namaController,
                      textCapitalization: TextCapitalization.words,
                      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Email',
                      icon: Icons.email,
                      controller: _emailController,
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                    ),

                    const SizedBox(height: 16),
                    _buildSectionTitle('Role'),
                    DropdownButtonFormField<String>(
                      value: _role,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.assignment_ind),
                      ),
                      items: ['Bidan'].map((role) {
                        //, 'Koordinator'
                        return DropdownMenuItem(value: role, child: Text(role));
                      }).toList(),
                      onChanged: (val) => setState(() => _role = val!),
                    ),

                    if (_role.toLowerCase() == 'bidan') ...[
                      const SizedBox(height: 16),
                      _buildSectionTitle('Kategori Bidan'),
                      DropdownButtonFormField<String>(
                        value: _bidanKind,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.assignment_ind),
                        ),
                        items: ['Bidan Desa', 'Praktik Mandiri Bidan'].map((
                          role,
                        ) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _bidanKind = val!),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: Button(
                        isSubmitting: isSubmitting,
                        onPressed: () => _submitForm(context),
                        label: 'Simpan',
                        loadingLabel: 'Menyimpan...',
                        icon: Icons.check,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
