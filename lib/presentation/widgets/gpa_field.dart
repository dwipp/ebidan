import 'package:flutter/material.dart';

class GPAField extends StatelessWidget {
  final TextEditingController gravidaController;
  final TextEditingController paraController;
  final TextEditingController abortusController;

  const GPAField({
    super.key,
    required this.gravidaController,
    required this.paraController,
    required this.abortusController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Riwayat Kehamilan (GPA)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: gravidaController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "G",
                      prefixIcon: const Icon(Icons.pregnant_woman),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: paraController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "P",
                      prefixIcon: const Icon(Icons.child_care),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: abortusController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "A",
                      prefixIcon: const Icon(Icons.warning_amber_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
