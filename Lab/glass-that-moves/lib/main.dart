// Lab sketch: Glass that moves. Throwaway code — see Lab/Log.md.
//
// Question: does a halo and smudge layer that shifts with the phone's tilt
// read as real glass over the screen, without crossing the values and keys it
// must not obscure?
//
// The CRT shader from the passed probe, with the glass driven by the phone:
// the halo is a reflection of the room's light, so it slides as the phone
// tilts; the smudges sit on the glass and stay put, showing only where that
// reflection passes over them — as fingerprints do on a real screen.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() => runApp(const SketchApp());

const _tube = Color(0xFF1A1D1A);
const _ember = Color(0xFFD9573B);
const _text = Color(0xFFC8C3B0);
const _bright = Color(0xFFECE8DA);
const _obsidian = Color(0xFF121215);

class SketchApp extends StatelessWidget {
  const SketchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auburn · Glass sketch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const SketchScreen(),
    );
  }
}

class SketchScreen extends StatefulWidget {
  const SketchScreen({super.key});

  @override
  State<SketchScreen> createState() => _SketchScreenState();
}

class _SketchScreenState extends State<SketchScreen> with SingleTickerProviderStateMixin {
  ui.FragmentProgram? _program;

  static const _strengths = [0.6, 1.0];
  int _strengthIndex = 1;
  static const _glassLevels = [('OFF', 0.0), ('LOW', 0.6), ('HIGH', 1.2)];
  int _glassIndex = 1;
  static const _travels = [('SMALL', 0.35), ('LARGE', 0.7)];
  int _travelIndex = 0;

  // Tilt: the gravity direction relative to the pose captured by CENTER,
  // smoothed so the reflection glides rather than jitters.
  StreamSubscription<AccelerometerEvent>? _sensor;
  double _ax = 0, _ay = 0;
  double? _restX, _restY;
  double _tx = 0, _ty = 0;

  // Frame times, to confirm the sensor-driven glass stays inside the budget.
  final _total = <double>[];

  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;

  // Stand-in screen state.
  final _plates = <double>[20, 10, 10];
  final _today = <(double, String)>[(60, 'WARMUP'), (100, 'IDEAL')];
  String? _pressed;

