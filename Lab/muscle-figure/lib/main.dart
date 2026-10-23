// Lab sketch: Muscle figure regions. Throwaway code — see Lab/Log.md.
//
// Question: on the Fold cover screen, can the 20 muscle groups, drawn as
// regions on a front and a back figure, be told apart and tapped one-handed,
// both when an exercise lights its groups and when every group is tinted by
// its rest band?
//
// The regions are placeholders in assets/figure.svg — one path per muscle
// group per view, the structure the traced Albinus art will keep. Everything
// runs under the CRT and glass shader at the settings the earlier Lab
// attempts settled on.

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() => runApp(const SketchApp());

const _tube = Color(0xFF1A1D1A);
const _ember = Color(0xFFD9573B);
const _text = Color(0xFFC8C3B0);
const _cyanWhite = Color(0xFFDDF7F5);
const _ink = Color(0xFF241A16);

// From the glass sketch's verdict: strength 0.6, glass LOW, travel SMALL.
const _strength = 0.6;
const _glass = 0.6;
const _travel = 0.35;

const _groups = [
  'chest', 'front_delts', 'side_delts', 'rear_delts', 'biceps', 'triceps', //
  'forearms', 'lats', 'upper_back', 'traps', 'lower_back', 'abs', 'obliques',
  'quads', 'hamstrings', 'glutes', 'calves', 'adductors', 'abductors', 'neck',
];

String _label(String id) => id.replaceAll('_', ' ').toUpperCase();

/// Placeholder exercises with guessed muscle groups — stand-ins, not the
/// user's own ticks.
const _exercises = <(String, List<String>)>[
  ('—', []),
  ('CHEST PRESS : BAR', ['chest', 'front_delts', 'triceps']),
  ('LATERAL RAISE', ['side_delts']),
  ('REVERSE FLY', ['rear_delts', 'upper_back']),
  ('LOW ROW : CABLE', ['lats', 'upper_back', 'rear_delts', 'biceps']),
  ('SHRUG', ['traps']),
  ('ROMANIAN DEADLIFT', ['hamstrings', 'glutes', 'lower_back']),
  ('SQUAT : BAR', ['quads', 'glutes', 'adductors']),
  ('LEG CURL', ['hamstrings']),
  ('CALF', ['calves']),
  ('AB CRUNCH', ['abs']),
  ('BICEP CURL', ['biceps', 'forearms']),
  ('TRICEP EXTENSION', ['triceps']),
  ('HIP ABDUCTION', ['abductors']),
  ('WOODCHOP', ['obliques']),
  ('NECK CURL', ['neck']),
];

/// Rest bands: repair, maybe, train, overdue.
const _bands = [
  ('REPAIR', Color(0xFFB3261E)),
  ('MAYBE', Color(0xFF3E7BD6)),
  ('TRAIN', Color(0xFF4C9A52)),
  ('OVERDUE', Color(0xFFF29B38)),
];

class _Region {
  _Region(this.view, this.id, this.path);
  final String view;
  final String id;
  final Path path;
}

class SketchApp extends StatelessWidget {
  const SketchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auburn · Muscle figure sketch',
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
  List<_Region> _regions = [];

  String _view = 'front';
  int _exercise = 0;
  bool _rest = false;
  final _random = Random();
  Map<String, int> _restBands = {};
  String? _tapped;

  // Tap test: the app names a group, the user taps it.
  static const _rounds = 20;
  List<String> _testQueue = [];
  int _hits = 0;
  final _misses = <String>[];
  String? get _asked => _testQueue.isEmpty ? null : _testQueue.first;

  // Tilt drives the glass, as in the glass sketch.
  StreamSubscription<AccelerometerEvent>? _sensor;
  double _ax = 0, _ay = 0;
  double? _restX, _restY;
  double _tx = 0, _ty = 0;
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    ui.FragmentProgram.fromAsset('shaders/glass.frag').then((p) => setState(() => _program = p));
    rootBundle.loadString('assets/figure.svg').then((svg) => setState(() => _regions = _parse(svg)));
    _sensor = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen((e) {
      _ax = e.x;
      _ay = e.y;
      _restX ??= e.x;
      _restY ??= e.y;
    });
    _ticker = createTicker((d) {
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
    super.dispose();
  }

  static List<_Region> _parse(String svg) {
    final re = RegExp(r'<path id="([^"]+)" data-view="(front|back)" d="([^"]+)"');
    return [for (final m in re.allMatches(svg)) _Region(m[2]!, m[1]!, parseSvgPathData(m[3]!))];
  }

  bool _onView(String group, String view) => _regions.any((r) => r.view == view && r.id == group);

  void _toggleRest() => setState(() {
        _rest = !_rest;
        _restBands = {for (final g in _groups) g: _random.nextInt(_bands.length)};
      });

  void _startTest() => setState(() {
        _testQueue = [..._groups]..shuffle(_random);
        _hits = 0;
        _misses.clear();
        _showAsked();
      });

  // Turn the figure to a side that shows the asked group.
  void _showAsked() {
    final g = _asked;
    if (g != null && !_onView(g, _view)) _view = _view == 'front' ? 'back' : 'front';
  }

  void _onTap(String? id) => setState(() {
        _tapped = id;
        final asked = _asked;
        if (asked == null) return;
        if (id == asked) {
          _hits++;
        } else {
          _misses.add('${_label(asked)}→${id == null ? 'NOTHING' : _label(id)}');
        }
        _testQueue.removeAt(0);
        _showAsked();
      });

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.of(context).disableAnimations;
    final screen = _screen();
    final program = _program;
    Widget shaded = screen;
    if (program != null && ui.ImageFilter.isShaderFilterSupported) {
      final shader = program.fragmentShader()
        ..setFloat(2, _elapsed.inMicroseconds / 1e6)
        ..setFloat(3, _strength)
        ..setFloat(4, still ? 0.0 : 1.0)
        ..setFloat(5, 0.28 - (still ? 0 : _tx) * _travel)
        ..setFloat(6, 0.14 + (still ? 0 : _ty) * _travel)
        ..setFloat(7, _glass);
      shaded = ImageFiltered(imageFilter: ui.ImageFilter.shader(shader), child: screen);
    }
    return Scaffold(body: SafeArea(child: shaded));
  }

