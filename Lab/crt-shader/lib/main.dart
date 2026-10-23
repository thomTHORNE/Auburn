// Lab probe: CRT shader over Flutter. Throwaway code — see Lab/Log.md.
//
// Question: can Flutter run a custom fragment shader over the whole rendered
// screen on the Fold 8 while taps still answer within one frame?
//
// Modes, cycled from the readout:
//   OFF      no shader — the baseline.
//   FILTER   path A: ImageFilter.shader over the screen (Impeller only).
//   LITE     path A with a cheaper shader: half the bloom taps, one-octave smudge.
//   STILL    path A, nothing animated: the clock stops and frames are drawn only
//            when something changes, as on a real logging screen.
//   SAMPLER  path B: flutter_shaders' AnimatedSampler — snapshot, then shade.

import 'dart:developer' show Timeline;
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

enum Mode { off, filter, lite, still, sampler }

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

  // Frame rate counts only the mode's current run, so time spent in other
  // modes does not dilute it.
  int? runFirstUs;
  int? runLastUs;
  int runFrames = 0;

  void startRun() {
    runFirstUs = null;
    runLastUs = null;
    runFrames = 0;
  }

  void clear() {
    total.clear();
    raster.clear();
    taps.clear();
    startRun();
  }

  double get fps {
    if (runFirstUs == null || runLastUs == null || runLastUs == runFirstUs) return 0;
    return (runFrames - 1) / ((runLastUs! - runFirstUs!) / 1e6);
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
  ui.FragmentProgram? _lite;
  Mode _mode = Mode.off;
  static const _strengths = [0.3, 0.6, 1.0];
  int _strengthIndex = 2;
  double get _strength => _strengths[_strengthIndex];
  final _stats = {for (final m in Mode.values) m: Stats()};

  /// Per tap, keyed by the build-start timestamp of the frame that shows it:
  /// milliseconds from the tap handler to that frame's build finishing, on the
  /// app's own clock. The raster part is added from the frame's own timings.
  final _pendingTaps = <int, double>{};
  int _tapsSent = 0;
  int _tapsMatched = 0;

  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;

  // Stand-in screen state.
  final _plates = <double>[20, 10, 10];
  final _today = <(double, String)>[(60, 'WARMUP'), (100, 'IDEAL')];
  String? _pressed;

  @override
  void initState() {
    super.initState();
    ui.FragmentProgram.fromAsset('shaders/crt.frag').then((p) => setState(() => _program = p));
    ui.FragmentProgram.fromAsset('shaders/crt_lite.frag').then((p) => setState(() => _lite = p));
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
      s.runFirstUs ??= finish;
      s.runLastUs = finish;
      s.runFrames++;
      final toBuild = _pendingTaps.remove(t.timestampInMicroseconds(ui.FramePhase.buildStart));
      if (toBuild != null) {
        // Tap handler → build done (app clock) + build done → raster done (frame clock).
        final ms = toBuild + (finish - t.timestampInMicroseconds(ui.FramePhase.buildFinish)) / 1000;
        s.taps.add(ms);
        _tapsMatched++;
      }
    }
  }

  /// Grades log on pointer down and record when the tap landed.
  void _logSet(PointerDownEvent e, String grade) {
    final start = Timeline.now;
    _tapsSent++;
    setState(() {
      _today.add((_total, grade));
      _pressed = grade;
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _pendingTaps[SchedulerBinding.instance.currentSystemFrameTimeStamp.inMicroseconds] =
          (Timeline.now - start) / 1000;
    });
  }

  double get _total => 20 + 2 * _plates.fold<double>(0, (a, p) => a + p);

  void _cycleMode() => setState(() {
        _mode = Mode.values[(_mode.index + 1) % Mode.values.length];
        if (_mode != Mode.off && _mode != Mode.sampler && !ui.ImageFilter.isShaderFilterSupported) {
          _mode = Mode.sampler;
        }
        _stats[_mode]!.startRun();
        // STILL stops the clock, so frames are drawn only when something changes.
        if (_mode == Mode.still) {
          _ticker.stop();
        } else if (!_ticker.isActive) {
          _ticker.start();
        }
      });

  @override
  Widget build(BuildContext context) {
    final screen = _standIn();
    final program = _mode == Mode.lite ? _lite : _program;
    final time = _elapsed.inMicroseconds / 1e6;
    final animate = _mode == Mode.still ? 0.0 : 1.0;

    Widget shaded = screen;
    if (program != null && (_mode == Mode.filter || _mode == Mode.lite || _mode == Mode.still)) {
      final shader = program.fragmentShader()
        ..setFloat(2, time)
        ..setFloat(3, _strength)
        ..setFloat(4, animate);
      shaded = ImageFiltered(imageFilter: ui.ImageFilter.shader(shader), child: screen);
    } else if (program != null && _mode == Mode.sampler) {
      shaded = AnimatedSampler((image, size, canvas) {
        final shader = program.fragmentShader()
          ..setFloat(0, size.width)
          ..setFloat(1, size.height)
          ..setFloat(2, time)
          ..setFloat(3, _strength)
          ..setFloat(4, animate)
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
          final fps = m == Mode.still ? '  —' : s.fps.round().toString().padLeft(3);
          return '${m.name.padRight(8)} $fps  '
              '${f(Stats.pct(s.total, .5)).padLeft(5)}/${f(Stats.pct(s.total, .95)).padRight(5)}  '
              '${f(Stats.pct(s.raster, .95)).padLeft(6)}      '
              '${f(avg).padLeft(5)}/${f(max).padRight(5)} ${s.taps.length}';
        }(),
      'TAPS sent $_tapsSent · measured $_tapsMatched',
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
              _small('STRENGTH', () => setState(() => _strengthIndex = (_strengthIndex + 1) % _strengths.length)),
              _small('RESET', () => setState(() {
                    for (final s in _stats.values) {
                      s.clear();
                    }
                    _tapsSent = 0;
                    _tapsMatched = 0;
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
