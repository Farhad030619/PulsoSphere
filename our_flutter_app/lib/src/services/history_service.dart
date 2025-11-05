import 'package:flutter/foundation.dart';
import '../models/history_entry.dart';

/// Sparar de senaste 50 BPM‑värdena
class HistoryService extends ChangeNotifier {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  final List<HistoryEntry> _list = [];
  List<HistoryEntry> get all => List.unmodifiable(_list);

  /// Lägger till en ny BPM‑post (max 50)
  void addBpm(int bpm, DateTime timestamp) {
    _list.insert(0, HistoryEntry(bpm: bpm, timestamp: timestamp));
    if (_list.length > 50) _list.removeLast();
    notifyListeners();
  }
}
