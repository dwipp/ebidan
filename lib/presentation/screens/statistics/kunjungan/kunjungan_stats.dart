import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/screens/statistics/widgets/donut_chart.dart';
import 'package:ebidan/presentation/screens/statistics/widgets/k1_chart.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/premium_warning_banner.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class KunjunganStatsScreen extends StatelessWidget {
  final String? monthKey;

  const KunjunganStatsScreen({super.key, this.monthKey});

  @override
  Widget build(BuildContext context) {
    final stats = context.read<StatisticCubit>().state.statistic;
    final selectedMonth = stats?.byMonth[monthKey];
    final selectedKunjungan =
        selectedMonth?.kunjungan ?? stats?.lastMonthData?.kunjungan;
    final warningBanner = PremiumWarningBanner.fromContext(context);

    final List<Map<String, dynamic>> kategori = [
      {"label": "K1", "value": selectedKunjungan?.k1},
      {"label": "K1 USG", "value": selectedKunjungan?.k1Usg},
      {"label": "K1 Skrining Dokter", "value": selectedKunjungan?.k1Dokter},
      {"label": "K1 dengan 4T", "value": selectedKunjungan?.k14t},
      {"label": "K1 Murni", "value": selectedKunjungan?.k1Murni},
      {"label": "K1 Murni Skrining Dokter", "value": selectedKunjungan?.k1MurniDokter},
      {"label": "K1 Murni USG", "value": selectedKunjungan?.k1MurniUsg},
      {"label": "K1 Akses", "value": selectedKunjungan?.k1Akses},
      {"label": "K1 Akses Skrining Dokter", "value": selectedKunjungan?.k1AksesDokter},
      {"label": "K1 Akses USG", "value": selectedKunjungan?.k1AksesUsg},
      {"label": "Abortus", "value": selectedKunjungan?.abortus},
      {"label": "K2", "value": selectedKunjungan?.k2},
      {"label": "K3", "value": selectedKunjungan?.k3},
      {"label": "K4", "value": selectedKunjungan?.k4},
      {"label": "K5", "value": selectedKunjungan?.k5},
      {"label": "K5 USG", "value": selectedKunjungan?.k5Usg},
      {"label": "K6", "value": selectedKunjungan?.k6},
      {"label": "K6 USG", "value": selectedKunjungan?.k6Usg},
    ];

    return Scaffold(
      appBar: PageHeader(title: 'Statistik Kunjungan'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (warningBanner != null) warningBanner,
              Text(
                "Laporan Bulan ${Utils.formattedYearMonth(monthKey ?? stats?.lastUpdatedMonth ?? '')}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // --- TOTAL KUNJUNGAN ---
              AnimatedDataCard(
                label: "Total Kunjungan",
                value: selectedKunjungan?.total ?? 0,
                isTotal: true,
                icon: Icons.bar_chart,
              ),
              const SizedBox(height: 16),

              // --- EXPANSION TILE KATEGORI ---
              ...buildKategoriExpansionTiles(kategori),

              const SizedBox(height: 32),

              // --- CHART AREA ---
              Text(
                "Visualisasi",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // --- Donut Chart Card ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade300.withOpacity(0.5),
                      Colors.blue.shade100.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Perbandingan Kunjungan",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    DonutChart(
                      data: [
                        PieChartDataItem(
                            label: 'K1', value: (selectedKunjungan?.k1 ?? 0).toDouble()),
                        PieChartDataItem(
                            label: 'K2', value: (selectedKunjungan?.k2 ?? 0).toDouble()),
                        PieChartDataItem(
                            label: 'K3', value: (selectedKunjungan?.k3 ?? 0).toDouble()),
                        PieChartDataItem(
                            label: 'K4', value: (selectedKunjungan?.k4 ?? 0).toDouble()),
                        PieChartDataItem(
                            label: 'K5', value: (selectedKunjungan?.k5 ?? 0).toDouble()),
                        PieChartDataItem(
                            label: 'K6', value: (selectedKunjungan?.k6 ?? 0).toDouble()),
                      ],
                      showCenterValue: true,
                      centerLabelTop: '${selectedKunjungan?.total ?? 0}',
                      centerLabelBottom: 'Kunjungan',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // --- K1 Chart Card ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade300.withOpacity(0.5),
                      Colors.orange.shade100.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade100.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Distribusi K1",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    K1Chart(
                      k1Murni: selectedKunjungan?.k1Murni ?? 0,
                      k1Akses: selectedKunjungan?.k1Akses ?? 0,
                      showCenterValue: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- HISTORY BUTTON ---
              if (monthKey == null) ...[
                SizedBox(
                  width: double.infinity,
                  child: Button(
                    isSubmitting: false,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRouter.listKunjunganStats);
                    },
                    label: "Lihat Riwayat Bulanan",
                    icon: Icons.history,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Button(
                    isSubmitting: false,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRouter.trenKunjunganStats,
                          arguments: {
                            'monthKeys': getLastMonths(stats!.lastUpdatedMonth, 3)
                          });
                    },
                    label: "Tren 3 Bulan Terakhir",
                    icon: Icons.trending_up,
                    secondaryButton: true,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Button(
                    isSubmitting: false,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRouter.trenKunjunganStats,
                          arguments: {
                            'monthKeys': getLastMonths(stats!.lastUpdatedMonth, 6)
                          });
                    },
                    label: "Tren 6 Bulan Terakhir",
                    icon: Icons.show_chart,
                    secondaryButton: true,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Button(
                    isSubmitting: false,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRouter.trenKunjunganStats,
                          arguments: {
                            'monthKeys': getLastMonths(stats!.lastUpdatedMonth, 12)
                          });
                    },
                    label: "Tren 1 Tahun Terakhir",
                    icon: Icons.insert_chart_outlined,
                    secondaryButton: true,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<String> getLastMonths(String latestMonth, int count) {
    final DateFormat formatter = DateFormat("yyyy-MM");

    DateTime date = DateFormat("yyyy-MM").parse(latestMonth);

    List<String> months = [];

    for (int i = 0; i < count; i++) {
      DateTime target = DateTime(date.year, date.month - i, 1);
      months.add(formatter.format(target));
    }

    return months;
  }

  // --- ExpansionTile builder ---
  List<Widget> buildKategoriExpansionTiles(List<Map<String, dynamic>> kategori) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var item in kategori) {
      final label = item["label"];
      String parent;

      if (label.toString().startsWith("K1")) {
        parent = "K1";
      } else if (label.toString().startsWith("K2")) {
        parent = "K2";
      } else if (label.toString().startsWith("K3")) {
        parent = "K3";
      } else if (label.toString().startsWith("K4")) {
        parent = "K4";
      } else if (label.toString().startsWith("K5")) {
        parent = "K5";
      } else if (label.toString().startsWith("K6")) {
        parent = "K6";
      } else {
        parent = label; // Abortus jadi parent sendiri
      }

      grouped.putIfAbsent(parent, () => []);
      grouped[parent]!.add(item);
    }

    return grouped.entries.map((entry) {
      final parent = entry.key;
      final children = entry.value;
      if (children.length== 1) {
        return Card(
        margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
              tileColor: getKategoriColor(children.first["label"]).withOpacity(0.15),
              title: Text(children.first["label"]),
              trailing: Text("${children.first["value"] ?? 0}"),
            ),
        );
      }else {
        final parentItem = children.first; // item inti
      final subItems = children.skip(1).toList(); // exclude item pertama

        return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ExpansionTile(
          title: ListTile(
            title: Text(parent),
            trailing: Text(
              "${parentItem["value"] ?? 0}", 
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          collapsedBackgroundColor: getKategoriColor(parent).withOpacity(0.2),
          backgroundColor: getKategoriColor(parent).withOpacity(0.1),
          children: subItems.map((item) {
            return ListTile(
              tileColor: getKategoriColor(item["label"]).withOpacity(0.15),
              title: Text(item["label"]),
              trailing: Text("${item["value"] ?? 0}"),
            );
          }).toList(),
        ),
      );
      }
      
    }).toList();
  }

  // --- Warna kategori ---
  Color getKategoriColor(String label) {
    if (label == "K1") return Colors.blue.shade400;
    if (label == "K1 Murni") return Colors.lightBlue.shade400;
    if (label == "K1 Akses") return Colors.cyan.shade400;
    if (label == "K2") return Colors.green.shade400;
    if (label == "K3") return Colors.yellow.shade400;
    if (label == "K4") return Colors.orange.shade400;
    if (label == "K5") return Colors.pink.shade400;
    if (label == "K6") return Colors.red.shade400;

    if (label.startsWith("K1")) return Colors.blue.shade100;
    if (label.startsWith("K1 Murni")) return Colors.lightBlue.shade100;
    if (label.startsWith("K1 Akses")) return Colors.cyan.shade100;
    if (label.startsWith("K2")) return Colors.green.shade100;
    if (label.startsWith("K3")) return Colors.yellow.shade100;
    if (label.startsWith("K4")) return Colors.orange.shade100;
    if (label.startsWith("K5")) return Colors.pink.shade100;
    if (label.startsWith("K6")) return Colors.red.shade100;

    if (label.contains("Abortus")) return Colors.purple.shade200;

    return Colors.grey.shade100;
  }
}

/// --- Animated Data Card ---
class AnimatedDataCard extends StatefulWidget {
  final String label;
  final int value;
  final bool isTotal;
  final Color? backgroundColor;
  final IconData? icon;

  const AnimatedDataCard({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false,
    this.backgroundColor,
    this.icon,
  });

  @override
  State<AnimatedDataCard> createState() => _AnimatedDataCardState();
}

class _AnimatedDataCardState extends State<AnimatedDataCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    )..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedDataCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = IntTween(begin: 0, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(from: 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: widget.backgroundColor ??
              (widget.isTotal ? Colors.blue.shade100 : Colors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: widget.isTotal ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 20, color: Colors.grey[700]),
              const SizedBox(height: 4),
            ],
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  color: widget.isTotal ? Colors.blue : Colors.grey[700],
                  fontWeight:
                      widget.isTotal ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.compact().format(_animation.value),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.isTotal ? Colors.blue : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
