import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/measurement.dart';

class ApiService {
  static const _base = 'http://127.0.0.1:5001';

  static Future<Measurement> fetchLatest() async {
    final r = await http.get(Uri.parse('$_base/data'));
    if (r.statusCode != 200) {
      throw Exception('HTTP ${r.statusCode}');
    }
    return Measurement.fromJson(json.decode(r.body) as Map<String, dynamic>);
  }
}
