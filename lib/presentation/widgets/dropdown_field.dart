import 'package:flutter/material.dart';

class DropdownField extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final String? value;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;
  final bool enabled; // ✅ Tambahan

  const DropdownField({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
    this.enabled = true, // ✅ default tetap aktif
  });

  @override
  Widget build(BuildContext context) {
    print('this.items: ${this.items}');
    print('this.value: ${this.value}');
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      items: items.map((String val) {
        return DropdownMenuItem<String>(value: val, child: Text(val));
      }).toList(),
      onChanged: enabled ? onChanged : null, // ✅ kalau disabled, null
      validator: validator,
      disabledHint: value != null
          ? Text(value!)
          : const Text("Tidak tersedia"), // ✅ hint saat disable
    );
  }
}
