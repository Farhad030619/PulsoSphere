import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import './models/measurement.dart';
import './services/api_service.dart';
import './services/history_service.dart';

class EmgView extends StatefulWidget {
  const EmgView({super.key});

  @override
  State<EmgView> createState() => _EmgViewState();
}

class _EmgViewState extends State<EmgView> {
  late Timer _timer;
  final _buf = List<double>.filled(50, 0.0, growable: true);
  Measurement _m = Measurement.empty();

  @override
  void initState() {
    super.initState();
    _fetch();
    _timer =
        Timer.periodic(const Duration(milliseconds: 1500), (_) => _fetch());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final m = await ApiService.fetchLatest();
      HistoryService().addBpm(m.bpm, m.timestamp);
      setState(() {
        _m = m;
        _buf.removeAt(0);
        _buf.add(m.emg.isNotEmpty ? m.emg.last : 0);
      });
    } catch (_) {
      setState(() {
        _buf.removeAt(0);
        _buf.add(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spots = _buf
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    final lastVal = _m.emg.isNotEmpty ? _m.emg.last.toStringAsFixed(1) : '–';

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.fitness_center,
                    size: 28, color: Colors.blueAccent),
                const SizedBox(width: 12),
                const Text('Senaste EMG‑värde:',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                const Spacer(),
                Text('$lastVal µV',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Text('EMG‑graf',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
                        isCurved: false,
                        barWidth: 2,
                        color: Colors.blueAccent,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  )),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
