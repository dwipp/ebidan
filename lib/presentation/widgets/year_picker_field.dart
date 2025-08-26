import 'package:flutter/material.dart';

class YearPickerField extends StatelessWidget {
  final BuildContext contextField;
  final String label;
  final IconData icon;
  final String initialYear;
  final Function(String) onSaved;

  const YearPickerField({
    Key? key,
    required this.contextField,
    required this.label,
    required this.icon,
    required this.initialYear,
    required this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialYear);

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      readOnly: true,
      validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
      onTap: () async {
        final currentYear = DateTime.now().year;
        const minYear = 1900;
        int tempSelectedYear = initialYear.isNotEmpty
            ? int.tryParse(initialYear) ?? currentYear
            : currentYear;

        await showDialog(
          context: contextField,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  title: const Text('Pilih Tahun'),
                  content: SizedBox(
                    height: 200,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 50,
                      onSelectedItemChanged: (index) {
                        setStateDialog(() {
                          tempSelectedYear = currentYear - index;
                        });
                      },
                      physics: const FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: currentYear - minYear + 1,
                        builder: (context, index) {
                          final year = currentYear - index;
                          final isSelected = year == tempSelectedYear;

                          return Container(
                            decoration: isSelected
                                ? BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  )
                                : null,
                            alignment: Alignment.center,
                            child: Text(
                              '$year',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected ? Colors.blue : Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        controller.text = tempSelectedYear.toString();
                        onSaved(tempSelectedYear.toString());
                      },
                      child: const Text('Pilih'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