  @override
  void initState() {
    super.initState();
    ui.FragmentProgram.fromAsset('shaders/glass.frag').then((p) => setState(() => _program = p));
    _sensor = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen((e) {
      _ax = e.x;
      _ay = e.y;
      _restX ??= e.x;
      _restY ??= e.y;
    });
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    _ticker = createTicker((d) {
      // Ease toward the current tilt each frame.
      final dx = ((_ax - (_restX ?? _ax)) / 9.81).clamp(-1.0, 1.0);
      final dy = ((_ay - (_restY ?? _ay)) / 9.81).clamp(-1.0, 1.0);
      setState(() {
        _elapsed = d;
        _tx += (dx - _tx) * 0.12;
        _ty += (dy - _ty) * 0.12;
      });
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sensor?.cancel();
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    super.dispose();
  }

  void _onTimings(List<ui.FrameTiming> timings) {
    for (final t in timings) {
      _total.add(t.totalSpan.inMicroseconds / 1000);
    }
    if (_total.length > 600) _total.removeRange(0, _total.length - 600);
  }

  double _p95() {
    if (_total.isEmpty) return 0;
    final s = [..._total]..sort();
    return s[((s.length - 1) * 0.95).round()];
  }

  void _logSet(PointerDownEvent e, String grade) => setState(() {
        _today.add((_totalLoad, grade));
        _pressed = grade;
      });

  double get _totalLoad => 20 + 2 * _plates.fold<double>(0, (a, p) => a + p);

  @override
  Widget build(BuildContext context) {
    // The system's reduced-motion setting holds the glass still.
    final still = MediaQuery.of(context).disableAnimations;
    final travel = _travels[_travelIndex].$2;
    final lightX = 0.28 - (still ? 0 : _tx) * travel;
    final lightY = 0.14 + (still ? 0 : _ty) * travel;

    final screen = _standIn();
    final program = _program;
    Widget shaded = screen;
    if (program != null && ui.ImageFilter.isShaderFilterSupported) {
      final shader = program.fragmentShader()
        ..setFloat(2, _elapsed.inMicroseconds / 1e6)
        ..setFloat(3, _strengths[_strengthIndex])
        ..setFloat(4, still ? 0.0 : 1.0)
        ..setFloat(5, lightX)
        ..setFloat(6, lightY)
        ..setFloat(7, _glassLevels[_glassIndex].$2);
      shaded = ImageFiltered(imageFilter: ui.ImageFilter.shader(shader), child: screen);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _readout(still),
            Expanded(child: shaded),
          ],
        ),
      ),
    );
  }

  Widget _readout(bool still) {
    const style = TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: _bright, height: 1.3);
    final line = 'GLASS ${_glassLevels[_glassIndex].$1} · TRAVEL ${_travels[_travelIndex].$1} · '
        'STRENGTH ${_strengths[_strengthIndex]} · FRAME p95 ${_p95().toStringAsFixed(1)} ms'
        '${still ? ' · REDUCED MOTION: STILL' : ''}';
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(line, style: style),
          const SizedBox(height: 4),
          Row(
            children: [
              _small('GLASS', () => setState(() => _glassIndex = (_glassIndex + 1) % _glassLevels.length)),
              _small('TRAVEL', () => setState(() => _travelIndex = (_travelIndex + 1) % _travels.length)),
              _small('STRENGTH', () => setState(() => _strengthIndex = (_strengthIndex + 1) % _strengths.length)),
              _small('CENTER', () => setState(() {
                    _restX = _ax;
                    _restY = _ay;
                  })),
            ],
          ),
        ],
      ),
    );
  }

  Widget _small(String label, VoidCallback onTap) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: SizedBox(
            height: 34,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: _bright,
                side: const BorderSide(color: _text),
                shape: const RoundedRectangleBorder(),
                padding: EdgeInsets.zero,
              ),
              child: Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
            ),
          ),
        ),
      );

  // ------------------------------------------------------------- stand-in

  /// A rough stand-in for the round 3 Plates screen: a realistic amount of UI.
  Widget _standIn() {
    const mono = TextStyle(fontFamily: 'monospace', color: _text, fontSize: 12.5);
    final secs = _elapsed.inMilliseconds / 1000;
    return Container(
      color: _tube,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('10-23 · GYMS4YOU', style: mono),
              Text('T+${secs.toStringAsFixed(2)} · ROLL OFF', style: mono),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            color: _ember,
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: _obsidian, width: 2)),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: const Text('ROMANIAN DEADLIFT',
                  style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 3,
                      color: _obsidian)),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(border: Border.all(color: _ember)),
            padding: const EdgeInsets.all(8),
            child: const Text(
                'LOOK FORWARD — NOT DOWN\nPull on the bar · twist elbows in throughout\nInitiate by sitting back',
                style: mono),
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < 4; i++) _setRow(i, mono),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(_totalLoad),
                  style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 50, fontWeight: FontWeight.bold, color: _ember)),
              Wrap(
                spacing: 4,
                children: [
                  for (final p in [20.0, 10.0, 5.0, 2.5])
                    _key('+${_fmt(p)}', 44, () => setState(() => _plates.add(p))),
                  _key('−LAST', 54, () => setState(() {
                        if (_plates.isNotEmpty) _plates.removeLast();
                      })),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          _grade('IDEAL', filled: true, height: 52),
          const SizedBox(height: 5),
          Row(
            children: [
              for (final g in ['ACCEPTABLE', 'LIGHT', 'YIELDING', 'WARMUP'])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _grade(g, height: 46),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// The table scrolls with the sets: it always shows the last three logged
  /// and the one being done now, so every tap changes what is on screen.
  Widget _setRow(int i, TextStyle mono) {
    const last = [(60.0, 'WARMUP'), (100.0, 'IDEAL'), (100.0, 'IDEAL'), (80.0, 'IDEAL')];
    final first = _today.length > 3 ? _today.length - 3 : 0;
    final n = first + i;
    final t = n < _today.length ? _today[n] : null;
    final l = last[n % last.length];
    return SizedBox(
      height: 22,
      child: Row(
        children: [
          SizedBox(width: 40, child: Text('S${n + 1}', style: mono)),
          Expanded(child: Text('${_fmt(l.$1)} ${l.$2}', style: mono)),
          Expanded(
            child: Text(
              t == null ? (n == _today.length ? '▸ NOW' : '—') : '${_fmt(t.$1)} ${t.$2}',
              style: mono.copyWith(color: t == null ? _bright : _ember, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _key(String label, double width, VoidCallback onTap) => SizedBox(
        width: width,
        height: 44,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: _text,
            side: BorderSide(color: _text.withValues(alpha: 0.6)),
            shape: const RoundedRectangleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        ),
      );

  /// A grade key logs on pointer down and shows itself pressed until the finger
  /// lifts, so every tap is answered on screen, in any order, as often as wanted.
  Widget _grade(String g, {bool filled = false, required double height}) {
    final pressed = _pressed == g;
    final solid = filled != pressed;
    return Listener(
      onPointerDown: (e) => _logSet(e, g),
      onPointerUp: (_) => setState(() => _pressed = null),
      onPointerCancel: (_) => setState(() => _pressed = null),
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: solid ? (pressed ? _bright : _ember) : Colors.transparent,
          border: Border.all(color: pressed ? _bright : _ember, width: 2),
        ),
        child: Text(g,
            style: TextStyle(
              fontFamily: filled ? 'serif' : 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: filled ? 20 : 11,
              letterSpacing: filled ? 4 : 0.5,
              color: solid ? _obsidian : _bright,
            )),
      ),
    );
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.round().toString() : v.toString();
}
