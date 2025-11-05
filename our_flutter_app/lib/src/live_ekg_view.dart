import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import './services/data_controller.dart';
import './ekg_detail_view.dart';

/// Hur många senaste punkter vi visar på skärmen samtidigt.
const int _viewWindow = 100;

class LiveEkgView extends StatelessWidget {
  const LiveEkgView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DataController>();

    // 1) Skapa listan med datapunkter
    final spots = List<FlSpot>.generate(
      ctrl.ekgBuf.length,
      (i) => FlSpot(
        // x = globala tick minus (bufferten-längd - i) så att vi alltid har
        // de senaste _viewWindow punkterna synliga
        (ctrl.tick - (ctrl.ekgBuf.length - i)).toDouble(),
        ctrl.ekgBuf[i],
      ),
    );

    // 2) Beräkna X-intervallet (de senaste _viewWindow punkterna)
    final double windowStart = (ctrl.tick - _viewWindow) < 0
        ? 0.0
        : (ctrl.tick - _viewWindow).toDouble();
    final double windowEnd = ctrl.tick.toDouble();

    // 3) Beräkna Y-min/max från bufferten
    final minY = ctrl.ekgBuf.reduce((a, b) => a < b ? a : b);
    final maxY = ctrl.ekgBuf.reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // → Puls‑kort (oförändrat)
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite, color: Colors.redAccent, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Puls', style: TextStyle(color: Colors.grey)),
                    TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: ctrl.currentBpm.toDouble(),
                        end: ctrl.currentBpm.toDouble(),
                      ),
                      duration: const Duration(milliseconds: 500),
                      builder: (_, value, __) => Text(
                        '${value.round()} bpm',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // → EKG‑graf
        InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EkgDetailView(data: spots)),
          ),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text('EKG‑graf',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
                                // filtrera bort punkter utanför vårt viewport‑interval
                                .where((s) =>
                                    s.x >= windowStart && s.x <= windowEnd)
                                .toList(),
                            isCurved: false,
                            barWidth: 2,
                            color: Colors.redAccent,
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
        ),
      ],
    );
  }
}
