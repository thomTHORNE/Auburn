// Goals: drafting one from its target's exercise, its start answers, alternates and set limits, making it active,
// its chart and gap, reaching, abandoning, and frozen records.
// Behaviour: Spec/Features/Goals.md. Targets sit on exercises only here; cardio is not in the prototype.
import 'package:flutter/material.dart';

import '../logic.dart';
import '../model.dart';
import '../ui.dart';
import 'workout.dart';

const _sideWords = {TargetSide.left: 'left', TargetSide.right: 'right', TargetSide.both: 'both sides'};

String _targetLine(Target t) {
  final ex = store.exercise(t.exerciseId)?.name ?? '?';
  if (t.value <= 0) return '$ex · no value yet';
  final value = t.parameter == Param.load ? '${fmtKg(t.value)} kg or more' : '${fmtKg(t.value)} reps or more';
  final min = t.parameter == Param.reps && t.minLoadKg != null ? ' at ${fmtKg(t.minLoadKg!)} kg or more' : '';
  final side = t.side == null ? '' : ' · ${_sideWords[t.side]}';
  return '$ex$side · $value$min · ${t.grades.map(gradeLabel).join(', ')}';
}

String _unit(Target t) => t.parameter == Param.load ? 'kg' : 'reps';

const _questions = ['Why this goal?', 'What does reaching it mean, in your words?', 'What do you expect to be hardest?'];

List<String> _answers(Goal g) => [g.why, g.reachedMeans, g.hardestExpected];

