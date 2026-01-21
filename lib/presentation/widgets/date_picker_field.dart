import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/common/utility/app_colors.dart';
import 'package:flutter/material.dart';

class DatePickerFormField extends FormField<DateTime> {
  DatePickerFormField({
    Key? key,
    required String labelText,
    required IconData prefixIcon,
    required DateTime? value,
    DateTime? initialDate,
    DateTime? lastDate,
    required BuildContext context,
    required ValueChanged<DateTime> onDateSelected,
    FormFieldValidator<DateTime>? validator,
    bool readOnly = false,
  }) : super(
         key: key,
         initialValue: value,
         validator: validator,
         builder: (field) {
           return InkWell(
             onTap: readOnly
                 ? null
                 : () async {
                     final picked = await showDatePicker(
                       context: context,
                       initialDate:
                           field.value ?? initialDate ?? DateTime.now(),
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
                     : Utils.formattedDate(field.value),
                 style: TextStyle(
                   fontSize: 16,
                   color: field.value == null
                       ? context.themeColors.hintText
                       : context.themeColors.onSurface,
                 ),
               ),
             ),
           );
         },
       );

  @override
  FormFieldState<DateTime> createState() => _DatePickerFormFieldState();
}

class _DatePickerFormFieldState extends FormFieldState<DateTime> {
  @override
  void didUpdateWidget(covariant DatePickerFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newValue = widget.initialValue;

    if (newValue != value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          didChange(newValue);
        }
      });
    }
  }
}
