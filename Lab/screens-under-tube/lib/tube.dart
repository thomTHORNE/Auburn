// The tube: the CRT and glass shader from Lab/glass-that-moves, at the
// approved settings, run over whatever screen it wraps.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'basics.dart';

class Tube extends StatefulWidget {
  const Tube({super.key, required this.on, required this.child});

  final bool on;
  final Widget child;

  @override
  State<Tube> createState() => _TubeState();
}

class _TubeState extends State<Tube> with SingleTickerProviderStateMixin {
  ui.FragmentProgram? _program;
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
    _sensor = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen((e) {
      _ax = e.x;
      _ay = e.y;
      _restX ??= e.x;
      _restY ??= e.y;
    });
    // Ease toward the current tilt each frame, so the reflection glides.
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

  @override
  Widget build(BuildContext context) {
    final program = _program;
    if (!widget.on || program == null || !ui.ImageFilter.isShaderFilterSupported) return widget.child;
    final still = MediaQuery.of(context).disableAnimations;
    final shader = program.fragmentShader()
      ..setFloat(2, _elapsed.inMicroseconds / 1e6)
      ..setFloat(3, tubeStrength)
      ..setFloat(4, still ? 0.0 : 1.0)
      ..setFloat(5, 0.28 - (still ? 0 : _tx) * tubeTravel)
      ..setFloat(6, 0.14 + (still ? 0 : _ty) * tubeTravel)
      ..setFloat(7, tubeGlass);
    return ImageFiltered(imageFilter: ui.ImageFilter.shader(shader), child: widget.child);
  }
}
