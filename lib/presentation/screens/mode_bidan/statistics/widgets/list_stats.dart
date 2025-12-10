import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/premium_warning_banner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListStatsScreen extends StatelessWidget {
  final String title;
  final Map<String, dynamic> dataMap;
  final String routeName;
  final String Function(String key, dynamic value) subtitleBuilder;
  final IconData leadingIcon;

  const ListStatsScreen({
    super.key,
    required this.title,
    required this.dataMap,
    required this.routeName,
    required this.subtitleBuilder,
    this.leadingIcon = Icons.calendar_month,
  });

  @override
  Widget build(BuildContext context) {
    final warningBanner = PremiumWarningBanner.fromContext(context);

    final dataList = dataMap.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key)); // urut terbaru ke lama

    final hasBanner = warningBanner != null;

    return Scaffold(
      appBar: PageHeader(title: Text(title)),
      body: ListView.builder(
        itemCount: dataList.length + (hasBanner ? 1 : 0),
        itemBuilder: (context, index) {
          if (hasBanner && index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: warningBanner,
            );
          }

          final entry = dataList[index - (hasBanner ? 1 : 0)];
          final bulanKey = entry.key;
          final value = entry.value;

          // Konversi yyyy-MM → "MMMM yyyy"
          final parsedDate = DateTime.tryParse("$bulanKey-01");
          final bulanFormatted = parsedDate != null
              ? DateFormat("MMMM yyyy").format(parsedDate)
              : bulanKey;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: Icon(leadingIcon),
              title: Text(
                bulanFormatted,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(subtitleBuilder(bulanKey, value)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if ((hasBanner ? index - 1 : index) == 0) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushNamed(
                    context,
                    routeName,
                    arguments: {'monthKey': bulanKey},
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
