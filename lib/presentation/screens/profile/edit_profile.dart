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

  final TextEditingController _namaPraktikController = TextEditingController();

  final TextEditingController _alamatPraktikController =
      TextEditingController();

  final Map<String, GlobalKey> _fieldKeys = {
    'email': GlobalKey(),
    'nip': GlobalKey(),
    'hp': GlobalKey(),
    'puskesmas': GlobalKey(),
    'desa': GlobalKey(),
    'nama': GlobalKey(),
    'nama_praktik': GlobalKey(),
    'alamt_praktik': GlobalKey(),
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
    _selectedPuskesmas = {'ref': user?.idPuskesmas, 'nama': user?.puskesmas};
    _namaPraktikController.text = user?.namaPraktik ?? '';
    _alamatPraktikController.text = user?.alamatPraktik ?? '';
  }

  // Validator standar untuk wajib diisi
  String? _requiredValidator(dynamic val, {bool condition = true}) {
    // kalau kondisi tidak terpenuhi → tidak melakukan validasi
    if (!condition) return null;
    if (val is String) {
      return val.trim().isEmpty ? 'Wajib diisi' : null;
    }
    return val == null ? 'Wajib dipilih' : null;
  }

  String? wrapValidatorr(
    String fieldName,
    dynamic val,
    String? Function(dynamic, {bool condition}) validator, {
    bool condition = true,
  }) {
    return validator(val, condition: condition);
  }

  Future<void> _saveData(BuildContext context) async {
    _formValidator.reset();

    if (!_formValidator.validateAndScroll(_formKey, context)) {
      return;
    }
    final ref = _selectedPuskesmas?['ref'];

    final updatedBidan = MinimumBidan(
      desa: _desaController.text,
      email: _emailController.text,
      nama: _namaController.text,
      nip: _nipController.text,
      noHp: _hpController.text,
      puskesmas: _puskesmasController.text,
      idPuskesmas: ref is DocumentReference ? ref : null,
      namaPraktik: _namaPraktikController.text,
      alamatPraktik: _alamatPraktikController.text,
    );

    context.read<ProfileCubit>().updateProfile(updatedBidan);
  }

  @override
  void dispose() {
    super.dispose();
    _desaController.dispose();
    _emailController.dispose();
    _namaController.dispose();
    _nipController.dispose();
    _hpController.dispose();
    _puskesmasController.dispose();
    _namaPraktikController.dispose();
    _alamatPraktikController.dispose();
  }

  bool _isKoordinator(Bidan? user) {
    return user?.role.toLowerCase() == 'koordinator';
  }

  bool _isBidanDesa(Bidan? user) {
    if (user?.role.toLowerCase() == 'bidan' &&
        user?.kategoriBidan?.toLowerCase() == 'bidan desa') {
      return true;
    } else {
      return false;
    }
  }

  bool _isBPM(Bidan? user) {
    if (user?.role.toLowerCase() == 'bidan' &&
        user?.kategoriBidan?.toLowerCase() == 'praktik mandiri bidan') {
      return true;
    } else {
      return false;
    }
  }

  // String _getKategori(Bidan? user) {
  //   if (user?.role.toLowerCase() == 'koordinator') {
  //     return user!.role;
  //   } else {
  //     return user?.kategoriBidan ?? user!.role;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final cubitReg = context.read<RegisterCubit>();
    final user = context.read<UserCubit>().state;
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
                key: _fieldKeys['hp'], // Tambahkan key
                controller: _hpController,
                label: "Nomor HP",
                icon: Icons.phone,
                validator: (val) =>
                    _formValidator.wrapValidator('hp', val, _requiredValidator),
              ),
              if (user?.kategoriBidan?.toLowerCase() == 'bidan desa' ||
                  user?.role.toLowerCase() == 'koordinator') ...[
                const SizedBox(height: 12),
                CustomTextField(
                  key: _fieldKeys['nip'], // Tambahkan key
                  controller: _nipController,
                  label: "NIP",
                  icon: Icons.badge,
                  validator: (val) => _formValidator.wrapValidator(
                    'nip',
                    val,
                    (value) => _requiredValidator(
                      value,
                      condition: _isBidanDesa(user!),
                    ),
                  ),
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
                    print('puskesmas: ${_selectedPuskesmas?['nama']}');
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Puskesmas',
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                      validator: (_) =>
                          (_isKoordinator(user!) || _isBidanDesa(user)) &&
                              _selectedPuskesmas == null
                          ? 'Pilih puskesmas'
                          : null,
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
                if (user?.role.toLowerCase() == 'bidan') ...[
                  const SizedBox(height: 12),
                  CustomTextField(
                    key: _fieldKeys['desa'], // Tambahkan key
                    controller: _desaController,
                    label: "Desa",
                    icon: Icons.location_on,
                    validator: (val) => _formValidator.wrapValidator(
                      'desa',
                      val,
                      (value) => _requiredValidator(
                        value,
                        condition: _isBidanDesa(user!),
                      ),
                    ),
                  ),
                ],
              ] else ...[
                const SizedBox(height: 12),
                CustomTextField(
                  key: _fieldKeys['nama_praktik'], // Tambahkan key
                  controller: _namaPraktikController,
                  label: "Nama Praktik",
                  icon: Icons.house_sharp,
                  validator: (val) => _formValidator.wrapValidator(
                    'nama_praktik',
                    val,
                    (value) =>
                        _requiredValidator(value, condition: _isBPM(user!)),
                  ),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  key: _fieldKeys['alamat_praktik'], // Tambahkan key
                  controller: _alamatPraktikController,
                  label: "Alamat Praktik",
                  icon: Icons.near_me,
                ),
              ],

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
