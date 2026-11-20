// Plain parts built from the visual basics (Lens/Language/basics.css): the palette, the three emphasis
// levels and a 48 px tap area. No tube, no components from the canvas.
// A trial for the prototype only, not a design decision: Saira in place of Courier Prime, and secondary
// and supporting text at 70% in place of the basics' 42%, after Courier Prime read poorly in use.
import 'package:flutter/material.dart';

import 'logic.dart';
import 'model.dart';

const tube = Color(0xFF1A1D1A);
const obsidian = Color(0xFF121215);
const ember = Color(0xFFD9573B);
const cyanWhite = Color(0xFFDDF7F5);
const graphite = Color(0xFF212220);

final primaryC = ember.withValues(alpha: 0.9);
final secondaryC = cyanWhite.withValues(alpha: 0.7);
final supportingC = ember.withValues(alpha: 0.7);
final lineSecondary = ember.withValues(alpha: 0.55);
final lineSupporting = ember.withValues(alpha: 0.12);

TextStyle ts(double size, {Color? color, bool bold = false, double spacing = 1.2}) => TextStyle(
    fontFamily: 'Saira', fontSize: size, color: color ?? primaryC,
    fontWeight: bold ? FontWeight.w700 : FontWeight.w400, letterSpacing: spacing, height: 1.3);

/// Rebuilds whenever the store saves.
class Live extends StatelessWidget {
  const Live(this.builder, {super.key});
  final WidgetBuilder builder;
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: store, builder: (c, _) => builder(c));
}

Future<T?> push<T>(BuildContext context, Widget screen) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => screen));

class Screen extends StatelessWidget {
  const Screen({super.key, required this.title, this.status, required this.children, this.bottom, this.back = true});
  final String title;
  final String? status;
  final List<Widget> children;
  final Widget? bottom;
  final bool back;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: tube,
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
                if (back)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: SizedBox(height: 48, child: Center(widthFactor: 1, child: Text('< BACK', style: ts(12, color: supportingC, bold: true, spacing: 1.5)))),
                    ),
                  ),
                Text(title.toUpperCase(), style: ts(20, spacing: 3)),
                if (status != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(status!.toUpperCase(), style: ts(11, color: secondaryC, spacing: 1.5))),
                const SizedBox(height: 16),
                ...children,
              ]),
            ),
            if (bottom != null) Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: primaryC, width: 2))), padding: const EdgeInsets.all(12), child: bottom),
          ]),
        ),
      );
}

class Label extends StatelessWidget {
  const Label(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.only(top: 18, bottom: 6), child: Text(text.toUpperCase(), style: ts(11, color: supportingC, bold: true, spacing: 2)));
}

/// A list entry, marked with the entry glyph.
class Entry extends StatelessWidget {
  const Entry(this.label, {super.key, this.sub, this.trailing, this.onTap, this.dim = false, this.glyph = '>_'});
  final String label;
  final String? sub;
  final String? trailing;
  final VoidCallback? onTap;
  final bool dim;
  final String glyph;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: lineSupporting, width: 2))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(width: 30, child: Text(glyph, style: ts(12, color: secondaryC, spacing: 0))),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label.toUpperCase(), style: ts(14, color: dim ? secondaryC : primaryC, spacing: 1.6)),
                if (sub != null && sub!.isNotEmpty) Text(sub!.toUpperCase(), style: ts(10.5, color: secondaryC)),
              ]),
            ),
            if (trailing != null) Padding(padding: const EdgeInsets.only(left: 8), child: Text(trailing!.toUpperCase(), style: ts(11, color: cyanWhite.withValues(alpha: 0.8)))),
          ]),
        ),
      );
}

enum TagKind { gym, value, info, mark }

/// A badge on an exercise's second line. A gym is the most marked, since an exercise is offered only at its gyms.
class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.kind = TagKind.info});
  final String text;
  final TagKind kind;
  @override
  Widget build(BuildContext context) {
    final (border, fill, color, bold) = switch (kind) {
      TagKind.gym => (cyanWhite.withValues(alpha: 0.5), cyanWhite.withValues(alpha: 0.08), cyanWhite.withValues(alpha: 0.72), true),
      TagKind.value => (lineSecondary, null, primaryC, false),
      TagKind.info => (lineSupporting, null, secondaryC, false),
      TagKind.mark => (cyanWhite.withValues(alpha: 0.55), cyanWhite.withValues(alpha: 0.55), obsidian, true),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: fill, border: Border.all(color: border, width: 1.5)),
      child: Text(text.toUpperCase(), style: ts(10, color: color, bold: bold, spacing: 1)),
    );
  }
}