/// The start answers, as written: shown on the goal and again at its end.
String _answersText(Goal g) => [
      for (final (i, a) in _answers(g).indexed)
        if (a.trim().isNotEmpty) '${_questions[i]}\n${a.trim()}',
    ].join('\n\n');

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
            if (name == null || name.isEmpty || !context.mounted) return;
            // A goal starts from the exercise its target sits on; an exercise is the target of at most one goal.
            final options = store.exercises.where((e) => !e.archived && targetTakenBy(e.id) == null).toList();
            final ex = await pickExercise(context, 'Its target sits on', options);
            if (ex == null) return;
            final g = Goal(name: name, target: Target(exerciseId: ex.id));
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
  late final answers = [for (final a in g0 == null ? ['', '', ''] : _answers(g0!)) TextEditingController(text: a)];

  void _setAnswer(Goal g, int i, String v) {
    if (i == 0) g.why = v;
    if (i == 1) g.reachedMeans = v;
    if (i == 2) g.hardestExpected = v;
    store.save();
  }

  Future<void> _addAlternate(Goal g) async {
    final base = store.exercise(g.target?.exerciseId);
    if (base == null) return;
    final options = store.exercises.where((e) => !e.archived && !g.exerciseIds.contains(e.id) && fitsAsAlternate(base, e)).toList();
    final pick = await pickExercise(context, 'An alternate for ${base.name}', options, sub: (e) => e.mainMovers.map((m) => m.label).join(', '));
    if (pick == null) return;
    g.alternateIds.add(pick.id);
    store.save();
  }

  Future<void> _limit(Goal g, Exercise e) async {
    final now = g.limitOn(e.id);
    final v = await askText(context, 'Sets per workout · ${e.name}',
        initial: now?.toString() ?? '', number: true, hint: 'Empty: no limit',
        note: '${e.unilateral ? 'A side. ' : ''}Warmups are not counted. A set past the limit is refused.${g.state == GoalState.active ? ' The change is kept on the goal with its date.' : ''}');
    if (v == null) return;
    final n = int.tryParse(v);
    if (v.isNotEmpty && (n == null || n < 1)) return;
    g.setLimit(e.id, v.isEmpty ? null : n);
    store.save();
  }

  Future<void> _moveTarget(Goal g) async {
    final t = g.target!;
    final options = store.exercises.where((e) => !e.archived && e.id != t.exerciseId && targetTakenBy(e.id, except: g) == null).toList();
    final pick = await pickExercise(context, 'Its target sits on', options);
    if (pick == null) return;
    g.setLimitsRemoveFor(t.exerciseId);
    t.exerciseId = pick.id;
    t.side = null;
    g.alternateIds.remove(pick.id);
    store.save();
  }

  Future<void> _editTarget(Goal g) async {
    final t = g.target!;
    final ex = store.exercise(t.exerciseId)!;
    final value = TextEditingController(text: t.value == 0 ? '' : fmtKg(t.value));
    final minLoad = TextEditingController(text: t.minLoadKg == null ? '' : fmtKg(t.minLoadKg!));
    var parameter = t.parameter;
    var side = t.side;
    final grades = {...t.grades};
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
                Text('TARGET · ${ex.name}'.toUpperCase(), style: ts(14, spacing: 2)),
                const Label('Parameter'),
                Choice<Param>(options: Param.values, label: (p) => p == Param.load ? 'Load' : 'Reps, on a test', isOn: (p) => p == parameter, onTap: (p) => setState(() => parameter = p)),
                Label(parameter == Param.load ? 'Reached at · kg or more' : 'Reached at · reps or more'),
                Field(controller: value, number: true, onChanged: (_) => setState(() {})),
                if (ex.unilateral) ...[
                  const Label('Side · both: each side in one workout'),
                  Choice<TargetSide>(options: TargetSide.values, label: (s) => _sideWords[s]!, isOn: (s) => s == side, onTap: (s) => setState(() => side = s)),
                ],
                const Label('Grades that count'),
                Choice<Grade>(options: Grade.values, label: gradeLabel, isOn: grades.contains, onTap: (gr) => setState(() => grades.contains(gr) ? grades.remove(gr) : grades.add(gr))),
                if (parameter == Param.reps) ...[
                  const Label('Least load that counts · kg, or empty'),
                  Field(controller: minLoad, number: true),
                ],
                const SizedBox(height: 16),
                KeyButton('Save target', filled: true, onTap: v == null || v <= 0 || grades.isEmpty || (ex.unilateral && side == null) ? null : () {
                  t.value = v;
                  t.parameter = parameter;
                  t.grades = grades;
                  t.side = ex.unilateral ? side : null;
                  t.minLoadKg = parameter == Param.reps ? double.tryParse(minLoad.text.replaceAll(',', '.')) : null;
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
    if (!await confirm(context, 'Make this goal active?',
        note: 'Nothing in it but its alternates can change after: its name, your answers, its target and the limit on its target\'s exercise lock. It ends only by being reached or abandoned.',
        yes: 'Make active')) {
      return;
    }
    g.state = GoalState.active;
    g.activatedAt = DateTime.now();
    store.save();
  }

  @override
  Widget build(BuildContext context) => Live((context) {
        final g = store.goal(widget.goalId);
        if (g == null) return const Screen(title: 'Goal', children: [Para('Deleted.')]);
        final t = g.target;
        final targetEx = store.exercise(t?.exerciseId);
        final draft = g.state == GoalState.draft;
        final from = store.goal(g.fromGoalId);
        final successors = store.goals.where((x) => x.fromGoalId == g.id).toList();
        final alternates = [for (final id in g.alternateIds) store.exercise(id)].nonNulls.toList();

        // The chart: the target's line by the target's rules, every other line by the grades shown; a line per side.
        final parameter = g.shownParameter ?? t?.parameter ?? Param.load;
        final lines = <ChartLine>[];
        var colour = 1;
        for (final e in [?targetEx, ...alternates]) {
          final isTarget = e == targetEx;
          if (!isTarget && g.hiddenExerciseIds.contains(e.id)) continue;
          for (final side in sidesOf(e)) {
            final onTargetSide = isTarget && (t!.side == null || t.side == TargetSide.both || (t.side == TargetSide.left) == (side == Side.left));
            final c = isTarget ? (side == Side.right ? cyanWhite.withValues(alpha: 0.85) : ember) : [cyanWhite.withValues(alpha: 0.8), ember.withValues(alpha: 0.5), cyanWhite.withValues(alpha: 0.4)][(colour++) % 3];
            final points = exerciseLine(e.id, parameter, (s) => isTarget ? letsThrough(t!, s) || (parameter != t.parameter && t.grades.contains(s.grade)) : g.shownGrades.contains(s.grade), until: g.endedAt, side: side);
            lines.add(ChartLine(points, color: c, dashed: !isTarget, label: side == null ? e.name : '${e.name} ${sideLabel(side)}', isTarget: onTargetSide));
          }
        }
        final onTargetParam = t != null && t.value > 0 && parameter == t.parameter;
        final gap = goalGap(g);
        final days = g.activatedAt == null ? null : daysBetween(g.activatedAt!, g.endedAt ?? DateTime.now());
        final changes = g.activatedAt == null ? <SetLimit>[] : g.setLimits.where((l) => l.setAt.isAfter(g.activatedAt!)).toList().reversed.toList();

        Widget limitKey(Exercise e, {required bool locked}) {
          final l = g.limitOn(e.id);
          final text = l == null ? 'No limit' : '$l sets${e.unilateral ? ' a side' : ''}';
          return SizedBox(width: 118, child: KeyButton(text, size: 10, height: 36, onTap: locked || g.ended ? null : () => _limit(g, e)));
        }

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
                final answers = _answersText(g);
                final why = await askText(context, 'Why is it abandoned?', lines: 3, required: true,
                    note: '${answers.isEmpty ? '' : 'At the start you said:\n\n$answers\n\n'}The answer is kept on the goal and cannot be changed.');
                if (why == null || why.isEmpty) return;
                abandon(g, why);
                store.save();
              }),
            _ => KeyButton('Start a new goal from this one', onTap: () {
                if (targetTakenBy(t!.exerciseId) != null) {
                  confirm(context, 'Not yet', note: 'Another goal\'s target already sits on ${targetEx?.name}.', yes: 'OK');
                  return;
                }
                final copy = copyGoal(g);
                store.save();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => GoalScreen(goalId: copy.id)));
              }),
          },
          children: [
            if (from != null) Entry('Started from · ${from.name}', sub: 'Its answers are there', onTap: () => push(context, GoalScreen(goalId: from.id))),
            for (final s in successors) Entry('Continued as · ${s.name}', onTap: () => push(context, GoalScreen(goalId: s.id))),
            // The end answer, then the start answers it is read against.
            if (g.state == GoalState.abandoned) ...[const Label('Why it was abandoned'), Para(g.abandonedBecause ?? '', apart: true)],
            if (g.state == GoalState.reached) ...[const Label('What got you there'), Para(g.whatGotYouThere ?? 'Not answered.', apart: g.whatGotYouThere != null)],
            if (draft) ...[
              const Label('Name'),
              Field(controller: name, onChanged: (v) {
                g.name = v.trim();
                store.save();
              }),
              const SizedBox(height: 6),
              const Para('Each question is optional. Your answers lock when the goal is made active, and its end shows them again.'),
              for (final (i, q) in _questions.indexed) ...[
                Label(q),
                Field(controller: answers[i], lines: 2, hint: 'For you, at the end of this goal', onChanged: (v) => _setAnswer(g, i, v)),
              ],
            ] else
              for (final (i, q) in _questions.indexed) ...[
                Label(q),
                Para(_answers(g)[i].trim().isEmpty ? 'Not answered.' : _answers(g)[i].trim(), apart: _answers(g)[i].trim().isNotEmpty),
              ],
            const Label('Target'),
            if (t == null) const Para('None.') else Para(_targetLine(t), apart: true),
            if (draft && t != null) ...[
              Row(children: [
                Expanded(child: KeyButton(t.value <= 0 ? 'Set the target' : 'Change the target', size: 11, onTap: () => _editTarget(g))),
                const SizedBox(width: 8),
                Expanded(child: KeyButton('Move to another exercise', size: 11, onTap: () => _moveTarget(g))),
              ]),
            ],
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
            LineChart(
              lines: lines,
              target: onTargetParam ? t.value : null,
              unit: parameter == Param.load ? 'kg' : 'reps',
              markers: {if (g.activatedAt != null) 'ACTIVE': dayOf(g.activatedAt!)},
              onOpen: (w) => push(context, w.endedAt == null ? const WorkoutScreen() : PastWorkoutScreen(workoutId: w.id)),
            ),
            const Label('Sets per workout'),
            if (targetEx != null)
              Row(children: [
                Expanded(child: Text('${targetEx.name} · the target\'s${draft ? '' : ' · locked'}'.toUpperCase(), style: ts(11.5, color: primaryC))),
                limitKey(targetEx, locked: !draft),
              ]),
            const Label('Alternates · offered on demand'),
            if (alternates.isEmpty) const Para('None.'),
            for (final e in alternates) ...[
              Entry(e.name,
                  glyph: g.hiddenExerciseIds.contains(e.id) ? '[ ]' : '[x]',
                  sub: [
                    g.hiddenExerciseIds.contains(e.id) ? 'Line hidden' : 'Line shown',
                    if (targetEx != null && !fitsAsAlternate(targetEx, e)) 'no longer shares a main mover or a gym',
                    if (e.archived) 'archived',
                  ].join(' · '),
                  dim: g.hiddenExerciseIds.contains(e.id),
                  onTap: () async {
                    final act = await pickOne<String>(context, e.name, [g.hiddenExerciseIds.contains(e.id) ? 'Show its line' : 'Hide its line', if (!g.ended) 'Remove from the goal'], (s) => s);
                    if (act == null) return;
                    if (act.startsWith('Remove')) {
                      g.alternateIds.remove(e.id);
                      g.hiddenExerciseIds.remove(e.id);
                      if (draft) g.setLimitsRemoveFor(e.id);
                    } else {
                      g.hiddenExerciseIds.contains(e.id) ? g.hiddenExerciseIds.remove(e.id) : g.hiddenExerciseIds.add(e.id);
                    }
                    store.save();
                  }),
              Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.only(top: 4), child: limitKey(e, locked: false))),
            ],
            if (!g.ended) ...[const SizedBox(height: 10), KeyButton('Add an alternate', onTap: () => _addAlternate(g))],
            if (changes.isNotEmpty) ...[
              const Label('Limit changes since active'),
              for (final l in changes)
                Entry('${store.exercise(l.exerciseId)?.name ?? '?'} · ${l.sets == null ? 'no limit' : '${l.sets} sets'}', glyph: '-', trailing: fmtDay(l.setAt)),
            ],
            const Label('Alternates\' lines · grades shown'),
            Choice<Grade>(options: Grade.values, label: gradeLabel, isOn: g.shownGrades.contains, onTap: (gr) {
              g.shownGrades.contains(gr) ? g.shownGrades.remove(gr) : g.shownGrades.add(gr);
              store.save();
            }),
          ],
        );
      });
}

/// A target is marked and not yet kept or undone: Auburn asks how to proceed, and cannot be dismissed.
/// Keeping it also asks what got you there, beside the start answers.
Future<void> askOwedReaches(BuildContext context) async {
  for (final g in owedPrompts()) {
    if (!context.mounted) return;
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
      final answers = _answersText(g);
      if (!context.mounted) return;
      final got = await askText(context, 'What got you there?', lines: 3, note: '${answers.isEmpty ? '' : 'At the start you said:\n\n$answers\n\n'}Optional. It is kept on the goal.');
      keepReach(g, got);
      if (choice == 'new' && targetTakenBy(t.exerciseId) == null) copyGoal(g);
    }
    store.save();
  }
}
