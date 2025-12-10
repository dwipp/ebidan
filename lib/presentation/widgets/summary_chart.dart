import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SummaryChart extends StatefulWidget {
  final int pasien;
  final int kehamilan;
  final int kunjungan;
  final int persalinan;
  final bool showCenterValue;

  const SummaryChart({
    super.key,
    required this.pasien,
    required this.kehamilan,
    required this.kunjungan,
    required this.persalinan,
    this.showCenterValue = true,
  });

  @override
  State<SummaryChart> createState() => _SummaryChartState();
}

class _SummaryChartState extends State<SummaryChart> {
  int touchedIndex = -1;

  // rotasi (derajat)
  double _startDegreeOffset = 10.0;

  // timer untuk rotasi berkelanjutan
  Timer? _rotationTimer;

  // timer untuk mendeteksi long-press (start setelah delay)
  Timer? _longPressTimer;
  bool _pointerDown = false;

  // konfigurasi
  static const Duration _longPressDelay =
      Duration(milliseconds: 350); // durasi untuk long-press
  static const Duration _rotationTick =
      Duration(milliseconds: 16); // ~60fps
  static const double _baseDegPerTick = 0.2; // kecepatan dasar

  bool _isClockwise = true; // arah rotasi

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
    // setelah selesai satu sesi rotasi, balik arah
    _isClockwise = !_isClockwise;
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerDown = true;
    _longPressTimer?.cancel();
    _longPressTimer = Timer(_longPressDelay, () {
      if (_pointerDown) {
        _startRotation();
      }
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

  @override
  Widget build(BuildContext context) {
    final total = widget.pasien +
        widget.kehamilan +
        widget.kunjungan +
        widget.persalinan;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Ringkasan Bulan Ini",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
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
                                    .touchedSection!
                                    .touchedSectionIndex;
                              });
                            },
                          ),
                          sections: [
                            _buildSection(
                              index: 0,
                              value: widget.pasien.toDouble(),
                              color: Colors.orange,
                              label: "Pasien Baru\n${widget.pasien}",
                            ),
                            _buildSection(
                              index: 1,
                              value: widget.kehamilan.toDouble(),
                              color: Colors.pink,
                              label: "Ibu Hamil\n${widget.kehamilan}",
                            ),
                            _buildSection(
                              index: 2,
                              value: widget.kunjungan.toDouble(),
                              color: Colors.blue,
                              label: "Kunjungan\n${widget.kunjungan}",
                            ),
                            _buildSection(
                              index: 3,
                              value: widget.persalinan.toDouble(),
                              color: Colors.green,
                              label: "Persalinan\n${widget.persalinan}",
                            ),
                          ],
                          centerSpaceRadius: 60,
                          sectionsSpace: 4,
                          startDegreeOffset: _startDegreeOffset,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                      if (widget.showCenterValue)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$total",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              "Total",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
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

  PieChartSectionData _buildSection({
    required int index,
    required double value,
    required Color color,
    required String label,
  }) {
    final isTouched = index == touchedIndex;

    return PieChartSectionData(
      value: value > 0 ? value : 0.0001,
      color: color,
      radius: isTouched ? 65 : 50,
      title: label,
      titleStyle: TextStyle(
        fontSize: isTouched ? 14 : 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
