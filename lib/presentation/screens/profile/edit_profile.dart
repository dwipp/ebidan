import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/common/utility/form_validator.dart';
import 'package:ebidan/data/models/bidan_model.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/snack_bar.dart';
import 'package:ebidan/presentation/widgets/textfield.dart';
import 'package:ebidan/state_management/auth/cubit/register_cubit.dart';
import 'package:ebidan/state_management/auth/cubit/user_cubit.dart';
import 'package:ebidan/state_management/profile/cubit/profile_cubit.dart';
import 'package:ebidan/state_management/profile/cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _namaController = TextEditingController();

  final TextEditingController _nipController = TextEditingController();

  final TextEditingController _hpController = TextEditingController();

  final TextEditingController _puskesmasController = TextEditingController();

  final TextEditingController _desaController = TextEditingController();

  final Map<String, GlobalKey> _fieldKeys = {
    'email': GlobalKey(),
    'nip': GlobalKey(),
    'hp': GlobalKey(),
    'puskesmas': GlobalKey(),
    'desa': GlobalKey(),
    'nama': GlobalKey(),
  };

  Map<String, dynamic>? _selectedPuskesmas;

  late FormValidator _formValidator;

  @override
  void initState() {
    super.initState();
    _formValidator = FormValidator(fieldKeys: _fieldKeys);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<UserCubit>().state;
    _emailController.text = user?.email ?? '';
    _namaController.text = user?.nama ?? '';
    _nipController.text = user?.nip ?? '';
    _hpController.text = user?.noHp ?? '';
    _puskesmasController.text = user?.puskesmas ?? '';
    _desaController.text = user?.desa ?? '';
    _selectedPuskesmas?['ref'] = user?.idPuskesmas ?? '';
    _selectedPuskesmas?['nama'] = user?.puskesmas ?? '';
  }

  // Validator standar untuk wajib diisi
  String? _requiredValidator(dynamic val) {
    if (val is String) {
      return val.isEmpty ? 'Wajib diisi' : null;
    }
    return val == null ? 'Wajib dipilih' : null;
  }

  Future<void> _saveData(BuildContext context) async {
    _formValidator.reset();

    if (!_formValidator.validateAndScroll(_formKey, context)) {
      return;
    }

    final updatedBidan = MinimumBidan(
      desa: _desaController.text,
      email: _emailController.text,
      nama: _namaController.text,
      nip: _nipController.text,
      noHp: _hpController.text,
      puskesmas: _puskesmasController.text,
      idPuskesmas: _selectedPuskesmas?['ref'] as DocumentReference,
    );

    context.read<ProfileCubit>().updateProfile(updatedBidan);
  }

  @override
  Widget build(BuildContext context) {
    final cubitReg = context.read<RegisterCubit>();
    return Scaffold(
      appBar: PageHeader(title: Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                key: _fieldKeys['nama'], // Tambahkan key
                controller: _namaController,
                label: "Nama",
                icon: Icons.person,
                validator: (val) => _formValidator.wrapValidator(
                  'nama',
                  val,
                  _requiredValidator,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['email'], // Tambahkan key
                controller: _emailController,
                label: "Email",
                icon: Icons.email,
                validator: (val) => _formValidator.wrapValidator(
                  'email',
                  val,
                  _requiredValidator,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['nip'], // Tambahkan key
                controller: _nipController,
                label: "NIP",
                icon: Icons.badge,
                validator: (val) => _formValidator.wrapValidator(
                  'nip',
                  val,
                  _requiredValidator,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['hp'], // Tambahkan key
                controller: _hpController,
                label: "Nomor HP",
                icon: Icons.phone,
                validator: (val) =>
                    _formValidator.wrapValidator('hp', val, _requiredValidator),
              ),
              const SizedBox(height: 12),
              Autocomplete<Map<String, dynamic>>(
                displayStringForOption: (option) =>
                    option['nama'], // tetap simpan nama saja untuk hasil pilihan
                optionsBuilder: (textEditingValue) async {
                  await cubitReg.searchPuskesmas(textEditingValue.text);
                  return cubitReg.puskesmasList;
                },
                onSelected: (option) {
                  setState(() {
                    _selectedPuskesmas = option;
                    _puskesmasController.text = option['nama'];
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, _) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_puskesmasController.text.isNotEmpty &&
                        controller.text != _puskesmasController.text) {
                      controller.text = _puskesmasController.text;
                    }
                  });
                  focusNode.addListener(() {
                    if (focusNode.hasFocus) {
                      Future.delayed(Duration(milliseconds: 300), () {
                        Scrollable.ensureVisible(
                          focusNode.context!,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      });
                    }
                  });
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Puskesmas',
                      prefixIcon: Icon(Icons.local_hospital),
                    ),
                    validator: (_) =>
                        _selectedPuskesmas == null ? 'Pilih puskesmas' : null,
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      child: SizedBox(
                        height: 200,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              title: Text(
                                option['nama'],
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                '${option['kecamatan'] ?? ''}, ${option['kabupaten'] ?? ''}, ${option['provinsi'] ?? ''}',
                              ),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                key: _fieldKeys['desa'], // Tambahkan key
                controller: _desaController,
                label: "Desa",
                icon: Icons.location_on,
                validator: (val) => _formValidator.wrapValidator(
                  'desa',
                  val,
                  _requiredValidator,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: BlocConsumer<ProfileCubit, ProfileState>(
                  listener: (context, state) {
                    if (state is ProfileLoaded) {
                      Snackbar.show(
                        context,
                        message: 'Profile berhasil diperbaharui',
                        type: SnackbarType.success,
                      );
                      Navigator.pop(context);
                    } else if (state is ProfileFailure) {
                      Snackbar.show(
                        context,
                        message: 'Gagal: ${state.message}',
                        type: SnackbarType.error,
                      );
                    }
                  },
                  builder: (context, state) {
                    var isSubmitting = false;
                    if (state is ProfileLoading) {
                      isSubmitting = true;
                    }
                    return Button(
                      isSubmitting: isSubmitting,
                      onPressed: () => _saveData(context),
                      label: 'Perbaharui',
                      icon: Icons.check,
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
