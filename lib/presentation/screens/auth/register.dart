import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/dropdown_field.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/state_management/auth/cubit/register_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  String _role = 'bidan';
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
    if (!_formKey.currentState!.validate() || _selectedPuskesmas == null) {
      return;
    }

    context.read<RegisterCubit>().submitForm(
      nama: _namaController.text,
      nip: _nipController.text,
      noHp: _noHpController.text,
      email: _emailController.text,
      role: _role,
      desa: _desaController.text,
      selectedPuskesmas: _selectedPuskesmas!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(
        title: "Registrasi",
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
              builder: (_) => AlertDialog(
                title: const Text('Sukses'),
                content: const Text('Bidan berhasil diregistrasi'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRouter.homepage);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else if (state is RegisterFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isSubmitting = state is RegisterSubmitting;

          return SingleChildScrollView(
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
                    label: 'NIP',
                    icon: Icons.badge,
                    controller: _nipController,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'No HP',
                    icon: Icons.phone,
                    controller: _noHpController,
                    keyboardType: TextInputType.phone,
                    validator: (val) {
                      final hp = val?.trim();
                      final pattern = RegExp(r'^(\+62|62|0)8[1-9][0-9]{7,11}$');
                      if (hp == null || hp.isEmpty) {
                        return 'Wajib diisi';
                      } else if (!pattern.hasMatch(hp)) {
                        return 'Format no HP tidak valid';
                      }
                      return null;
                    },
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
                    items: ['bidan', 'admin'].map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (val) => setState(() => _role = val!),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionTitle('Puskesmas'),
                  Autocomplete<Map<String, dynamic>>(
                    displayStringForOption: (option) => option['nama'],
                    optionsBuilder: (textEditingValue) async {
                      return await context
                          .read<RegisterCubit>()
                          .searchPuskesmas(textEditingValue.text);
                    },
                    onSelected: (option) {
                      setState(() {
                        _selectedPuskesmas = option;
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, _) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Cari Puskesmas',
                          prefixIcon: Icon(Icons.local_hospital),
                        ),
                        validator: (_) => _selectedPuskesmas == null
                            ? 'Pilih puskesmas'
                            : null,
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Desa',
                    icon: Icons.house,
                    controller: _desaController,
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSubmitting
                          ? null
                          : () => _submitForm(context),
                      icon: isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(
                        isSubmitting ? 'Menyimpan...' : 'Daftarkan Bidan',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
