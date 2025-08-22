import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePickerField extends FormField<DateTime> {
  DateTimePickerField({
    super.key,
    required String labelText,
    required IconData prefixIcon,
    super.validator,
    super.onSaved,
    required BuildContext context,
  }) : super(
         builder: (FormFieldState<DateTime> field) {
           void selectDateTime() async {
             final DateTime? pickedDate = await showDatePicker(
               context: context,
               initialDate: field.value ?? DateTime.now(),
               firstDate: DateTime(2000),
               lastDate: DateTime(2101),
             );

             if (pickedDate != null) {
               final TimeOfDay? pickedTime = await showTimePicker(
                 context: context,
                 initialTime: field.value != null
                     ? TimeOfDay.fromDateTime(field.value!)
                     : TimeOfDay.now(),
               );

               if (pickedTime != null) {
                 final newDateTime = DateTime(
                   pickedDate.year,
                   pickedDate.month,
                   pickedDate.day,
                   pickedTime.hour,
                   pickedTime.minute,
                 );
                 field.didChange(newDateTime);
               }
             }
           }

           return InkWell(
             onTap: selectDateTime,
             child: InputDecorator(
               decoration: InputDecoration(
                 labelText: labelText,
                 prefixIcon: Icon(prefixIcon),
                 errorText: field.errorText,
                 border: const UnderlineInputBorder(),
               ),
               child: Text(
                 field.value == null
                     ? labelText
                     : DateFormat('dd MMMM yyyy, HH:mm').format(field.value!),
                 style: TextStyle(
                   color: field.value == null
                       ? Theme.of(context).hintColor
                       : Theme.of(context).textTheme.bodyLarge!.color,
                 ),
               ),
             ),
           );
         },
       );
}