/// Every tag an exercise carries wherever it is offered: its gyms, its property values, unilateral, its load kind,
/// and, with [movers], its main movers.
List<Tag> exerciseTags(Exercise e, {bool movers = true}) => [
      for (final g in store.gyms)
        if (e.gymIds.contains(g.id)) Tag(g.name, kind: TagKind.gym),
      for (final v in valuesOf(e)) Tag(v.name, kind: TagKind.value),
      if (e.unilateral) const Tag('Unilateral', kind: TagKind.value),
      Tag(loadKindLabel(e.loadKind)),
      if (movers)
        for (final m in e.mainMovers) Tag(m.label),
      if (e.archived) const Tag('Archived', kind: TagKind.mark),
    ];

/// An exercise in a list: its name alone on the first line, every tag on the second.
class ExerciseEntry extends StatelessWidget {
  const ExerciseEntry(this.exercise, {super.key, this.before = const [], this.after = const [], this.movers = true, this.onTap, this.dim = false});
  final Exercise exercise;
  final List<Tag> before; // what the place it is shown in adds first, such as committed
  final List<Tag> after; // and after, such as its rest
  final bool movers;
  final VoidCallback? onTap;
  final bool dim;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: lineSupporting, width: 2))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(exercise.name.toUpperCase(), style: ts(14, color: dim ? secondaryC : primaryC, spacing: 1.6)),
            const SizedBox(height: 5),
            Wrap(spacing: 4, runSpacing: 4, children: [...before, ...exerciseTags(exercise, movers: movers), ...after]),
          ]),
        ),
      );
}

class KeyButton extends StatelessWidget {
  const KeyButton(this.label, {super.key, this.onTap, this.filled = false, this.on = false, this.height = 48, this.size = 13});
  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final bool on;
  final double height;
  final double size;

  @override
  Widget build(BuildContext context) {
    final solid = filled || on;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: solid ? ember : null, border: Border.all(color: onTap == null ? lineSupporting : lineSecondary, width: 2)),
        child: FittedBox(fit: BoxFit.scaleDown, child: Text(label.toUpperCase(), maxLines: 1, style: ts(size, color: solid ? obsidian : (onTap == null ? supportingC : primaryC), bold: solid, spacing: 1.5))),
      ),
    );
  }
}

/// A row of keys, one or several of which are on.
class Choice<T> extends StatelessWidget {
  const Choice({super.key, required this.options, required this.label, required this.isOn, required this.onTap});
  final List<T> options;
  final String Function(T) label;
  final bool Function(T) isOn;
  final void Function(T) onTap;
  @override
  Widget build(BuildContext context) => Wrap(spacing: 6, runSpacing: 6, children: [
        for (final o in options) IntrinsicWidth(child: KeyButton(label(o), on: isOn(o), onTap: () => onTap(o), height: 40, size: 11)),
      ]);
}

class Para extends StatelessWidget {
  const Para(this.text, {super.key, this.apart = false});
  final String text;
  final bool apart;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: ts(13, color: apart ? cyanWhite.withValues(alpha: 0.85) : secondaryC, spacing: 0.4)));
}

class Field extends StatelessWidget {
  const Field({super.key, required this.controller, this.hint, this.lines = 1, this.number = false, this.onChanged, this.autofocus = false});
  final TextEditingController controller;
  final String? hint;
  final int lines;
  final bool number;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        autofocus: autofocus,
        minLines: lines,
        maxLines: lines == 1 ? 1 : null,
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : (lines > 1 ? TextInputType.multiline : TextInputType.text),
        onChanged: onChanged,
        style: ts(14, color: cyanWhite, spacing: 0.4),
        cursorColor: ember,
        decoration: InputDecoration(
          hintText: hint, hintStyle: ts(14, color: secondaryC, spacing: 0.4), isDense: true,
          contentPadding: const EdgeInsets.all(10),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: lineSecondary, width: 2)),
          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: ember, width: 2)),
        ),
      );
}

