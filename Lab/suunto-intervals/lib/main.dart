// Lab probe: Suunto via intervals.icu. Throwaway code — see Lab/Log.md.
//
// Question: with a personal intervals.icu API key, does a Flutter app fetch
// the original FIT files of a run, a treadmill session, and a hike recorded
// on the Suunto watch, and read distance, duration, and heart rate from each?

import 'dart:convert';
import 'dart:io';

import 'package:fit_tool/fit_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const ProbeApp());

// Passed at build time so the key never lands in the repo:
// flutter run --dart-define=ICU_ATHLETE=... --dart-define=ICU_KEY=...
const _defaultAthlete = String.fromEnvironment('ICU_ATHLETE');
const _defaultKey = String.fromEnvironment('ICU_KEY');

const _bg = Color(0xFF1A1D1A);
const _ember = Color(0xFFD9573B);
const _text = Color(0xFFC8C3B0);
const _bright = Color(0xFFECE8DA);

const _base = 'https://intervals.icu/api/v1';

class ProbeApp extends StatelessWidget {
  const ProbeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auburn · intervals probe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _bg,
        textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'monospace',
              bodyColor: _text,
              displayColor: _text,
            ),
      ),
      home: const ProbeScreen(),
    );
  }
}

/// The kinds the pass condition names, read from the FIT file's own sport.
const _kinds = ['RUN', 'TREADMILL', 'HIKE'];

/// What one original FIT file held.
class _Parsed {
  _Parsed({
    this.sport,
    this.subSport,
    this.distance,
    this.duration,
    this.heartRates = 0,
    this.avgHeartRate,
    this.crcOk = true,
    this.error,
  });

  final String? sport;
  final String? subSport;
  final double? distance; // metres
  final double? duration; // seconds, timer time
  final int heartRates; // records carrying a heart rate
  final int? avgHeartRate;
  final bool crcOk;
  final String? error;

  String? get kind {
    if (sport == 'running') {
      const indoor = {'treadmill', 'indoorRunning', 'virtualActivity'};
      return indoor.contains(subSport) ? 'TREADMILL' : 'RUN';
    }
    if (sport == 'hiking') return 'HIKE';
    return null;
  }

  bool get complete =>
      (distance ?? 0) > 0 && (duration ?? 0) > 0 && heartRates > 0;
}

class _Activity {
  _Activity(this.json);

  final Map<String, dynamic> json;
  int? bytes;
  bool gzipped = false;
  int? status;
  _Parsed? parsed;

  String get id => '${json['id']}';
  String get type => '${json['type'] ?? '?'}';
  String get date => '${json['start_date_local'] ?? ''}'.split('T').first;
}

/// Runs off the UI thread, as a top-level function so nothing else is sent along: a long run's file holds thousands of records.
_Parsed _parse(Uint8List bytes) {
  FitFile file;
  var crcOk = true;
  try {
    file = FitFile.fromBytes(bytes);
  } catch (_) {
    crcOk = false;
    try {
      file = FitFile.fromBytes(bytes, checkCrc: false);
    } catch (e) {
      return _Parsed(crcOk: false, error: '$e');
    }
  }

  SessionMessage? session;
  var heartRates = 0;
  for (final record in file.records) {
    final m = record.message;
    if (m is SessionMessage) session ??= m;
    if (m is RecordMessage && (m.heartRate ?? 0) > 0) heartRates++;
  }
  return _Parsed(
    sport: session?.sport?.name,
    subSport: session?.subSport?.name,
    distance: session?.totalDistance,
    duration: session?.totalTimerTime ?? session?.totalElapsedTime,
    heartRates: heartRates,
    avgHeartRate: session?.avgHeartRate,
    crcOk: crcOk,
    error: session == null ? 'no session message' : null,
  );
}

class ProbeScreen extends StatefulWidget {
  const ProbeScreen({super.key});

  @override
  State<ProbeScreen> createState() => _ProbeScreenState();
}

class _ProbeScreenState extends State<ProbeScreen> {
  final _athlete = TextEditingController(text: _defaultAthlete);
  final _key = TextEditingController(text: _defaultKey);
  final _log = <String>[];
  final _days = [90, 365, 30];
  int _dayIndex = 0;
  bool _busy = false;
  List<_Activity> _activities = [];

  /// At most this many files are fetched, newest first.
  static const _maxFiles = 30;

  void _say(String line) => setState(() => _log.add(line));

