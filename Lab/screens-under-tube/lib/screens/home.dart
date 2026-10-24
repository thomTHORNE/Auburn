// Screen 01, Navigation, round 2 — rebuilt from the canvas boards S01-R2-* before approval.
// Values: screen 01's manifest (hierarchy, covers) and the palette board's roles.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../basics.dart';
import '../sounds.dart';
import 'covers.dart';

// The palette roles from the palette board.
const _screen = tube;
const _list = Color(0xFF212220); // Trial A
const _power = tube;
const _ink = obsidian;

// The hierarchy levels from screen 01's manifest: Ember at an opacity.
Color _e(double a) => ember.withValues(alpha: a);
final _primaryText = _e(0.9);
final _secondaryText = _e(0.62);
final _supportingText = _e(0.42);
final _primaryLine = _e(0.9);
final _secondaryLine = _e(0.55);
final _supportingLine = _e(0.12);
final _light = cyanWhite.withValues(alpha: 0.9);

const _holdToFill = Duration(milliseconds: 1500);
const _drain = Duration(milliseconds: 300);

TextStyle _mono(double size, Color color, {FontWeight weight = FontWeight.w400, double spacing = 1.5, double height = 1.2}) =>
    GoogleFonts.courierPrime(fontSize: size, color: color, fontWeight: weight, letterSpacing: spacing, height: height);

enum _Widget { rest, goals, cardio }

