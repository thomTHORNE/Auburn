// Lab probe: Suunto via Health Connect. Throwaway code — see Lab/Log.md.
//
// Question: does a Flutter app on the phone read the runs, treadmill
// sessions, and hikes the Suunto app saved to Health Connect, with distance,
// duration, and heart rate?

import 'package:flutter/material.dart';
import 'package:health/health.dart';

void main() => runApp(const ProbeApp());

const _bg = Color(0xFF1A1D1A);
const _ember = Color(0xFFD9573B);
const _text = Color(0xFFC8C3B0);
const _bright = Color(0xFFECE8DA);

class ProbeApp extends StatelessWidget {
  const ProbeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auburn · Suunto probe',
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

/// The activity types the probe's pass condition names.
const _wanted = <HealthWorkoutActivityType, String>{
  HealthWorkoutActivityType.RUNNING: 'RUN',
  HealthWorkoutActivityType.RUNNING_TREADMILL: 'TREADMILL',
  HealthWorkoutActivityType.HIKING: 'HIKE',
};

/// Every type the workout read touches: Health Connect refuses the distance,
/// calorie, and step lookups inside a workout read without their own grants.
const _types = <HealthDataType>[
  HealthDataType.WORKOUT,
  HealthDataType.DISTANCE_DELTA,
  HealthDataType.TOTAL_CALORIES_BURNED,
  HealthDataType.STEPS,
  HealthDataType.HEART_RATE,
];

class _Workout {
  _Workout(this.point, this.heartRates);

  final HealthDataPoint point;
  final List<double> heartRates;

  WorkoutHealthValue get value => point.value as WorkoutHealthValue;
  Duration get duration => point.dateTo.difference(point.dateFrom);
}

class ProbeScreen extends StatefulWidget {
  const ProbeScreen({super.key});

  @override
  State<ProbeScreen> createState() => _ProbeScreenState();
}

class _ProbeScreenState extends State<ProbeScreen> {
  final _health = Health();
  final _log = <String>[];

  HealthConnectSdkStatus? _sdk;
  bool? _granted;
  bool? _history;
  List<_Workout> _workouts = [];
  Map<String, int> _sources = {};
  bool _busy = false;
  int _days = 90;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _note(String line) => setState(() => _log.insert(0, line));

  Future<void> _init() async {
    await _health.configure();
    final sdk = await _health.getHealthConnectSdkStatus();
    final granted = await _health.hasPermissions(_types);
    final history = await _health.isHealthDataHistoryAuthorized();
    setState(() {
      _sdk = sdk;
      _granted = granted;
      _history = history;
    });
  }

  Future<void> _grant() async {
    final ok = await _health.requestAuthorization(_types);
    _note('Access request: ${ok ? 'granted' : 'not granted'}');
    await _init();
  }

  Future<void> _grantHistory() async {
    final ok = await _health.requestHealthDataHistoryAuthorization();
    _note('History request: ${ok ? 'granted' : 'not granted'}');
    await _init();
  }

  Future<void> _read() async {
    setState(() => _busy = true);
    final end = DateTime.now();
    final start = end.subtract(Duration(days: _days));
    try {
      final workouts = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: start,
        endTime: end,
      );
      final heart = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: start,
        endTime: end,
      );

      final sources = <String, int>{};
      for (final p in [...workouts, ...heart]) {
        final key = '${p.sourceName} · ${p.type.name}';
        sources[key] = (sources[key] ?? 0) + 1;
      }

      final result = <_Workout>[];
      for (final w in workouts) {
        // Heart rate from the same app, inside the workout's window.
        final hr = heart
            .where((h) =>
                h.sourceName == w.sourceName &&
                !h.dateFrom.isBefore(w.dateFrom) &&
                !h.dateTo.isAfter(w.dateTo))
            .map((h) => (h.value as NumericHealthValue).numericValue.toDouble())
            .toList();
        result.add(_Workout(w, hr));
      }
      result.sort((a, b) => b.point.dateFrom.compareTo(a.point.dateFrom));

