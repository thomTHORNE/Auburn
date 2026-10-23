// The tube: the CRT and glass shader from Lab/glass-that-moves, at the
// approved settings, run over whatever screen it wraps.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'basics.dart';

class Tube extends StatefulWidget {
  const Tube({
    super.key,
    required this.on,
    required this.child,
    this.glass = tubeGlass,
    this.travel = tubeTravel,
    this.centers = 0,
    this.readout = false,
  });

  final bool on;
  final Widget child;

  /// Overrides for checking the glass; the approved values are the defaults.
  final double glass;
  final double travel;

  /// Bumped to take the phone's current pose as the resting one.
  final int centers;

  /// Shows what the tube is doing, outside the shader.
  final bool readout;

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
  void didUpdateWidget(Tube old) {
    super.didUpdateWidget(old);
    if (old.centers != widget.centers) {
      _restX = _ax;
      _restY = _ay;
    }
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
    final supported = ui.ImageFilter.isShaderFilterSupported;
    final still = MediaQuery.of(context).disableAnimations;
    final lightX = 0.28 - (still ? 0 : _tx) * widget.travel;
    final lightY = 0.14 + (still ? 0 : _ty) * widget.travel;
    Widget shown = widget.child;
    if (widget.on && program != null && supported) {
      final shader = program.fragmentShader()
        ..setFloat(2, _elapsed.inMicroseconds / 1e6)
        ..setFloat(3, tubeStrength)
        ..setFloat(4, still ? 0.0 : 1.0)
        ..setFloat(5, lightX)
        ..setFloat(6, lightY)
        ..setFloat(7, widget.glass);
      shown = ImageFiltered(imageFilter: ui.ImageFilter.shader(shader), child: widget.child);
    }
    if (!widget.readout) return shown;
    String f(double v) => v.toStringAsFixed(2);
    final status = !widget.on
        ? 'TUBE OFF'
        : program == null
            ? 'SHADER LOADING'
            : supported
                ? 'SHADER ON'
                : 'SHADER UNSUPPORTED';
    return Stack(fit: StackFit.expand, children: [
      shown,
      Positioned(
        left: 8,
        right: 8,
        bottom: 8,
        child: Container(
          color: const Color(0xD9000000),
          padding: const EdgeInsets.all(6),
          child: Text(
            '$status · GLASS ${f(widget.glass)} · TRAVEL ${f(widget.travel)}${still ? ' · REDUCED MOTION: GLASS STILL' : ''}\n'
            'TILT x ${f(_tx)} y ${f(_ty)} · LIGHT x ${f(lightX)} y ${f(lightY)}',
            style: const TextStyle(fontFamily: 'monospace', color: cyanWhite, fontSize: 11),
          ),
        ),
      ),
    ]);
  }
}
