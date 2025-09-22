import 'package:flutter/material.dart';

typedef FieldValidator = String? Function(dynamic value);

class FormValidator {
  final Map<String, GlobalKey> fieldKeys;
  GlobalKey? _firstErrorFieldKey;

  FormValidator({required this.fieldKeys});

  void reset() {
    _firstErrorFieldKey = null;
  }

  /// Wrapper yang harus digunakan oleh semua FormField.
  /// Ini mencatat GlobalKey dari field pertama yang gagal validasi.
  String? wrapValidator<T>(
    String fieldName,
    T? value,
    FieldValidator validator,
  ) {
    final error = validator(value);

    // Logika pencatatan key error pertama
    if (error != null && _firstErrorFieldKey == null) {
      _firstErrorFieldKey = fieldKeys[fieldName];
    }
    return error;
  }

  /// Validasi seluruh form menggunakan FormState.validate() dan scroll ke field pertama yang error.
  bool validateAndScroll(GlobalKey<FormState> formKey, BuildContext context) {
    // 1. Reset key error sebelum validasi
    _firstErrorFieldKey = null;

    // 2. Jalankan validasi asli dari Flutter Form
    // Ini akan memicu semua wrapValidator, yang mencatat _firstErrorFieldKey.
    final isValid = formKey.currentState!.validate();

    if (!isValid && _firstErrorFieldKey?.currentContext != null) {
      // 3. Tampilkan SnackBar error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Periksa field yang belum valid 👆'),
          backgroundColor: Colors.red,
        ),
      );

      // 4. Scroll ke GlobalKey yang dicatat
      Scrollable.ensureVisible(
        _firstErrorFieldKey!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        alignment: 0.1, // Aligns slightly below the top to show label
      );
    }

    return isValid;
  }
}