  Widget _screen() {
    final lit = _exercises[_exercise].$2.toSet();
    final testing = _asked != null;
    final String status;
    if (testing) {
      status = 'TAP ${_label(_asked!)}   ${_rounds - _testQueue.length + 1}/$_rounds';
    } else if (_misses.isNotEmpty || _hits > 0) {
      status = 'TEST $_hits/$_rounds${_misses.isEmpty ? '' : '  MISSED ${_misses.join(' · ')}'}';
    } else {
      status = 'TAPPED ${_tapped == null ? '—' : _label(_tapped!)}';
    }

    return Container(
      color: _tube,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            _button(_exercises[_exercise].$1, () => setState(() => _exercise = (_exercise + 1) % _exercises.length), flex: 3),
            _button(_rest ? 'REST ON' : 'REST', _toggleRest),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            _button(_view == 'front' ? 'FRONT ▸ BACK' : 'BACK ▸ FRONT',
                () => setState(() => _view = _view == 'front' ? 'back' : 'front'),
                flex: 2),
            _button(testing ? 'TESTING' : 'TAP TEST', testing ? null : _startTest),
          ]),
          const SizedBox(height: 8),
          Text(status, style: const TextStyle(fontFamily: 'monospace', color: _cyanWhite, fontSize: 13)),
          if (_rest)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(spacing: 10, children: [
                for (final b in _bands)
                  Text('■ ${b.$1}', style: TextStyle(fontFamily: 'monospace', color: b.$2, fontSize: 12)),
              ]),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _regions.isEmpty
                ? const SizedBox()
                : LayoutBuilder(builder: (context, box) {
                    final painter = _FigurePainter(
                      regions: _regions.where((r) => r.view == _view).toList(),
                      lit: testing ? const {} : lit,
                      restBands: _rest && !testing ? _restBands : const {},
                      tapped: testing ? null : _tapped,
                    );
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => _onTap(painter.hit(d.localPosition, box.biggest)),
                      child: CustomPaint(size: box.biggest, painter: painter),
                    );
                  }),
          ),
        ],
      ),
    );
  }

  Widget _button(String label, VoidCallback? onTap, {int flex = 1}) => Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(border: Border.all(color: _text, width: 1.2)),
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'monospace', color: _text, fontSize: 13)),
            ),
          ),
        ),
      );
}

class _FigurePainter extends CustomPainter {
  _FigurePainter({required this.regions, required this.lit, required this.restBands, required this.tapped});

  final List<_Region> regions;
  final Set<String> lit;
  final Map<String, int> restBands;
  final String? tapped;

  static const _box = Size(200, 400);

  /// Scale and offset that fit the 200×400 figure into the canvas.
  (double, Offset) _fit(Size size) {
    final s = min(size.width / _box.width, size.height / _box.height);
    return (s, Offset((size.width - _box.width * s) / 2, (size.height - _box.height * s) / 2));
  }

  /// Regions are listed largest first, so the last one containing the point
  /// is the smallest — the one a finger on a small group means.
  String? hit(Offset p, Size size) {
    final (s, o) = _fit(size);
    final q = (p - o) / s;
    for (final r in regions.reversed) {
      if (r.id != 'outline' && r.path.contains(q)) return r.id;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // The ember plate, as on the boot screen.
    canvas.drawRect(Offset.zero & size, Paint()..color = _ember);
    canvas.drawRect((Offset.zero & size).deflate(6),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = _ink.withValues(alpha: 0.7));

    final (s, o) = _fit(size);
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.scale(s);

    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = _ink;
    final hatch = Paint()
      ..strokeWidth = 0.35
      ..color = _ink.withValues(alpha: 0.55);

    for (final r in regions) {
      if (r.id == 'outline') {
        canvas.drawPath(r.path, ink..strokeWidth = 1.0);
        ink.strokeWidth = 0.7;
        continue;
      }
      final band = restBands[r.id];
      if (lit.contains(r.id)) {
        canvas.drawPath(r.path, Paint()..color = _cyanWhite);
      } else if (band != null) {
        canvas.drawPath(r.path, Paint()..color = _bands[band].$2.withValues(alpha: 0.85));
      }
      // Engraved hatching: diagonal strokes clipped to the region.
      canvas.save();
      canvas.clipPath(r.path);
      final b = r.path.getBounds();
      for (var x = b.left - b.height; x < b.right; x += 2.2) {
        canvas.drawLine(Offset(x, b.bottom), Offset(x + b.height, b.top), hatch);
      }
      canvas.restore();
      canvas.drawPath(
          r.path,
          r.id == tapped
              ? (Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.6
                ..color = _cyanWhite)
              : ink);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FigurePainter old) => true;
}
