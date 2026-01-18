import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/ktp_camera.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/check_bumil_cubit.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ktp_extractor/models/ktp_model.dart';

class CheckBumilScreen extends StatefulWidget {
  const CheckBumilScreen({Key? key}) : super(key: key);

  @override
  State<CheckBumilScreen> createState() => _CheckBumilScreenState();
}

class _CheckBumilScreenState extends State<CheckBumilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  KtpModel? _ktp;

  @override
  void initState() {
    super.initState();
    context.read<CheckBumilCubit>().reset();
    _nikController.addListener(() {
      context.read<CheckBumilCubit>().reset();
    });
  }

  @override
  void dispose() {
    _nikController.dispose();
    super.dispose();
  }

  String? _validateNIK(String? val) {
    if (val == null || val.isEmpty) return 'Wajib diisi';
    if (!RegExp(r'^\d{16}$').hasMatch(val)) return 'Harus 16 digit angka';
    return null;
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<CheckBumilCubit>().checkNIK(_nikController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title: Text('Cek Pasien')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan NIK Ibu untuk pengecekan:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'NIK Ibu',
                icon: Icons.badge,
                controller: _nikController,
                isNumber: true,
                maxLength: 16,
                suffixIcon: IconButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KtpCameraScreen(
                          onCaptured: (KtpModel ktp) async {
                            _ktp = ktp;
                            setState(() {
                              _nikController.text = ktp.nik ?? '';
                            });
                          },
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.camera),
                ),
                validator: _validateNIK,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: BlocConsumer<CheckBumilCubit, CheckBumilState>(
                  listener: (context, state) {
                    if (state is CheckBumilError) {
                      Snackbar.show(
                        context,
                        message: state.message,
                        type: SnackbarType.error,
                      );
                    }

                    if (state is CheckBumilNotFound) {
                      Snackbar.show(
                        context,
                        message: 'Silahkan tambah pasien baru...',
                        type: SnackbarType.general,
                      );
                      Navigator.pushReplacementNamed(
                        context,
                        AppRouter.addBumil,
                        arguments: {'nikIbu': _nikController.text, 'ktp': _ktp},
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is CheckBumilFound) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pasien telah terdaftar dengan nama: \n${state.nama}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: Button(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRouter.addKehamilan,
                                );
                              },
                              label: 'Tambah Kehamilan Baru',
                              icon: Icons.add,
                              isSubmitting: false,
                            ),
                          ),
                        ],
                      );
                    }

                    var isSubmitting = false;
                    if (state is CheckBumilLoading) {
                      isSubmitting = true;
                    }
                    // default: initial
                    return Button(
                      onPressed: () => _onSubmit(context),
                      label: 'Cek Pasien',
                      icon: Icons.search,
                      isSubmitting: isSubmitting,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
