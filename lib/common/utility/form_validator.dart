import 'package:flutter/material.dart';

typedef FieldValidator = String? Function(dynamic value);

class FormValidator {
  final Map<String, GlobalKey> fieldKeys;
  // **Hapus Map 'validators' di sini.** Validator harus didefinisikan di FormField
  // dan dibungkus oleh FormValidator.wrapValidator.

  GlobalKey? _firstErrorFieldKey;

  // Anda hanya perlu fieldKeys di konstruktor
  FormValidator({required this.fieldKeys});

  void reset() {
    _firstErrorFieldKey = null;
  }

  // Wrapper yang harus digunakan oleh semua FormField
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
  /// CATATAN: Semua FormField HARUS menggunakan FormValidator.wrapValidator.
  bool validateAndScroll(GlobalKey<FormState> formKey, BuildContext context) {
    // 1. Reset key error sebelum validasi
    _firstErrorFieldKey = null;

    // 2. Jalankan validasi asli dari Flutter Form
    // Semua field akan memanggil wrapValidator, yang akan mencatat _firstErrorFieldKey.
    final isValid = formKey.currentState!.validate();

    if (!isValid && _firstErrorFieldKey?.currentContext != null) {
      // 3. Scroll ke GlobalKey yang dicatat oleh wrapValidator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Periksa field yang belum valid 👆'),
          backgroundColor: Colors.red,
        ),
      );

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
