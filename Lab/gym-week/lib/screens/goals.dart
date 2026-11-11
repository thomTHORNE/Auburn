// Goals: drafting one, making it active, its chart and gap, reaching, abandoning, and frozen records.
// Behaviour: Spec/Features/Goals.md. Targets sit on exercises only here; cardio is not in the prototype.
import 'package:flutter/material.dart';

import '../logic.dart';
import '../model.dart';
import '../ui.dart';

String _targetLine(Target t) {
  final ex = store.exercise(t.exerciseId)?.name ?? '?';
  final value = t.parameter == Param.load ? '${fmtKg(t.value)} kg or more' : '${fmtKg(t.value)} reps or more';
  final min = t.parameter == Param.reps && t.minLoadKg != null ? ' at ${fmtKg(t.minLoadKg!)} kg or more' : '';
  return '$ex · $value$min · ${t.grades.map(gradeLabel).join(', ')}';
}

String _unit(Target t) => t.parameter == Param.load ? 'kg' : 'reps';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});
  @override
  Widget build(BuildContext context) => Live((context) {
        List<Goal> of(GoalState s) => store.goals.where((g) => g.state == s).toList();
        Widget row(Goal g) {
          final gap = goalGap(g).gap;
          return Entry(g.name.isEmpty ? 'Unnamed' : g.name,
              sub: g.target == null ? 'No target' : _targetLine(g.target!),
              trailing: g.state == GoalState.active && gap != null ? 'gap ${fmtKg(gap)}' : null,
              dim: g.ended,
              onTap: () => push(context, GoalScreen(goalId: g.id)));
        }

        return Screen(
          title: 'Goals',
          status: '${of(GoalState.active).length} active',
          bottom: KeyButton('New goal', onTap: () async {
            final name = await askText(context, 'New goal', hint: 'Something to reach', required: true);
            if (name == null || name.isEmpty) return;
            final g = Goal(name: name);
            store.goals.add(g);
            store.save();
            if (context.mounted) push(context, GoalScreen(goalId: g.id));
          }),
          children: [
            if (store.goals.isEmpty) const Para('No goals yet.'),
            for (final (state, title) in [(GoalState.active, 'Active'), (GoalState.draft, 'Drafts'), (GoalState.reached, 'Reached'), (GoalState.abandoned, 'Abandoned')])
              if (of(state).isNotEmpty) ...[Label(title), for (final g in of(state)) row(g)],
          ],
        );
      });
}

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key, required this.goalId});
  final String goalId;
  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  late final Goal? g0 = store.goal(widget.goalId);
  late final name = TextEditingController(text: g0?.name ?? '');
  late final explanation = TextEditingController(text: g0?.explanation ?? '');

  Future<void> _addExercise(Goal g) async {
    final options = store.exercises.where((e) => !e.archived && !g.exerciseIds.contains(e.id)).toList()..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final pick = await pickOne<Exercise>(context, 'Add an exercise', options, (e) => e.name);
    if (pick == null) return;
    g.exerciseIds.add(pick.id);
    store.save();
  }

  Future<void> _editTarget(Goal g) async {
    final own = [for (final id in g.exerciseIds) store.exercise(id)].nonNulls.where((e) => !e.archived).toList();
    if (own.isEmpty) {
      await confirm(context, 'Add an exercise first', note: 'A target sits on one of the goal\'s exercises.', yes: 'OK');
      return;
    }
    final t = g.target ?? Target(exerciseId: own.first.id);
    if (!own.any((e) => e.id == t.exerciseId)) t.exerciseId = own.first.id;
    final value = TextEditingController(text: t.value == 0 ? '' : fmtKg(t.value));
    final minLoad = TextEditingController(text: t.minLoadKg == null ? '' : fmtKg(t.minLoadKg!));
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        final v = double.tryParse(value.text.replaceAll(',', '.'));
        return Dialog(
          backgroundColor: graphite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: primaryC, width: 2)),
          insetPadding: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('TARGET', style: ts(14, spacing: 2)),
                const Label('Sits on'),
                Choice<Exercise>(options: own, label: (e) => e.name, isOn: (e) => e.id == t.exerciseId, onTap: (e) => setState(() => t.exerciseId = e.id)),
                const Label('Parameter'),
                Choice<Param>(options: Param.values, label: (p) => p == Param.load ? 'Load' : 'Reps, on a test', isOn: (p) => p == t.parameter, onTap: (p) => setState(() => t.parameter = p)),
                Label(t.parameter == Param.load ? 'Reached at · kg or more' : 'Reached at · reps or more'),
                Field(controller: value, number: true, onChanged: (_) => setState(() {})),
                const Label('Grades that count'),
                Choice<Grade>(options: Grade.values, label: gradeLabel, isOn: t.grades.contains, onTap: (gr) => setState(() => t.grades.contains(gr) ? t.grades.remove(gr) : t.grades.add(gr))),
                if (t.parameter == Param.reps) ...[
                  const Label('Least load that counts · kg, or empty'),
                  Field(controller: minLoad, number: true),
                ],
                const SizedBox(height: 16),
                KeyButton('Save target', filled: true, onTap: v == null || v <= 0 || t.grades.isEmpty ? null : () {
                  t.value = v;
                  t.minLoadKg = t.parameter == Param.reps ? double.tryParse(minLoad.text.replaceAll(',', '.')) : null;
                  g.target = t;
                  store.save();
                  Navigator.pop(ctx);
                }),
              ]),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _activate(Goal g) async {
    final why = cannotActivate(g);
    if (why != null) {
      await confirm(context, 'Not yet', note: why, yes: 'OK');
      return;
    }
    if (!await confirm(context, 'Make this goal active?', note: 'Nothing in it but its supporting exercises can change after. It ends only by being reached or abandoned.', yes: 'Make active')) return;
    g.state = GoalState.active;
    g.activatedAt = DateTime.now();
    store.save();
  }

  @override
  Widget build(BuildContext context) => Live((context) {
        final g = store.goal(widget.goalId);
        if (g == null) return const Screen(title: 'Goal', children: [Para('Deleted.')]);
        final t = g.target;
        final draft = g.state == GoalState.draft;
        final from = store.goal(g.fromGoalId);
        final successors = store.goals.where((x) => x.fromGoalId == g.id).toList();
        final exercises = [for (final id in g.exerciseIds) store.exercise(id)].nonNulls.toList();

        // The chart: the target's line by the target's rules, every other line by the grades shown.
        final parameter = g.shownParameter ?? t?.parameter ?? Param.load;
        final lines = <ChartLine>[];
        final legend = <(Exercise, Color, bool, bool)>[];
        var colour = 1;
        for (final e in exercises) {
          final isTarget = t != null && e.id == t.exerciseId;
          final hidden = !isTarget && g.hiddenExerciseIds.contains(e.id);
          final c = isTarget ? ember : [cyanWhite.withValues(alpha: 0.8), ember.withValues(alpha: 0.5), cyanWhite.withValues(alpha: 0.4)][(colour++) % 3];
          final points = exerciseLine(e.id, parameter, (s) => isTarget ? letsThrough(t, s) || (parameter != t.parameter && t.grades.contains(s.grade)) : g.shownGrades.contains(s.grade), until: g.endedAt);
          legend.add((e, c, isTarget, points.isEmpty));
          if (!hidden) lines.add(ChartLine(points, color: c, dashed: !isTarget));
        }
        final onTargetParam = t != null && parameter == t.parameter;
        final gap = goalGap(g);
        final days = g.activatedAt == null ? null : daysBetween(g.activatedAt!, g.endedAt ?? DateTime.now());

        return Screen(
          title: g.name.isEmpty ? 'Unnamed goal' : g.name,
          status: switch (g.state) {
            GoalState.draft => 'Draft · everything can change',
            GoalState.active => 'Active since ${fmtDay(g.activatedAt)} · day $days',
            GoalState.reached => 'Reached ${fmtDay(g.endedAt)} · $days days from active to reached',
            GoalState.abandoned => 'Abandoned ${fmtDay(g.endedAt)} · ran $days days',
          },
          bottom: switch (g.state) {
            GoalState.draft => Row(children: [
                Expanded(child: KeyButton('Delete', onTap: () async {
                  if (!await confirm(context, 'Delete this draft?', yes: 'Delete')) return;
                  store.goals.remove(g);
                  store.save();
                  if (context.mounted) Navigator.of(context).pop();
                })),
                const SizedBox(width: 8),
                Expanded(child: KeyButton('Make active', filled: true, onTap: () => _activate(g))),
              ]),
            GoalState.active => KeyButton('Abandon', onTap: () async {
                final why = await askText(context, 'Why is it abandoned?', lines: 3, required: true, note: 'The answer is kept on the goal and cannot be changed.');
                if (why == null || why.isEmpty) return;
                abandon(g, why);
                store.save();
              }),
            _ => KeyButton('Start a new goal from this one', onTap: () {
                final copy = copyGoal(g);
                store.save();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => GoalScreen(goalId: copy.id)));
              }),
          },
          children: [
            if (from != null) Entry('Started from · ${from.name}', onTap: () => push(context, GoalScreen(goalId: from.id))),
            for (final s in successors) Entry('Continued as · ${s.name}', onTap: () => push(context, GoalScreen(goalId: s.id))),
            if (g.state == GoalState.abandoned) ...[const Label('Why it was abandoned'), Para(g.abandonedBecause ?? '', apart: true)],
            if (draft) ...[
              const Label('Name'),
              Field(controller: name, onChanged: (v) {
                g.name = v.trim();
                store.save();
              }),
              const Label('What it is for, and how it is meant to be achieved'),
              Field(controller: explanation, lines: 3, hint: 'In your own words', onChanged: (v) {
                g.explanation = v;
                store.save();
              }),
            ] else if (g.explanation.isNotEmpty)
              Para(g.explanation, apart: true),
            const Label('Target'),
            if (t == null) const Para('None yet. A goal is made active with its target.') else Para(_targetLine(t), apart: true),
            if (draft) KeyButton(t == null ? 'Set the target' : 'Change the target', onTap: () => _editTarget(g)),
            if (t != null && !draft) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(border: Border.all(color: lineSecondary, width: 2)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(g.state == GoalState.reached ? 'REACHED' : 'GAP', style: ts(12, color: cyanWhite, bold: true)),
                  Text(
                      g.state == GoalState.reached
                          ? '${fmtKg(t.value)} ${_unit(t)} · ${fmtDay(t.reachedAt)}'
                          : gap.gap == null
                              ? 'NO POINT YET'
                              : '${fmtKg(gap.gap!)} ${_unit(t)} · BEST ${fmtKg(gap.from!)}'.toUpperCase(),
                      style: ts(12, color: cyanWhite)),
                ]),
              ),
            ],
            const Label('Chart'),
            Choice<Param>(options: Param.values, label: (p) => p == Param.load ? 'Load' : 'Reps, on tests', isOn: (p) => p == parameter, onTap: (p) {
              g.shownParameter = p;
              store.save();
            }),
            const SizedBox(height: 10),
            LineChart(lines: lines, target: onTargetParam ? t.value : null, markers: {if (g.activatedAt != null) 'ACTIVE': dayOf(g.activatedAt!)}),
            const SizedBox(height: 6),
            for (final (e, _, isTarget, empty) in legend)
              Entry(e.name,
                  glyph: isTarget ? '[T]' : (g.hiddenExerciseIds.contains(e.id) ? '[ ]' : '[x]'),
                  sub: [
                    if (isTarget) 'The target\'s · always shown' else if (g.hiddenExerciseIds.contains(e.id)) 'Hidden' else 'Shown',
                    if (empty) 'no points on this parameter',
                    if (e.archived) 'archived',
                  ].join(' · '),
                  trailing: !isTarget && !g.ended ? 'Remove' : null,
                  dim: !isTarget && g.hiddenExerciseIds.contains(e.id),
                  onTap: isTarget
                      ? null
                      : () async {
                          final act = await pickOne<String>(context, e.name, [g.hiddenExerciseIds.contains(e.id) ? 'Show its line' : 'Hide its line', if (!g.ended) 'Remove from the goal'], (s) => s);
                          if (act == null) return;
                          if (act.startsWith('Remove')) {
                            g.exerciseIds.remove(e.id);
                            g.hiddenExerciseIds.remove(e.id);
                          } else {
                            g.hiddenExerciseIds.contains(e.id) ? g.hiddenExerciseIds.remove(e.id) : g.hiddenExerciseIds.add(e.id);
                          }
                          store.save();
                        }),
            if (draft && t != null && g.exerciseIds.contains(t.exerciseId))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: KeyButton('Take the target\'s exercise out', size: 11, height: 40, onTap: () {
                  g.exerciseIds.remove(t.exerciseId);
                  store.save();
                }),
              ),
            const Label('Supporting lines · grades shown'),
            Choice<Grade>(options: Grade.values, label: gradeLabel, isOn: g.shownGrades.contains, onTap: (gr) {
              g.shownGrades.contains(gr) ? g.shownGrades.remove(gr) : g.shownGrades.add(gr);
              store.save();
            }),
            if (!g.ended) ...[const SizedBox(height: 14), KeyButton(draft ? 'Add an exercise' : 'Add a supporting exercise', onTap: () => _addExercise(g))],
          ],
        );
      });
}

/// A target is marked and not yet kept or undone: Auburn asks how to proceed, and cannot be dismissed.
Future<void> askOwedReaches(BuildContext context) async {
  for (final g in owedPrompts()) {
    final t = g.target!;
    final choice = await mustChoose<String>(
      context,
      'Target reached',
      '${g.name}\n${_targetLine(t)}\nReached ${fmtDay(t.reachedAt)}.',
      [('Keep it', 'keep'), ('Keep it, and start a new goal from this one', 'new'), ('Undo it', 'undo')],
    );
    if (choice == 'undo') {
      undoReach(g);
    } else {
      keepReach(g);
      if (choice == 'new') copyGoal(g);
    }
    store.save();
  }
}
