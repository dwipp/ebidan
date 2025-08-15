import 'package:flutter/material.dart';

class DatePickerFormField extends FormField<DateTime> {
  DatePickerFormField({
    Key? key,
    required String labelText,
    required IconData prefixIcon,
    DateTime? initialValue,
    required BuildContext context,
    required ValueChanged<DateTime> onDateSelected,
    FormFieldValidator<DateTime>? validator,
  }) : super(
         key: key,
         initialValue: initialValue,
         validator: validator,
         builder: (FormFieldState<DateTime> field) {
           return InkWell(
             onTap: () async {
               final picked = await showDatePicker(
                 context: context,
                 initialDate: DateTime(1990),
                 firstDate: DateTime(1960),
                 lastDate: DateTime.now(),
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
