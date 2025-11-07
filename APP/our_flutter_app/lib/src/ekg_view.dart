import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import './models/measurement.dart';
import 'ekg_detail_view.dart';

class EkgView extends StatelessWidget {
  final Measurement measurement;
  const EkgView({super.key, required this.measurement});

  @override
  Widget build(BuildContext context) {
    final spots = measurement.ekg
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
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
                    Text('${measurement.bpm} bpm',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => EkgDetailView(data: spots)),
            );
          },
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text('EKG‑graf',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: LineChart(LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          barWidth: 2,
                          color: Colors.redAccent,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    )),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tryck för större vy',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
