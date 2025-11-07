import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EkgDetailView extends StatelessWidget {
  final List<FlSpot> data;
  const EkgDetailView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EKG – Detaljvy')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: data,
                isCurved: false,
                barWidth: 2,
                color: Colors.redAccent,
                dotData: FlDotData(show: false),
              )
            ],
          ),
        ),
      ),
    );
  }
}
