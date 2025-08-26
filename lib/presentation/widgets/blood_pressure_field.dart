import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BloodPressureField extends StatefulWidget {
  const BloodPressureField({
    super.key,
    this.controller,
    this.label = "Tekanan Darah",
    this.hint = "120/80",
    this.minSistolik = 40,
    this.maxSistolik = 300,
    this.minDiastolik = 30,
    this.maxDiastolik = 200,
    this.validator, // optional override
  });

  final TextEditingController? controller;
  final String label;
  final String hint;
  final int minSistolik;
  final int maxSistolik;
  final int minDiastolik;
  final int maxDiastolik;
  final String? Function(String?)? validator;

  @override
  State<BloodPressureField> createState() => _BloodPressureFieldState();
}

class _BloodPressureFieldState extends State<BloodPressureField> {
  late final TextEditingController _c;
  bool _internalChange = false;
  String _lastText = "";

  @override
  void initState() {
    super.initState();
    _c = widget.controller ?? TextEditingController();
    _lastText = _c.text;
    _c.addListener(_handleChange);
  }

  @override
  void dispose() {
    _c.removeListener(_handleChange);
    if (widget.controller == null) _c.dispose();
    super.dispose();
  }

  void _handleChange() {
    if (_internalChange) return;

    final currentText = _c.text;
    final selection = _c.selection;
    final cursorPos = selection.baseOffset;

    String text = currentText.replaceAll(' ', '');
    final slashIndex = text.indexOf('/');

    // Auto tambahkan "/" setelah sistolik valid
    if (slashIndex == -1 && text.isNotEmpty) {
      final systolic = int.tryParse(text);
      if (systolic != null &&
          systolic >= widget.minSistolik &&
          systolic <= widget.maxSistolik) {
        _internalChange = true;
        _c.text = "$systolic/";
        _c.selection = TextSelection.collapsed(offset: _c.text.length);
        _internalChange = false;
      }
    }

    // Tangani penghapusan
    if (_lastText.length > text.length) {
      // Ada penghapusan
      final lastSlashIndex = _lastText.indexOf('/');

      if (lastSlashIndex != -1) {
        if (cursorPos == lastSlashIndex + 1) {
          // Jika cursor tepat setelah '/', hapus '/' + 1 angka sebelum '/'
          final newText =
              _lastText.substring(0, lastSlashIndex - 1) +
              _lastText.substring(lastSlashIndex + 1);
          _internalChange = true;
          _c.text = newText;
          _c.selection = TextSelection.collapsed(offset: lastSlashIndex - 1);
          _internalChange = false;
        } else if (cursorPos > lastSlashIndex + 1) {
          // Cursor di bagian diastolik → hapus karakter di diastolik
          final diastolicPart = text.substring(lastSlashIndex + 1);
          if (diastolicPart.isNotEmpty) {
            final newDiastolic = diastolicPart.substring(
              0,
              diastolicPart.length - 1,
            );
            _internalChange = true;
            _c.text = text.substring(0, lastSlashIndex + 1) + newDiastolic;
            _c.selection = TextSelection.collapsed(
              offset: lastSlashIndex + 1 + newDiastolic.length,
            );
            _internalChange = false;
          }
        } else if (cursorPos <= lastSlashIndex) {
          // Cursor di bagian sistolik → hapus karakter sistolik
          final systolicPart = text.substring(0, lastSlashIndex);
          if (systolicPart.isNotEmpty) {
            final newSystolic = systolicPart.substring(
              0,
              systolicPart.length - 1,
            );
            _internalChange = true;
            _c.text = newSystolic + text.substring(lastSlashIndex);
            _c.selection = TextSelection.collapsed(offset: newSystolic.length);
            _internalChange = false;
          }
        }
      }
    }

    _lastText = _c.text;
  }

  String? _defaultValidator(String? value) {
    final v = (value ?? '').trim();
    final m = RegExp(r'^(\d{2,3})/(\d{2,3})$').firstMatch(v);
    if (m == null) return 'Gunakan format ${widget.hint}';
    final sys = int.parse(m.group(1)!);
    final dia = int.parse(m.group(2)!);
    if (sys < widget.minSistolik || sys > widget.maxSistolik) {
      return 'Sistolik ${widget.minSistolik}-${widget.maxSistolik} mmHg';
    }
    if (dia < widget.minDiastolik || dia > widget.maxDiastolik) {
      return 'Diastolik ${widget.minDiastolik}-${widget.maxDiastolik} mmHg';
    }
    if (sys <= dia) return 'Sistolik harus > diastolik';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _c,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(/?\d{0,3})?$')),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        hintStyle: TextStyle(color: Colors.black26),
        prefixIcon: const Icon(Icons.bloodtype),
        suffixText: "mmHg",
        suffixStyle: TextStyle(color: Colors.black54, fontSize: 16),
      ),
      validator: widget.validator ?? _defaultValidator,
    );
  }
}
