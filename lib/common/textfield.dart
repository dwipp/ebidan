import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function(String)? onSaved; // ✅ opsional
  final bool isNumber;
  final String? suffixText;
  final TextCapitalization textCapitalization;
  final TextEditingController? controller; // ✅ opsional
  final bool readOnly; // ✅ tambahkan readOnly
  final bool isMultiline; // ✅ tambahkan untuk auto grow textfield

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    this.onSaved, // ✅ tidak wajib
    this.isNumber = false,
    this.suffixText,
    this.textCapitalization = TextCapitalization.sentences,
    this.controller, // ✅ tidak wajib
    this.readOnly = false, // ✅ default false
    this.isMultiline = false, // ✅ default: single line
  }) : assert(
         onSaved != null || controller != null,
         'Harus isi salah satu: onSaved atau controller',
       );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: isMultiline ? null : 1,
      controller: controller,
      readOnly: readOnly, // ✅ aktifkan
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixText: suffixText,
      ),
      keyboardType: isNumber
          ? TextInputType.number
          : isMultiline
          ? TextInputType.multiline
          : TextInputType.text,
      textCapitalization: isNumber
          ? TextCapitalization.none
          : textCapitalization,
      onSaved: onSaved != null
          ? (val) => onSaved!(val ?? '')
          : null, // ✅ hanya dipakai kalau ada
    );
  }
}