Widget _sheet(BuildContext context, String title, List<Widget> children) => Dialog(
      backgroundColor: graphite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: primaryC, width: 2)),
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(title.toUpperCase(), style: ts(14, spacing: 2)),
            const SizedBox(height: 12),
            ...children,
          ]),
        ),
      ),
    );

/// Asks for text. With [required], it cannot be empty and cannot be dismissed with nothing.
Future<String?> askText(BuildContext context, String title, {String initial = '', String? hint, bool required = false, int lines = 1, bool number = false, String? note}) {
  final c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => _sheet(ctx, title, [
        if (note != null) Para(note),
        Field(controller: c, hint: hint, lines: lines, number: number, autofocus: true, onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: KeyButton('Cancel', onTap: () => Navigator.pop(ctx))),
          const SizedBox(width: 8),
          Expanded(child: KeyButton('OK', filled: true, onTap: required && c.text.trim().isEmpty ? null : () => Navigator.pop(ctx, c.text.trim()))),
        ]),
      ]),
    ),
  );
}

Future<bool> confirm(BuildContext context, String title, {String? note, String yes = 'Yes'}) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => _sheet(ctx, title, [
        if (note != null) Para(note, apart: true),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: KeyButton('Cancel', onTap: () => Navigator.pop(ctx, false))),
          const SizedBox(width: 8),
          Expanded(child: KeyButton(yes, filled: true, onTap: () => Navigator.pop(ctx, true))),
        ]),
      ]),
    ) ??
    false;

/// Picks one of a list. Returns null when dismissed.
Future<T?> pickOne<T>(BuildContext context, String title, List<T> options, String Function(T) label, {String Function(T)? sub}) => showDialog<T>(
      context: context,
      builder: (ctx) => _sheet(ctx, title, [
        if (options.isEmpty) const Para('Nothing to choose from.'),
        for (final o in options) Entry(label(o), sub: sub?.call(o), onTap: () => Navigator.pop(ctx, o)),
        const SizedBox(height: 12),
        KeyButton('Cancel', onTap: () => Navigator.pop(ctx)),
      ]),
    );

/// A dialog that cannot be dismissed: one of its keys must be taken.
Future<T> mustChoose<T>(BuildContext context, String title, String note, List<(String, T)> keys) async =>
    (await showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: _sheet(ctx, title, [
          Para(note, apart: true),
          const SizedBox(height: 8),
          for (final k in keys) Padding(padding: const EdgeInsets.only(top: 8), child: KeyButton(k.$1, filled: k == keys.first, onTap: () => Navigator.pop(ctx, k.$2))),
        ]),
      ),
    )) as T;

/// A number with keys either side of it.
class Stepper2 extends StatelessWidget {
  const Stepper2({super.key, required this.text, required this.onMinus, required this.onPlus});
  final String text;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  @override
  Widget build(BuildContext context) => Row(children: [
        SizedBox(width: 72, child: KeyButton('-', onTap: onMinus, height: 56, size: 22)),
        Expanded(child: Center(child: Text(text, style: ts(26, color: cyanWhite, spacing: 1)))),
        SizedBox(width: 72, child: KeyButton('+', onTap: onPlus, height: 56, size: 22)),
      ]);
}