      setState(() {
        _workouts = result;
        _sources = sources;
      });
      _note('Read $_days days: ${workouts.length} workouts, ${heart.length} heart-rate samples');
    } catch (e) {
      _note('Read failed: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  /// Pass condition: each wanted type appears with distance, duration, and heart rate.
  Map<String, String> _verdict() {
    final out = <String, String>{};
    _wanted.forEach((type, label) {
      final matches = _workouts.where((w) => w.value.workoutActivityType == type).toList();
      if (matches.isEmpty) {
        out[label] = 'NOT FOUND';
        return;
      }
      final full = matches.where((w) =>
          (w.value.totalDistance ?? 0) > 0 && w.duration.inSeconds > 0 && w.heartRates.isNotEmpty);
      out[label] = full.isNotEmpty
          ? 'PASS (${full.length}/${matches.length} complete)'
          : 'FOUND, MISSING FIELDS (${matches.length})';
    });
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final verdict = _verdict();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            const Text('SUUNTO VIA HEALTH CONNECT · PROBE',
                style: TextStyle(color: _ember, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            _row('Health Connect', _sdk?.name ?? '…'),
            _row('Access', _granted == null ? '…' : (_granted! ? 'granted' : 'not granted')),
            _row('History > 30 days', _history == null ? '…' : (_history! ? 'granted' : 'not granted')),
            const SizedBox(height: 10),
            _button('1 · GRANT ACCESS', _grant),
            _button('2 · ALLOW HISTORY', _grantHistory),
            Row(
              children: [
                Expanded(child: _button('3 · READ LAST $_days DAYS', _busy ? null : _read)),
                const SizedBox(width: 6),
                SizedBox(
                  width: 64,
                  child: _button('±', () => setState(() => _days = _days == 90 ? 365 : (_days == 365 ? 30 : 90))),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _heading('VERDICT'),
            ...verdict.entries.map((e) => _row(e.key, e.value,
                color: e.value.startsWith('PASS') ? _bright : _ember)),
            const SizedBox(height: 14),
            _heading('SOURCES (APP · TYPE · COUNT)'),
            if (_sources.isEmpty) const Text('—'),
            ..._sources.entries.map((e) => Text('${e.key} · ${e.value}', style: const TextStyle(fontSize: 12))),
            const SizedBox(height: 14),
            _heading('WORKOUTS'),
            if (_workouts.isEmpty) const Text('—'),
            ..._workouts.map(_workoutTile),
            const SizedBox(height: 14),
            _heading('LOG'),
            ..._log.map((l) => Text(l, style: const TextStyle(fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _workoutTile(_Workout w) {
    final d = w.point.dateFrom;
    final date = '${d.year}-${_two(d.month)}-${_two(d.day)} ${_two(d.hour)}:${_two(d.minute)}';
    final km = w.value.totalDistance == null ? '—' : (w.value.totalDistance! / 1000).toStringAsFixed(2);
    final hr = w.heartRates.isEmpty
        ? 'no HR'
        : 'HR ${w.heartRates.length} samples, avg ${(w.heartRates.reduce((a, b) => a + b) / w.heartRates.length).round()}';
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: _text.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${w.value.workoutActivityType.name} · $date',
              style: const TextStyle(color: _bright, fontWeight: FontWeight.bold)),
          Text('${w.duration.inMinutes} min · $km km · ${w.value.totalEnergyBurned ?? '—'} kcal · $hr',
              style: const TextStyle(fontSize: 12)),
          Text('source: ${w.point.sourceName}', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  Widget _heading(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(s, style: const TextStyle(color: _ember, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      );

  Widget _row(String k, String v, {Color color = _bright}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(child: Text(k)),
            Text(v, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _button(String label, VoidCallback? onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: _bright,
              side: const BorderSide(color: _ember, width: 2),
              shape: const RoundedRectangleBorder(),
            ),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ),
      );
}