  Map<String, String> get _auth => {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('API_KEY:${_key.text.trim()}'))}',
      };

  Future<void> _read() async {
    setState(() {
      _busy = true;
      _log.clear();
      _activities = [];
    });
    try {
      final now = DateTime.now();
      String day(DateTime d) => d.toIso8601String().split('T').first;
      final oldest = day(now.subtract(Duration(days: _days[_dayIndex])));
      final newest = day(now);

      // The athlete id is tried as entered, then without its "i" prefix.
      final given = _athlete.text.trim();
      final ids = [given, if (given.startsWith('i')) given.substring(1)];
      http.Response? list;
      for (final id in ids) {
        final uri = Uri.parse('$_base/athlete/$id/activities?oldest=$oldest&newest=$newest');
        final res = await http.get(uri, headers: _auth);
        _say('LIST athlete/$id → ${res.statusCode}');
        if (res.statusCode == 200) {
          list = res;
          break;
        }
        _say('  ${res.body.length > 200 ? res.body.substring(0, 200) : res.body}');
      }
      if (list == null) return;

      final all = (jsonDecode(list.body) as List).cast<Map<String, dynamic>>();
      _say('${all.length} activities in the last ${_days[_dayIndex]} days');
      final types = <String, int>{};
      for (final a in all) {
        types.update('${a['type']}', (n) => n + 1, ifAbsent: () => 1);
      }
      _say('types: ${types.entries.map((e) => '${e.key} ${e.value}').join(' · ')}');

      final picked = all.take(_maxFiles).map(_Activity.new).toList();
      setState(() => _activities = picked);

      for (final a in picked) {
        final res = await http.get(Uri.parse('$_base/activity/${a.id}/file'), headers: _auth);
        a.status = res.statusCode;
        if (res.statusCode != 200) {
          setState(() {});
          continue;
        }
        var bytes = res.bodyBytes;
        // The original file comes gzip-compressed.
        if (bytes.length > 2 && bytes[0] == 0x1f && bytes[1] == 0x8b) {
          a.gzipped = true;
          bytes = Uint8List.fromList(gzip.decode(bytes));
        }
        a.bytes = bytes.length;
        final isFit = bytes.length > 12 && ascii.decode(bytes.sublist(8, 12), allowInvalid: true) == '.FIT';
        a.parsed = isFit
            ? await compute(_parse, bytes)
            : _Parsed(error: 'not a FIT file');
        setState(() {});
      }
      _say('done');
    } catch (e) {
      _say('ERROR ${'$e'.split('\n').first}');
    } finally {
      setState(() => _busy = false);
    }
  }

  String _verdict() {
    final passed = {
      for (final a in _activities)
        if (a.parsed?.complete ?? false) a.parsed!.kind,
    };
    final missing = _kinds.where((k) => !passed.contains(k)).toList();
    if (_activities.isEmpty) return '—';
    return missing.isEmpty ? 'PASS' : 'MISSING ${missing.join(' · ')}';
  }

  Widget _row(_Activity a) {
    final p = a.parsed;
    String km(double? m) => m == null ? '—' : (m / 1000).toStringAsFixed(2);
    String mins(double? s) => s == null ? '—' : '${(s / 60).toStringAsFixed(0)}m';
    final head = '${a.date}  ${a.type}  ${p?.kind ?? ''}';
    final String body;
    if (a.status != null && a.status != 200) {
      body = 'FILE → ${a.status}';
    } else if (p == null) {
      body = '…';
    } else if (p.error != null && p.sport == null) {
      body = 'PARSE ${p.error}';
    } else {
      body = 'fit ${p.sport}/${p.subSport} · ${km(p.distance)} km · ${mins(p.duration)} · '
          'HR ${p.heartRates} samples avg ${p.avgHeartRate ?? '—'} · '
          '${a.bytes} B${a.gzipped ? ' gz' : ''}${p.crcOk ? '' : ' · CRC ✗'}';
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(head, style: TextStyle(color: (p?.complete ?? false) ? _ember : _bright)),
          Text(body, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {bool obscure = false}) => TextField(
        controller: c,
        obscureText: obscure,
        style: const TextStyle(color: _bright),
        decoration: InputDecoration(labelText: label, isDense: true),
      );

  Widget _button(String label, VoidCallback? onTap) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: _bright,
              shape: const RoundedRectangleBorder(),
            ),
            onPressed: onTap,
            child: Text(label),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field('ATHLETE ID', _athlete),
              _field('API KEY', _key, obscure: true),
              const SizedBox(height: 8),
              Row(children: [
                _button(_busy ? 'READING…' : 'READ LAST ${_days[_dayIndex]} DAYS', _busy ? null : _read),
                _button('±', _busy ? null : () => setState(() => _dayIndex = (_dayIndex + 1) % _days.length)),
              ]),
              const SizedBox(height: 12),
              Text('VERDICT  ${_verdict()}',
                  style: const TextStyle(color: _ember, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(children: [
                  ..._log.map((l) => Text(l, style: const TextStyle(fontSize: 12))),
                  const SizedBox(height: 8),
                  ..._activities.map(_row),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
