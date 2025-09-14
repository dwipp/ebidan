import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartDataItem {
  final String label;
  final num value;
  final Color? color;

  PieChartDataItem({
    required this.label,
    required this.value,
    this.color,
  });
}

class DonutChart extends StatefulWidget {
  final List<PieChartDataItem> data;
  final bool showCenterValue;
  final String? centerLabelTop;
  final String? centerLabelBottom;

  const DonutChart({
    super.key,
    required this.data,
    this.showCenterValue = true,
    this.centerLabelTop,
    this.centerLabelBottom,
  });

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> {
  int touchedIndex = -1;
  double _startDegreeOffset = 10.0;
  Timer? _rotationTimer;
  Timer? _longPressTimer;
  bool _pointerDown = false;

  static const Duration _longPressDelay = Duration(milliseconds: 350);
  static const Duration _rotationTick = Duration(milliseconds: 16);
  static const double _baseDegPerTick = 0.2;
  bool _isClockwise = true;

  void _startRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(_rotationTick, (_) {
      setState(() {
        final step = _isClockwise ? _baseDegPerTick : -_baseDegPerTick;
        _startDegreeOffset += step;
        if (_startDegreeOffset >= 360) _startDegreeOffset -= 360;
        if (_startDegreeOffset < 0) _startDegreeOffset += 360;
      });
    });
  }

  void _stopRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = null;
    _isClockwise = !_isClockwise;
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerDown = true;
    _longPressTimer?.cancel();
    _longPressTimer = Timer(_longPressDelay, () {
      if (_pointerDown) _startRotation();
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    _pointerDown = false;
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _stopRotation();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _pointerDown = false;
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _stopRotation();
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _longPressTimer?.cancel();
    super.dispose();
  }

  // generate warna pastel cerah merata
  List<Color> _generateBrightColors(int count) {
  final List<Color> colors = [];
  for (int i = 0; i < count; i++) {
    final hue = (360 / count) * i; // sebar di spektrum
    final saturation = 0.8 + 0.2 * (i % count) / count; // 0.8 - 1.0
    final value = 0.85 + 0.15 * ((i + 1) % count) / count; // 0.85 - 1.0
    colors.add(HSVColor.fromAHSV(1, hue, saturation, value).toColor());
  }
  return colors;
}


  @override
  Widget build(BuildContext context) {
    final filteredData = widget.data.where((item) => item.value != 0).toList();
    final total = filteredData.fold<num>(0, (prev, item) => prev + item.value);
    final colors = _generateBrightColors(filteredData.length);

    Widget? centerContent;
    if (widget.showCenterValue) {
      centerContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.centerLabelTop ?? '$total',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.centerLabelBottom != null)
            Text(
              widget.centerLabelBottom!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black45,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: _onPointerDown,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerCancel,
                child: SizedBox(
                  height: 220,
                  width: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    response == null ||
                                    response.touchedSection == null) {
                                  touchedIndex = -1;
                                  return;
                                }
                                touchedIndex = response
                                    .touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          sections: List.generate(
                            filteredData.length,
                            (index) {
                              final item = filteredData[index];
                              final isTouched = index == touchedIndex;
                              final color = item.color ?? colors[index];
                              return PieChartSectionData(
  value: item.value.toDouble(),
  color: color,
  radius: isTouched ? 65 : 50,
  // gunakan badgeWidget untuk styling berbeda
  badgeWidget: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        item.label,
        style: TextStyle(
          fontSize: isTouched ? 12 : 10,
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
      ),
      Text(
        '${item.value % 1 == 0 ? item.value.toInt() : item.value}',
        style: TextStyle(
          fontSize: isTouched ? 16 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ],
  ),
  badgePositionPercentageOffset: 0.6, // sesuaikan posisi badge di tengah section
  title: '', // kosongkan title karena kita pakai badgeWidget
);
                            },
                          ),
                          centerSpaceRadius: 60,
                          sectionsSpace: 4,
                          startDegreeOffset: _startDegreeOffset,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                      if (centerContent != null) centerContent,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
