import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import './services/history_service.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryService>().all;
    final fmt = DateFormat('yyyy‑MM‑dd HH:mm:ss');

    if (history.isEmpty) {
      return const Center(child: Text('Ingen historik ännu'));
    }

    return ListView.separated(
      itemCount: history.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final entry = history[i];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(fmt.format(entry.timestamp)),
          subtitle: Text('BPM: ${entry.bpm} bpm'),
        );
      },
    );
  }
}
