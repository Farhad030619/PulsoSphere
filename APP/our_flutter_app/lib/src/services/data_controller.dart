import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'history_service.dart';

class DataController extends ChangeNotifier {
  static const _bufLen = 350;
  late final Timer _timer;

  int _oldBpm = -1;
  int currentBpm = 0;
  int tick = 0; // löpande steg

  final List<double> ekgBuf = List<double>.filled(_bufLen, 0, growable: true);
  final List<double> emgBuf = List<double>.filled(_bufLen, 0, growable: true);

  DataController() {
    _poll();
    _timer = Timer.periodic(const Duration(milliseconds: 3), (_) => _poll());
    
  }

  Future<void> _poll() async {
    tick++; // öka steget
    try {
      final m = await ApiService.fetchLatest();
      final isNew = m.bpm != _oldBpm;
      if (isNew) {
        currentBpm = m.bpm;
        HistoryService().addBpm(m.bpm, m.timestamp);
        for (var v in m.ekg) {
          ekgBuf.removeAt(0);
          ekgBuf.add(v);
        }
        for (var v in m.emg) {
          emgBuf.removeAt(0);
          emgBuf.add(v);
        }
      } else {
        currentBpm = 0;
        ekgBuf.removeAt(0);
        ekgBuf.add(0);
        emgBuf.removeAt(0);
        emgBuf.add(0);
      }
      _oldBpm = m.bpm;
    } catch (_) {
      currentBpm = 0;
      ekgBuf.removeAt(0);
      ekgBuf.add(0);
      emgBuf.removeAt(0);
      emgBuf.add(0);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
