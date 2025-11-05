class Measurement {
  final int bpm;
  final List<double> ekg;
  final List<double> emg;
  final DateTime timestamp;

  Measurement({
    required this.bpm,
    required this.ekg,
    required this.emg,
    required this.timestamp,
  });

  factory Measurement.fromJson(Map<String, dynamic> j) => Measurement(
        bpm: j['bpm'] as int,
        ekg: List<double>.from(
            (j['ekg'] as List).map((e) => (e as num).toDouble())),
        emg: List<double>.from(
            (j['emg'] as List).map((e) => (e as num).toDouble())),
        timestamp: DateTime.parse(j['timestamp'] as String),
      );

  factory Measurement.empty() => Measurement(
        bpm: 0,
        ekg: List<double>.filled(50, 0),
        emg: List<double>.filled(50, 0),
        timestamp: DateTime.now(),
      );
}
