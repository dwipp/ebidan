import 'package:flutter/material.dart';

class DatePickerFormField extends FormField<DateTime> {
  DatePickerFormField({
    Key? key,
    required String labelText,
    required IconData prefixIcon,
    DateTime? initialValue, // ✅ bisa binding langsung
    DateTime? initialDate,
    DateTime? lastDate,
    required BuildContext context,
    required ValueChanged<DateTime> onDateSelected,
    FormFieldValidator<DateTime>? validator,
    bool readOnly = false,
  }) : super(
         key: key,
         initialValue: initialValue, // pakai value terbaru
         validator: validator,
         builder: (FormFieldState<DateTime> field) {
           return InkWell(
             onTap: readOnly
                 ? null
                 : () async {
                     final picked = await showDatePicker(
                       context: context,
                       initialDate: initialDate ?? DateTime.now(),
                       firstDate: DateTime(1960),
                       lastDate: lastDate ?? DateTime.now(),
                     );
                     if (picked != null) {
                       field.didChange(picked);
                       onDateSelected(picked);
                     }
                   },
             child: InputDecorator(
               decoration: InputDecoration(
                 labelText: labelText,
                 prefixIcon: Icon(prefixIcon),
                 errorText: field.errorText,
                 border: const UnderlineInputBorder(),
               ),
               child: Text(
                 field.value == null
                     ? 'Pilih Tanggal'
                     : '${field.value!.day}/${field.value!.month}/${field.value!.year}',
                 style: TextStyle(
                   fontSize: 16,
                   color: field.value == null
                       ? Colors.grey.shade600
                       : Colors.black,
                 ),
               ),
             ),
           );
         },
       );
}
