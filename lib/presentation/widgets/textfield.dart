import 'package:ebidan/common/utility/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function(String)? onSaved;
  final bool isNumber;
  final TextInputType? keyboardType;
  final String? suffixText;
  final Widget? suffixIcon; // ✅ tambahan
  final TextCapitalization textCapitalization;
  final TextEditingController? controller;
  final bool readOnly;
  final bool disable;
  final bool isMultiline;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    this.onSaved,
    this.isNumber = false,
    this.keyboardType,
    this.suffixText,
    this.suffixIcon, // ✅ tambahan
    this.textCapitalization = TextCapitalization.sentences,
    this.controller,
    this.readOnly = false,
    this.disable = false,
    this.isMultiline = false,
    this.validator,
    this.inputFormatters,
    this.maxLength,
  }) : assert(
         onSaved != null || controller != null,
         'Harus isi salah satu: onSaved atau controller',
       );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: isMultiline ? null : 1,
      controller: controller,
      readOnly: readOnly,
      enabled: !disable,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixText: suffixText,
        suffixIcon: suffixIcon, // ✅ aktifkan
        suffixStyle: TextStyle(
          color: context.themeColors.suffixText,
          fontSize: 16,
        ),
      ),
      maxLength: maxLength,
      keyboardType: isNumber
          ? TextInputType.number
          : keyboardType ??
                (isMultiline ? TextInputType.multiline : TextInputType.text),
      textCapitalization: isNumber
          ? TextCapitalization.none
          : textCapitalization,
      onSaved: onSaved != null ? (val) => onSaved!(val ?? '') : null,
      validator: validator,
    );
  }
}