const _entries = ['START WORKOUT', 'PAST WORKOUTS', 'EXERCISES', 'SPLITS AND GYMS', 'OVERDUE LOG', 'SETTINGS'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.workoutInProgress});

  final bool workoutInProgress;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _cursor = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  late final AnimationController _hold = AnimationController(vsync: this, duration: _holdToFill, reverseDuration: _drain)
    ..addStatusListener(_held);

  bool _listUp = false;
  _Widget? _editing;
  String? _standIn;

  // The widgets in reading order, and which are full width.
  final _order = [_Widget.rest, _Widget.goals, _Widget.cardio];
  final _full = {_Widget.rest};

  @override
  void initState() {
    super.initState();
    Sounds.instance.ensureAmbience();
  }

  @override
  void dispose() {
    _cursor.dispose();
    _hold.dispose();
    super.dispose();
  }

  void _held(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    Sounds.instance.powerDown();
    setState(() => _standIn = 'POWER DOWN\nSCREEN 16 IS NOT DESIGNED.\nAUBURN WOULD QUIT HERE.');
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _hold.value = 0;
    });
  }

  void _open(String target, String screen) => setState(() => _standIn = '$target\nSCREEN $screen IS NOT DESIGNED.');

  void _move(_Widget w, int by) {
    final i = _order.indexOf(w), j = i + by;
    if (j < 0 || j >= _order.length) return;
    setState(() {
      _order[i] = _order[j];
      _order[j] = w;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final h = box.maxHeight;
      const powerH = 52.0, handleH = 30.0, rowH = 42.0;
      final downTop = h - powerH - handleH - 3 * rowH;
      return ColoredBox(
        color: _screen,
        child: Stack(children: [
          // Layer 1: the content, which scrolls under the list.
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 18, 16, h - downTop + 16),
              child: _content(),
            ),
          ),
          // Layer 2: the list.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            top: _listUp ? 82 : downTop,
            bottom: powerH,
            child: _sheet(),
          ),
          // Layer 3: power down, always on top.
          Positioned(left: 0, right: 0, bottom: 0, height: powerH, child: _powerDown()),
          if (_standIn != null) Positioned.fill(child: _standInScreen()),
        ]),
      );
    });
  }

  Widget _content() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Text('AUBURN', style: GoogleFonts.gelasio(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 6, color: ember)),
        AnimatedBuilder(
          animation: _cursor,
          builder: (_, _) => Opacity(
            opacity: _cursor.value < 0.5 ? 1 : 0,
            child: Container(width: 11, height: 20, margin: const EdgeInsets.only(left: 2), color: ember),
          ),
        ),
      ]),
      const SizedBox(height: 10),
      Text('LAST WORKOUT · 2 DAYS AGO · CITY GYM', style: _mono(11, _secondaryText, weight: FontWeight.w700, spacing: 0.5)),
      const SizedBox(height: 14),
      ..._rows(),
    ]);
  }

  // Widgets flow in reading order: a full one takes a row, half ones pair up.
  List<Widget> _rows() {
    final rows = <Widget>[];
    final pending = <_Widget>[];
    void flush() {
      if (pending.isEmpty) return;
      rows.add(IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: _card(pending[0])),
          const SizedBox(width: 8),
          Expanded(child: pending.length > 1 ? _card(pending[1]) : const SizedBox()),
        ]),
      ));
      rows.add(const SizedBox(height: 8));
      pending.clear();
    }

    for (final w in _order) {
      if (_full.contains(w)) {
        flush();
        rows.add(_card(w));
        rows.add(const SizedBox(height: 8));
      } else {
        pending.add(w);
        if (pending.length == 2) flush();
      }
    }
    flush();
    return rows;
  }

  Widget _card(_Widget w) {
    final full = _full.contains(w);
    final editing = _editing == w;
    final dim = _editing != null && !editing;
    final (title, lines, target, screen) = switch (w) {
      _Widget.rest => ('REST AT A GLANCE', ['4 IN TRAIN · 2 OVERDUE', 'OVERDUE · QUADS, HAMSTRINGS'], 'REST AT A GLANCE', '02'),
      _Widget.goals => ('GOALS', ['5 GOALS', 'LATEST · PISTOL SQUAT'], 'GOALS', '11'),
      _Widget.cardio => ('CARDIO', ['3 DAYS SINCE LAST', 'LAST RUN · 8.2 KM'], 'CARDIO', 'NONE YET'),
    };
    final text = <Widget>[
      _titleChip(title),
      const SizedBox(height: 8),
      for (final l in lines) ...[
        Text(l, maxLines: 1, overflow: TextOverflow.ellipsis, style: _mono(11, _secondaryText, weight: FontWeight.w700, spacing: 0.5)),
        const SizedBox(height: 4),
      ],
    ];
    final body = full
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _cover(w, 96),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: text)),
            _editKey(w),
          ])
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [_cover(w, 72), const Spacer(), _editKey(w)]),
            const SizedBox(height: 7),
            ...text,
          ]);
    return Opacity(
      opacity: dim ? 0.42 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _editing == null ? () => _open(target, screen) : null,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(border: Border.all(color: editing ? _primaryLine : _supportingLine, width: editing ? 2 : 3)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [body, if (editing) _controls(w)]),
        ),
      ),
    );
  }

  Widget _cover(_Widget w, double size) {
    switch (w) {
      case _Widget.rest:
        return SizedBox(
          width: size,
          height: size,
          child: Stack(children: [
            SvgPicture.string(restFrameSvg, width: size, height: size),
            Positioned(
              left: size * 0.2,
              top: size * 0.08,
              width: size * 0.6,
              height: size * 0.86,
              child: Image.asset('assets/bust-ember.png', fit: BoxFit.contain, alignment: Alignment.topCenter),
            ),
          ]),
        );
      case _Widget.goals:
        return SvgPicture.string(goalsCoverSvg, width: size, height: size);
      case _Widget.cardio:
        return SvgPicture.string(cardioCoverSvg, width: size, height: size);
    }
  }

  // The widget's name on an Ember fill, in ink.
  Widget _titleChip(String t) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
          color: ember,
          child: Text(t, style: GoogleFonts.courierPrime(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 2, color: _ink, height: 11 / 13)),
        ),
      );

  // A 26 px key inside a 44 px tap area.
  Widget _editKey(_Widget w) {
    final editing = _editing == w;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _editing = editing ? null : w),
      child: SizedBox(
        width: 56,
        height: 44,
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: editing ? ember : null,
              border: Border.all(color: editing ? ember : _secondaryLine, width: 2),
            ),
            child: Text(editing ? 'DONE' : 'EDIT', style: _mono(10, editing ? _ink : _secondaryText, weight: FontWeight.w700, spacing: 1)),
          ),
        ),
      ),
    );
  }

  Widget _controls(_Widget w) {
    final full = _full.contains(w);
    // The whole key answers a tap, not only its label.
    Widget key(String label, VoidCallback onTap) => Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(border: Border.all(color: _secondaryLine, width: 2)),
              child: Text(label, style: _mono(13, _primaryText, weight: FontWeight.w700)),
            ),
          ),
        );
    Widget seg(String label, bool on, VoidCallback onTap) => Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              alignment: Alignment.center,
              color: on ? ember : null,
              child: Text(label, style: _mono(10, on ? _ink : _secondaryText, weight: FontWeight.w700, spacing: 1)),
            ),
          ),
        );
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(children: [
        key('▲', () => _move(w, -1)),
        const SizedBox(width: 6),
        key('▼', () => _move(w, 1)),
        const SizedBox(width: 6),
        Expanded(
          flex: 2,
          child: Container(
            height: 44,
            decoration: BoxDecoration(border: Border.all(color: _secondaryLine, width: 2)),
            child: Row(children: [
              seg('HALF', !full, () => setState(() => _full.remove(w))),
              seg('FULL', full, () => setState(() => _full.add(w))),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _sheet() {
    final entries = [widget.workoutInProgress ? 'RESUME WORKOUT' : _entries.first, ..._entries.skip(1)];
    return Container(
      decoration: BoxDecoration(color: _list, border: Border(top: BorderSide(color: _secondaryLine, width: 2))),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // The handle: tap or drag to raise and lower the list.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _listUp = !_listUp),
          onVerticalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v < -100) setState(() => _listUp = true);
            if (v > 100) setState(() => _listUp = false);
          },
          child: SizedBox(
            height: 30,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 40, height: 3, color: _supportingText),
              const SizedBox(width: 10),
              Text(_listUp ? 'HIDE' : '${entries.length - 3} MORE', style: _mono(10, _supportingText, weight: FontWeight.w700)),
            ]),
          ),
        ),
        Expanded(
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: double.infinity,
              child: Column(mainAxisSize: MainAxisSize.min, children: [for (final e in entries) _entry(e)]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _entry(String label) {
    final screen = switch (label) {
      'START WORKOUT' || 'RESUME WORKOUT' => '04',
      'PAST WORKOUTS' => '08',
      'EXERCISES' => '09',
      'SPLITS AND GYMS' => '13',
      'OVERDUE LOG' => '14',
      _ => '15',
    };
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _open(label, screen),
      child: Container(
        height: 42,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _supportingLine, width: 3))),
        child: Row(children: [
          CustomPaint(size: const Size(18, 18), painter: _GlyphC(_supportingText)),
          const SizedBox(width: 16),
          Text(label, style: _mono(16, _primaryText)),
        ]),
      ),
    );
  }

  // Press and hold: the fill crosses in 1.5 s and drains in 0.3 s if let go early.
  Widget _powerDown() {
    const label = 'POWER DOWN';
    const left = 50.0, size = 16.0, spacing = 1.5;
    const advance = size * 0.6 + spacing; // Courier Prime advances 0.6 em, plus the tracking.
    return LayoutBuilder(builder: (context, box) {
      return Listener(
        onPointerDown: (_) => _hold.forward(),
        onPointerUp: (_) {
          if (!_hold.isCompleted) _hold.reverse();
        },
        onPointerCancel: (_) {
          if (!_hold.isCompleted) _hold.reverse();
        },
        // Claims the long press, so the Lab's own long-press menu does not open over it.
        child: GestureDetector(
          onLongPress: () {},
          child: AnimatedBuilder(
            animation: _hold,
            builder: (_, _) {
              final fill = _hold.value * box.maxWidth;
              return Container(
                decoration: BoxDecoration(color: _power, border: Border(top: BorderSide(color: _secondaryLine, width: 2))),
                child: Stack(children: [
                  Positioned(left: 0, top: 0, bottom: 0, width: fill, child: const ColoredBox(color: ember)),
                  Positioned(
                    left: left,
                    top: 0,
                    bottom: 0,
                    child: Row(children: [
                      for (var i = 0; i < label.length; i++)
                        Text(label[i],
                            style: _mono(size, fill >= left + (i + 0.5) * advance ? _ink : _light, spacing: spacing)),
                    ]),
                  ),
                ]),
              );
            },
          ),
        ),
      );
    });
  }

  // Where a tap would go: the screen it opens is not designed yet.
  Widget _standInScreen() {
    return GestureDetector(
      onTap: () {
        if (_standIn!.startsWith('POWER DOWN')) Sounds.instance.afterPowerDown();
        setState(() => _standIn = null);
      },
      child: Container(
        color: _screen,
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_standIn!, textAlign: TextAlign.center, style: _mono(14, _primaryText, height: 1.6)),
          const SizedBox(height: 24),
          Text('TAP TO RETURN', style: _mono(11, _supportingText, weight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

/// Glyph C: a chevron and an underscore on a 24-unit grid, square ends and corners.
class _GlyphC extends CustomPainter {
  _GlyphC(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * k
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;
    canvas.drawPath(
      Path()
        ..moveTo(4 * k, 7 * k)
        ..lineTo(9 * k, 12 * k)
        ..lineTo(4 * k, 17 * k)
        ..moveTo(12 * k, 17 * k)
        ..lineTo(20 * k, 17 * k),
      p,
    );
  }

  @override
  bool shouldRepaint(_GlyphC old) => old.color != color;
}
