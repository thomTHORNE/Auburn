// Lab probe: CRT shader over Flutter. Throwaway code — see Lab/Log.md.
//
// Question: can Flutter run a custom fragment shader over the whole rendered
// screen on the Fold 8 while taps still answer within one frame?
//
// Three modes, cycled from the readout:
//   OFF      no shader — the baseline.
//   FILTER   path A: ImageFilter.shader over the screen (Impeller only).
//   SAMPLER  path B: flutter_shaders' AnimatedSampler — snapshot, then shade.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

void main() => runApp(const ProbeApp());

const _tube = Color(0xFF1A1D1A);
const _ember = Color(0xFFD9573B);
const _text = Color(0xFFC8C3B0);
const _bright = Color(0xFFECE8DA);
const _obsidian = Color(0xFF121215);

enum Mode { off, filter, sampler }

class ProbeApp extends StatelessWidget {
  const ProbeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auburn · CRT probe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const ProbeScreen(),
    );
  }
}

/// Frame and tap measurements for one mode.
class Stats {
  final total = <double>[];
  final raster = <double>[];
  final taps = <double>[];
  int? firstUs;
  int? lastUs;

  void clear() {
    total.clear();
    raster.clear();
    taps.clear();
    firstUs = null;
    lastUs = null;
  }

  double get fps {
    if (firstUs == null || lastUs == null || lastUs == firstUs) return 0;
    return (total.length - 1) / ((lastUs! - firstUs!) / 1e6);
  }

  static double pct(List<double> xs, double p) {
    if (xs.isEmpty) return 0;
    final s = [...xs]..sort();
    return s[((s.length - 1) * p).round()];
  }
}

class ProbeScreen extends StatefulWidget {
  const ProbeScreen({super.key});

  @override
  State<ProbeScreen> createState() => _ProbeScreenState();
}

class _ProbeScreenState extends State<ProbeScreen> with SingleTickerProviderStateMixin {
  ui.FragmentProgram? _program;
  Mode _mode = Mode.off;
  double _strength = 1.0;
  final _stats = {for (final m in Mode.values) m: Stats()};

  /// Tap start, keyed by the build-start timestamp of the frame that shows it.
  final _pendingTaps = <int, int>{};

  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;

  // Stand-in screen state.
  final _plates = <double>[20, 10, 10];
  final _today = <(double, String)>[(60, 'WARMUP'), (100, 'IDEAL')];

  @override
  void initState() {
    super.initState();
    ui.FragmentProgram.fromAsset('shaders/crt.frag').then((p) => setState(() => _program = p));
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    // A running clock keeps frames flowing in every mode, so modes compare fairly.
    _ticker = createTicker((d) => setState(() => _elapsed = d))..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    super.dispose();
  }

  void _onTimings(List<ui.FrameTiming> timings) {
    final s = _stats[_mode]!;
    for (final t in timings) {
      s.total.add(t.totalSpan.inMicroseconds / 1000);
      s.raster.add(t.rasterDuration.inMicroseconds / 1000);
      final finish = t.timestampInMicroseconds(ui.FramePhase.rasterFinish);
      s.firstUs ??= finish;
      s.lastUs = finish;
      final start = _pendingTaps.remove(t.timestampInMicroseconds(ui.FramePhase.buildStart));
      if (start != null) {
        // Pointer timestamps and frame timestamps share the monotonic clock on
        // Android; a negative or absurd value means they do not on this device.
        final ms = (finish - start) / 1000;
        if (ms > 0 && ms < 1000) s.taps.add(ms);
      }
    }
  }

