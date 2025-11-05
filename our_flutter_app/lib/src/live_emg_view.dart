import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import './services/data_controller.dart';

/// Samma vybredd för EMG‑grafen
const int _viewWindow = 100;

class LiveEmgView extends StatelessWidget {
  const LiveEmgView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DataController>();

    // 1) Skapa punkter
    final spots = List<FlSpot>.generate(
      ctrl.emgBuf.length,
      (i) => FlSpot(
        (ctrl.tick - (ctrl.emgBuf.length - i)).toDouble(),
        ctrl.emgBuf[i],
      ),
    );

    // 2) X‑intervall
    final double windowStart =
        (ctrl.tick - _viewWindow) < 0 ? 0.0 : (ctrl.tick - _viewWindow).toDouble();
    final double windowEnd = ctrl.tick.toDouble();

    // 3) Y‑min/max
    final minY = ctrl.emgBuf.reduce((a, b) => a < b ? a : b);
    final maxY = ctrl.emgBuf.reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Text('EMG‑graf',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minX: windowStart,
                      maxX: windowEnd,
                      minY: minY,
                      maxY: maxY,
                      clipData: FlClipData.all(),
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots
                              .where((s) =>
                                  s.x >= windowStart && s.x <= windowEnd)
                              .toList(),
                          isCurved: false,
                          barWidth: 2,
                          color: Colors.blueAccent,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
