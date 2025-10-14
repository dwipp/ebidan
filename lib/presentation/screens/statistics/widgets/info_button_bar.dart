import 'package:flutter/material.dart';

/// Komponen tombol info reusable dengan dukungan RichText (bold + normal)
class InfoButtonBar extends StatelessWidget {
  final String title;
  final List<TextSpan> contentSpans;
  final Color? iconColor;

  const InfoButtonBar({
    super.key,
    required this.title,
    required this.contentSpans,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.info_outline, color: iconColor ?? Colors.blueGrey),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: Colors.black87,
                  ),
                  children: contentSpans,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      },
    );
  }
}
