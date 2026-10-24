// Screen 00, Boot — rebuilt from Spec/Visual Design/00-boot/screen.html.
// The timeline is the same fractions of the boot's 8 s as the CSS keyframes.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../basics.dart';
import '../sounds.dart';

const bootDuration = Duration(seconds: 8);

const _lines = [
  'More human than human.',
  'Introducing, the new You.',
  'Human, improved.',
  'Built better. By you.',
  'Engineered to endure.',
  'Strength is a protocol.',
  'Advancement is mandatory.',
  'Obsolescence is optional.',
  'Flesh: the first machine.',
];

class BootScreen extends StatefulWidget {
  const BootScreen({super.key, required this.dark, required this.replays});

  final bool dark;

  /// Bumped by the controls to play the boot again.
  final int replays;

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(vsync: this, duration: bootDuration);
  final _random = Random();
  int _line = -1;

  @override
  void initState() {
    super.initState();
    _play();
  }

  @override
  void didUpdateWidget(BootScreen old) {
    super.didUpdateWidget(old);
    if (old.replays != widget.replays) _play();
  }

  // A new line each boot, never the same as the last.
  void _play() {
    var next = _random.nextInt(_lines.length);
    if (next == _line) next = (next + 1) % _lines.length;
    setState(() => _line = next);
    _t.forward(from: 0);
    Sounds.instance.boot(bootDuration);
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  /// 0 → 1 between two fractions of the boot.
  double _span(double v, double from, double to, [Curve curve = Curves.linear]) =>
      curve.transform(((v - from) / (to - from)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final screen = widget.dark ? tube : ember;
    final wordmark = widget.dark ? ember : obsidian;
    final dot = widget.dark ? ember.withValues(alpha: 0.14 * 0.7) : obsidian.withValues(alpha: 0.10 * 0.7);
    final wordmarkWidth = widget.dark ? 220.0 : 200.0;

    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        final v = _t.value;
        // Power-on line: drawn 0–6%, gone by 12%.
        final lineScale = _span(v, 0, 0.06);
        final lineOpacity = 1 - _span(v, 0.06, 0.12);
        // The picture opens from the middle 6–15% and fades 85–100%.
        final open = _span(v, 0.06, 0.15);
        final fade = 1 - _span(v, 0.85, 1);
        final plate = _span(v, 0.09, 0.15);
        final rises = [
          _span(v, 0.15, 0.27, Curves.easeOut),
          _span(v, 0.21, 0.33, Curves.easeOut),
          _span(v, 0.27, 0.39, Curves.easeOut),
        ];
        final word = _span(v, 0.36, 0.51, Curves.easeOut);
        final quote = _flicker(v);

        return ColoredBox(
          color: screen,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: fade,
                child: ClipRect(
                  clipper: _OpenClipper(open),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(painter: _Dots(dot)),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Opacity(opacity: plate, child: _mark(rises, quote)),
                            const SizedBox(height: 14),
                            Opacity(
                              opacity: word,
                              child: Transform.scale(
                                scaleX: 1.12 - 0.12 * word,
                                child: SizedBox(
                                  width: wordmarkWidth,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      for (final c in 'AUBURN'.split(''))
                                        Text(c,
                                            style: GoogleFonts.gelasio(
                                                fontSize: 34, fontWeight: FontWeight.w700, height: 1, color: wordmark)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (lineOpacity > 0)
                Center(
                  child: Opacity(
                    opacity: lineOpacity,
                    child: Transform.scale(
                      scaleX: lineScale,
                      child: Container(height: 2, color: cyanWhite),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // The line flickers in: 45% off, 48% .6, 49.5% .15, 54% on.
  double _flicker(double v) {
    if (v < 0.45) return 0;
    if (v < 0.48) return 0.6 * _span(v, 0.45, 0.48);
    if (v < 0.495) return 0.6 - 0.45 * _span(v, 0.48, 0.495);
    if (v < 0.54) return 0.15 + 0.85 * _span(v, 0.495, 0.54);
    return 1;
  }

  Widget _mark(List<double> rises, double quote) {
    Widget pillar(String letter, double rise) => Expanded(
          child: Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.diagonal3Values(1, rise, 1),
            child: Container(
              color: obsidian,
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(letter,
                  style: GoogleFonts.saira(fontSize: 28, fontWeight: FontWeight.w300, height: 1, color: ember)),
            ),
          ),
        );

    return Container(
      width: 220,
      height: 264,
      color: ember,
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: obsidian, width: 2)),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: obsidian, width: 1)),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    pillar('H', rises[0]),
                    const SizedBox(width: 5),
                    pillar('C', rises[1]),
                    const SizedBox(width: 5),
                    pillar('M', rises[2]),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 26,
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: obsidian, width: 1))),
                alignment: Alignment.center,
                child: Opacity(
                  opacity: quote,
                  child: Text(
                    _line < 0 ? '' : _lines[_line].toUpperCase(),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    style: GoogleFonts.saira(
                        fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: obsidian),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clips the picture to a band around the middle that opens to full height.
class _OpenClipper extends CustomClipper<Rect> {
  _OpenClipper(this.open);
  final double open;

  @override
  Rect getClip(Size size) {
    final half = size.height / 2 * open;
    return Rect.fromLTRB(0, size.height / 2 - half, size.width, size.height / 2 + half);
  }

  @override
  bool shouldReclip(_OpenClipper old) => old.open != open;
}

/// The 9 px dot grid.
class _Dots extends CustomPainter {
  _Dots(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var y = 4.5; y < size.height; y += 9) {
      for (var x = 4.5; x < size.width; x += 9) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_Dots old) => old.color != color;
}