/// The four steps of rest as a meter, with its word.
class RestMeter extends StatelessWidget {
  const RestMeter(this.reading, {super.key, this.showName = true});
  final RestReading reading;
  final bool showName;
  @override
  Widget build(BuildContext context) {
    final r = reading;
    final step = r.step;
    final word = step == null ? 'Not yet trained' : restStepLabels[step.index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(
          child: Text('${showName ? '${r.group.label} · ' : ''}${r.days == null ? '' : '${r.days} d · '}$word'.toUpperCase(),
              style: ts(11.5, color: step == RestStep.overdue ? cyanWhite : primaryC)),
        ),
        SizedBox(
          width: 84,
          child: Row(children: [
            for (var i = 0; i < 4; i++)
              Expanded(
                child: Container(
                  height: 7,
                  margin: const EdgeInsets.only(left: 3),
                  color: step != null && i <= step.index ? (step == RestStep.overdue ? cyanWhite : ember) : lineSupporting,
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}

class ChartLine {
  ChartLine(this.points, {this.color = ember, this.dashed = false, this.label = '', this.isTarget = false});
  final List<Point> points;
  final Color color;
  final bool dashed;
  final String label; // which exercise, and which side
  final bool isTarget; // the line the goal's target sits on
}

/// Progress only draws: lines of points over time, and a target line across them. Touching the chart selects the
/// point nearest the touch, on its line; dragging moves along that line. The readout opens the workout.
class LineChart extends StatefulWidget {
  const LineChart({super.key, required this.lines, this.target, this.markers = const {}, this.unit = 'kg', this.onOpen});
  final List<ChartLine> lines;
  final double? target;
  final Map<String, DateTime> markers;
  final String unit;
  final void Function(Workout)? onOpen;
  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  int? line, point; // the selection

  void _select(Offset at, Size size, {bool alongLine = false}) {
    final g = _Geometry(widget.lines, widget.target, size);
    double best = double.infinity;
    int? bl, bp;
    for (final (li, l) in widget.lines.indexed) {
      if (alongLine && li != line) continue;
      for (final (pi, p) in l.points.indexed) {
        final o = Offset(g.x(p.date), g.y(p.value));
        // Along a line, only the date decides; on a touch, the nearest point.
        final d = alongLine ? (o.dx - at.dx).abs() : (o - at).distance;
        if (d < best) {
          best = d;
          bl = li;
          bp = pi;
        }
      }
    }
    if (bl != null) {
      setState(() {
        line = bl;
        point = bp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.lines;
    if (lines.every((l) => l.points.isEmpty)) {
      return Container(height: 80, alignment: Alignment.center, decoration: BoxDecoration(border: Border.all(color: lineSupporting, width: 2)), child: Text('NO POINTS YET', style: ts(11, color: secondaryC)));
    }
    if (line != null && (line! >= lines.length || point! >= lines[line!].points.length)) line = point = null;
    final selected = line == null ? null : lines[line!].points[point!];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      LayoutBuilder(builder: (context, box) {
        final size = Size(box.maxWidth, 190);
        return GestureDetector(
          onTapDown: (d) => _select(d.localPosition, size),
          onHorizontalDragStart: (d) => _select(d.localPosition, size),
          onHorizontalDragUpdate: (d) => _select(d.localPosition, size, alongLine: true),
          child: SizedBox(height: 190, child: CustomPaint(painter: _ChartPainter(lines, widget.target, widget.markers, selected), size: size)),
        );
      }),
      if (selected != null) _readout(lines[line!], selected),
    ]);
  }

  Widget _readout(ChartLine l, Point p) {
    final s = p.set;
    final w = p.workout;
    final parts = [
      fmtDay(p.date),
      if (w != null) store.gym(w.gymId)?.name ?? '?',
      l.label,
      '${fmtKg(p.value)} ${widget.unit}',
      if (s != null) gradeLabel(s.grade),
      if (s != null && s.test) 'test ${s.reps} reps at ${fmtKg(s.loadKg)} kg',
      if (s?.side != null) sideLabel(s!.side!),
      'given ${p.given} of ${p.total} sets',
      if (l.isTarget && widget.target != null) p.value >= widget.target! ? 'at the target' : '${fmtKg(widget.target! - p.value)} ${widget.unit} from the target',
    ];
    return InkWell(
      onTap: w == null || widget.onOpen == null ? null : () => widget.onOpen!(w),
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(border: Border.all(color: lineSecondary, width: 2)),
        child: Row(children: [
          Expanded(child: Text(parts.join(' · ').toUpperCase(), style: ts(11, color: cyanWhite))),
          if (w != null && widget.onOpen != null) Text('  OPEN >', style: ts(11, color: primaryC, bold: true)),
        ]),
      ),
    );
  }
}

/// Where values and dates fall on the chart.
class _Geometry {
  _Geometry(List<ChartLine> lines, double? target, this.size) {
    final all = [for (final l in lines) ...l.points];
    lo = all.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    hi = all.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    if (target != null) {
      if (target > hi) hi = target;
      if (target < lo) lo = target;
    }
    if (hi == lo) {
      hi += 1;
      lo = lo > 1 ? lo - 1 : 0;
    }
    final pad = (hi - lo) * 0.1;
    hi += pad;
    lo = lo - pad < 0 && lo >= 0 ? 0 : lo - pad;
    t0 = all.map((p) => p.date).reduce((a, b) => a.isBefore(b) ? a : b);
    t1 = all.map((p) => p.date).reduce((a, b) => a.isAfter(b) ? a : b);
    if (!t1.isAfter(t0)) {
      t0 = t0.subtract(const Duration(days: 1));
      t1 = t1.add(const Duration(days: 1));
    }
  }
  static const left = 38.0, right = 8.0, top = 12.0, bottom = 22.0;
  final Size size;
  late double lo, hi;
  late DateTime t0, t1;
  double x(DateTime d) => left + (d.difference(t0).inSeconds / t1.difference(t0).inSeconds).clamp(0.0, 1.0) * (size.width - left - right);
  double y(double v) => top + (1 - (v - lo) / (hi - lo)) * (size.height - top - bottom);
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.lines, this.target, this.markers, this.selected);
  final List<ChartLine> lines;
  final double? target;
  final Map<String, DateTime> markers;
  final Point? selected;

  @override
  void paint(Canvas canvas, Size size) {
    final g = _Geometry(lines, target, size);
    const left = _Geometry.left, right = _Geometry.right, top = _Geometry.top, bottom = _Geometry.bottom;
    final lo = g.lo, hi = g.hi, t0 = g.t0, t1 = g.t1;
    final x = g.x, y = g.y;

    void text(String s, Offset at, {Color? color, TextAlign align = TextAlign.left}) {
      final tp = TextPainter(text: TextSpan(text: s, style: ts(9.5, color: color ?? secondaryC, spacing: 0.5)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, align == TextAlign.right ? at - Offset(tp.width, 0) : at);
    }

    final grid = Paint()..color = lineSupporting..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final v = lo + (hi - lo) * i / 3;
      canvas.drawLine(Offset(left, y(v)), Offset(size.width - right, y(v)), grid);
      text(fmtKg(double.parse(v.toStringAsFixed(1))), Offset(left - 5, y(v) - 6), align: TextAlign.right);
    }
    text(fmtDay(t0), Offset(left, size.height - 14));
    text(fmtDay(t1), Offset(size.width - right, size.height - 14), align: TextAlign.right);

    void dashedLine(Offset a, Offset b, Paint p) {
      final len = (b - a).distance;
      final dir = (b - a) / len;
      for (var d = 0.0; d < len; d += 9) {
        canvas.drawLine(a + dir * d, a + dir * (d + 5 > len ? len : d + 5), p);
      }
    }

    markers.forEach((name, date) {
      if (date.isBefore(t0) || date.isAfter(t1)) return;
      dashedLine(Offset(x(date), top), Offset(x(date), size.height - bottom), Paint()..color = cyanWhite.withValues(alpha: 0.3)..strokeWidth = 1);
      text(name, Offset(x(date) + 3, size.height - bottom - 13), color: cyanWhite.withValues(alpha: 0.6));
    });
    if (target != null) {
      dashedLine(Offset(left, y(target!)), Offset(size.width - right, y(target!)), Paint()..color = cyanWhite.withValues(alpha: 0.8)..strokeWidth = 1.5);
      text('TARGET ${fmtKg(target!)}', Offset(size.width - right, y(target!) - 13), color: cyanWhite.withValues(alpha: 0.8), align: TextAlign.right);
    }
    for (final l in lines) {
      final paint = Paint()..color = l.color..strokeWidth = 2..style = PaintingStyle.stroke;
      for (var i = 1; i < l.points.length; i++) {
        final a = Offset(x(l.points[i - 1].date), y(l.points[i - 1].value));
        final b = Offset(x(l.points[i].date), y(l.points[i].value));
        l.dashed ? dashedLine(a, b, paint) : canvas.drawLine(a, b, paint);
      }
      for (final p in l.points) {
        canvas.drawCircle(Offset(x(p.date), y(p.value)), 2.6, Paint()..color = l.color);
      }
    }
    if (selected != null) {
      final at = Offset(x(selected!.date), y(selected!.value));
      canvas.drawLine(Offset(at.dx, top), Offset(at.dx, size.height - bottom), Paint()..color = cyanWhite.withValues(alpha: 0.5)..strokeWidth = 1);
      canvas.drawCircle(at, 6, Paint()..color = cyanWhite..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

const gradeLabels = ['Ideal', 'Acceptable', 'Light', 'Yielding', 'Warmup'];
String gradeLabel(Grade? g) => g == null ? 'Ungraded' : gradeLabels[g.index];
String sideLabel(Side s) => s == Side.left ? 'Left' : 'Right';
String setLine(LoggedSet s) => '${s.side == null ? '' : '${sideLabel(s.side!)} · '}${fmtKg(s.loadKg)} kg · ${gradeLabel(s.grade)}${s.test ? ' · test ${s.reps ?? '?'} reps' : ''}';

/// Keys for every property value, grouped by property; tapping one turns it on or off.
class ValueFilter extends StatelessWidget {
  const ValueFilter({super.key, required this.on, required this.onToggle});
  final Set<String> on;
  final void Function(String valueId) onToggle;
  @override
  Widget build(BuildContext context) {
    final props = store.properties.where((p) => store.propertyValues.any((v) => v.propertyId == p.id)).toList();
    if (props.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final p in props) ...[
          Padding(padding: const EdgeInsets.only(top: 4, bottom: 4), child: Text(p.name.toUpperCase(), style: ts(10, color: secondaryC))),
          Choice<PropertyValue>(
            options: store.propertyValues.where((v) => v.propertyId == p.id).toList(),
            label: (v) => v.name,
            isOn: (v) => on.contains(v.id),
            onTap: (v) => onToggle(v.id),
          ),
        ],
      ]),
    );
  }
}

/// Keys for every gym; tapping one turns it on or off. An exercise passes when it is tied to one that is on.
class GymFilter extends StatelessWidget {
  const GymFilter({super.key, required this.on, required this.onToggle});
  final Set<String> on;
  final void Function(String gymId) onToggle;
  @override
  Widget build(BuildContext context) {
    final gyms = store.gyms.where((g) => !g.archived).toList();
    if (gyms.length < 2) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('GYM', style: ts(10, color: secondaryC))),
        Choice<Gym>(options: gyms, label: (g) => g.name, isOn: (g) => on.contains(g.id), onTap: (g) => onToggle(g.id)),
      ]),
    );
  }
}

bool passesGyms(Exercise e, Set<String> gymIds) => gymIds.isEmpty || gymIds.any(e.gymIds.contains);

/// Keys for every muscle group some exercise names as a main mover. An exercise passes when one of those on is its
/// main mover.
class MuscleFilter extends StatelessWidget {
  const MuscleFilter({super.key, required this.on, required this.onToggle});
  final Set<MuscleGroup> on;
  final void Function(MuscleGroup) onToggle;
  @override
  Widget build(BuildContext context) {
    final named = {for (final e in store.exercises) ...e.mainMovers};
    final groups = MuscleGroup.values.where(named.contains).toList();
    if (groups.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('MAIN MOVER', style: ts(10, color: secondaryC))),
        Choice<MuscleGroup>(options: groups, label: (g) => g.label, isOn: on.contains, onTap: onToggle),
      ]),
    );
  }
}

bool passesMuscles(Exercise e, Set<MuscleGroup> groups) => groups.isEmpty || groups.any(e.mainMovers.contains);

/// Picks one exercise, with the property filter above the list. Returns null when dismissed.
Future<Exercise?> pickExercise(BuildContext context, String title, List<Exercise> options) {
  final on = <String>{};
  options.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return showDialog<Exercise>(
    context: context,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
      final shown = options.where((e) => passesFilter(e, on)).toList();
      return _sheet(ctx, title, [
        ValueFilter(on: on, onToggle: (id) => setState(() => on.contains(id) ? on.remove(id) : on.add(id))),
        if (shown.isEmpty) const Para('Nothing to choose from.'),
        for (final e in shown) ExerciseEntry(e, onTap: () => Navigator.pop(ctx, e)),
        const SizedBox(height: 12),
        KeyButton('Cancel', onTap: () => Navigator.pop(ctx)),
      ]);
    }),
  );
}
String loadKindLabel(LoadKind k) => const ['Plates', 'Stack', 'Dumbbells', 'Bodyweight'][k.index];