  /// Grades log on pointer down and record when the tap landed.
  void _logSet(PointerDownEvent e, String grade) {
    final start = e.timeStamp.inMicroseconds;
    setState(() => _today.add((_total, grade)));
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _pendingTaps[SchedulerBinding.instance.currentSystemFrameTimeStamp.inMicroseconds] = start;
    });
  }

  double get _total => 20 + 2 * _plates.fold<double>(0, (a, p) => a + p);

  void _cycleMode() => setState(() {
        _mode = Mode.values[(_mode.index + 1) % Mode.values.length];
        if (_mode == Mode.filter && !ui.ImageFilter.isShaderFilterSupported) _mode = Mode.sampler;
      });

  @override
  Widget build(BuildContext context) {
    final screen = _standIn();
    final program = _program;
    final time = _elapsed.inMicroseconds / 1e6;

    Widget shaded = screen;
    if (program != null && _mode == Mode.filter) {
      final shader = program.fragmentShader()
        ..setFloat(2, time)
        ..setFloat(3, _strength);
      shaded = ImageFiltered(imageFilter: ui.ImageFilter.shader(shader), child: screen);
    } else if (program != null && _mode == Mode.sampler) {
      shaded = AnimatedSampler((image, size, canvas) {
        final shader = program.fragmentShader()
          ..setFloat(0, size.width)
          ..setFloat(1, size.height)
          ..setFloat(2, time)
          ..setFloat(3, _strength)
          ..setImageSampler(0, image);
        canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
      }, child: screen);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _readout(context),
            Expanded(child: shaded),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- readout

  Widget _readout(BuildContext context) {
    final hz = View.of(context).display.refreshRate;
    const style = TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: _bright, height: 1.3);
    String f(double v) => v.toStringAsFixed(1);
    final lines = <String>[
      'MODE ${_mode.name.toUpperCase()} · STRENGTH ${_strength.toStringAsFixed(1)} · '
          'FILTER PATH ${ui.ImageFilter.isShaderFilterSupported ? 'SUPPORTED' : 'UNSUPPORTED'} · DISPLAY ${hz.round()} Hz',
      'MODE     FPS  TOTAL p50/p95  RASTER p95  TAP avg/max   n',
      for (final m in Mode.values)
        () {
          final s = _stats[m]!;
          final avg = s.taps.isEmpty ? 0.0 : s.taps.reduce((a, b) => a + b) / s.taps.length;
          final max = s.taps.isEmpty ? 0.0 : s.taps.reduce((a, b) => a > b ? a : b);
          return '${m.name.padRight(8)} ${s.fps.round().toString().padLeft(3)}  '
              '${f(Stats.pct(s.total, .5)).padLeft(5)}/${f(Stats.pct(s.total, .95)).padRight(5)}  '
              '${f(Stats.pct(s.raster, .95)).padLeft(6)}      '
              '${f(avg).padLeft(5)}/${f(max).padRight(5)} ${s.taps.length}';
        }(),
    ];
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final l in lines) Text(l, style: style),
          const SizedBox(height: 4),
          Row(
            children: [
              _small('MODE', _cycleMode),
              _small('STRENGTH', () => setState(() => _strength = _strength >= 1.0 ? 0.3 : _strength + 0.35)),
              _small('RESET', () => setState(() {
                    for (final s in _stats.values) {
                      s.clear();
                    }
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
              Text(_fmt(_total),
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

  Widget _setRow(int i, TextStyle mono) {
    const last = [(60.0, 'WARMUP'), (100.0, 'IDEAL'), (100.0, 'IDEAL'), (80.0, 'IDEAL')];
    final t = i < _today.length ? _today[i] : null;
    return SizedBox(
      height: 22,
      child: Row(
        children: [
          SizedBox(width: 28, child: Text('S${i + 1}', style: mono)),
          Expanded(child: Text('${_fmt(last[i].$1)} ${last[i].$2}', style: mono)),
          Expanded(
            child: Text(
              t == null ? (i == _today.length ? '▸ NOW' : '—') : '${_fmt(t.$1)} ${t.$2}',
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

  Widget _grade(String g, {bool filled = false, required double height}) => Listener(
        onPointerDown: (e) => _logSet(e, g),
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? _ember : Colors.transparent,
            border: Border.all(color: _ember, width: 2),
          ),
          child: Text(g,
              style: TextStyle(
                fontFamily: filled ? 'serif' : 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: filled ? 20 : 11,
                letterSpacing: filled ? 4 : 0.5,
                color: filled ? _obsidian : _bright,
              )),
        ),
      );

  String _fmt(double v) => v == v.roundToDouble() ? v.round().toString() : v.toString();
}
