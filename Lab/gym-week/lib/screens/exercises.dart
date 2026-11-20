// The exercises: the list, one exercise with its rest, notes, progress and past sets, and editing one.
// Behaviour: Spec/Features/Exercises.md, Muscle Groups.md and Progress.md.
import 'package:flutter/material.dart';

import '../logic.dart';
import '../model.dart';
import '../ui.dart';
import 'workout.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});
  @override
  State<ExercisesScreen> createState() => _ExercisesState();
}

class _ExercisesState extends State<ExercisesScreen> {
  final filter = <String>{};
  final gyms = <String>{};
  final muscles = <MuscleGroup>{};
  bool filtering = false;

  bool _passes(Exercise e) => passesFilter(e, filter) && passesGyms(e, gyms) && passesMuscles(e, muscles);

  @override
  Widget build(BuildContext context) => Live((context) {
        final all = [...store.exercises]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        final on = filter.length + gyms.length + muscles.length;
        final shown = all.where((e) => !e.archived && _passes(e)).toList();
        final archived = all.where((e) => e.archived && _passes(e)).toList();
        final unnamed = all.where((e) => !e.archived && e.mainMovers.isEmpty && e.supporting.isEmpty).length;
        return Screen(
          title: 'Exercises',
          status: '${all.where((e) => !e.archived).length} exercises${unnamed == 0 ? '' : ' · $unnamed with no muscle groups named'}',
          bottom: KeyButton('New exercise', onTap: () async {
            final name = await askText(context, 'New exercise', hint: 'Name', required: true);
            if (name == null || name.isEmpty || !context.mounted) return;
            // An exercise is tied to at least one gym.
            final gym = await pickOne<Gym>(context, 'Done at which gym?', store.gyms.where((g) => !g.archived).toList(), (g) => g.name);
            if (gym == null) return;
            final e = Exercise(name: name, loadKind: LoadKind.stack, stepKg: 2.5, gymIds: {gym.id});
            store.exercises.add(e);
            store.save();
            if (context.mounted) push(context, ExerciseEditScreen(exerciseId: e.id));
          }),
          children: [
            // The filters fold away behind one key, so the list starts high on the screen.
            Row(children: [
              Expanded(child: KeyButton(filtering ? 'Hide filters' : (on == 0 ? 'Filter' : 'Filter · $on on'), size: 11, height: 40, on: on > 0, onTap: () => setState(() => filtering = !filtering))),
              if (on > 0) ...[
                const SizedBox(width: 8),
                SizedBox(width: 96, child: KeyButton('Clear', size: 11, height: 40, onTap: () => setState(() {
                      filter.clear();
                      gyms.clear();
                      muscles.clear();
                    }))),
              ],
            ]),
            if (filtering) ...[
              const SizedBox(height: 10),
              GymFilter(on: gyms, onToggle: (id) => setState(() => gyms.contains(id) ? gyms.remove(id) : gyms.add(id))),
              MuscleFilter(on: muscles, onToggle: (m) => setState(() => muscles.contains(m) ? muscles.remove(m) : muscles.add(m))),
              ValueFilter(on: filter, onToggle: (id) => setState(() => filter.contains(id) ? filter.remove(id) : filter.add(id))),
            ],
            const SizedBox(height: 12),
            if (on > 0) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('${shown.length} OF ${all.where((e) => !e.archived).length} SHOWN', style: ts(10.5, color: secondaryC))),
            for (final e in shown)
              ExerciseCard(e, after: [if (e.mainMovers.isEmpty) const Tag('No main mover named', kind: TagKind.mark)], onTap: () => push(context, ExerciseScreen(exerciseId: e.id))),
            if (archived.isNotEmpty) const Label('Archived'),
            for (final e in archived) ExerciseCard(e, onTap: () => push(context, ExerciseScreen(exerciseId: e.id))),
          ],
        );
      });
}

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key, required this.exerciseId});
  final String exerciseId;
  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) => Live((context) {
        final e = store.exercise(widget.exerciseId);
        if (e == null) {
          // Deleted from its edit screen: leave as well.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) Navigator.of(context).maybePop();
          });
          return const Screen(title: 'Exercise', children: [Para('Deleted.')]);
        }
        final rest = readRest();
        final lines = [
          for (final side in sidesOf(e))
            ChartLine(exerciseLine(e.id, e.shownParameter, (s) => e.shownGrades.contains(s.grade), side: side),
                label: side == null ? e.name : '${e.name} ${sideLabel(side)}', color: side == Side.right ? cyanWhite.withValues(alpha: 0.8) : ember),
        ];
        final served = goalsServedBy(e.id);
        final alternates = alternatesOf(e);
        final from = alternatesFrom(e);
        final workouts = store.workouts.where((w) => w.commits.any((c) => c.exerciseId == e.id && c.sets.isNotEmpty)).toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
        final notes = [e.observations, e.settings, e.form];
        return Screen(
          title: e.name,
          status: '${loadKindLabel(e.loadKind)}${e.unilateral ? ' · unilateral' : ''}${e.archived ? ' · archived' : ''} · ${e.gymIds.map((id) => store.gym(id)?.name ?? '?').join(', ')}',
          bottom: KeyButton('Edit', onTap: () => push(context, ExerciseEditScreen(exerciseId: e.id))),
          children: [
            Wrap(spacing: 4, runSpacing: 4, children: exerciseTags(e, movers: false)),
            const SizedBox(height: 8),
            if (e.mainMovers.isEmpty && e.supporting.isEmpty) const Para('No muscle groups named: it resets no rest.', apart: true),
            for (final g in e.mainMovers) RestMeter(rest[g]!),
            if (e.supporting.isNotEmpty) Text('SUPPORTING · ${e.supporting.map((g) => g.label).join(', ')}'.toUpperCase(), style: ts(10.5, color: secondaryC)),
            if (valuesOf(e).isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(valuesOf(e).map((v) => '${store.property(v.propertyId)?.name}: ${v.name}').join(' · ').toUpperCase(), style: ts(10.5, color: secondaryC))),
            if (served.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text('SERVES · ${served.map((g) => g.name).join(', ')}'.toUpperCase(), style: ts(10.5, color: secondaryC))),
            if (alternates.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('ALTERNATES${from == null ? '' : ', FROM ${from.name}'} · ${alternates.map((x) => x.name).join(', ')}'.toUpperCase(), style: ts(10.5, color: secondaryC))),
            const Label('Notes'),
            Choice<int>(options: const [0, 1, 2], label: (i) => const ['Observations', 'Settings', 'Form'][i], isOn: (i) => i == tab, onTap: (i) => setState(() => tab = i)),
            Para(notes[tab].isEmpty ? 'Nothing noted.' : notes[tab], apart: notes[tab].isNotEmpty),
            const Label('Progress'),
            Choice<Param>(options: Param.values, label: (p) => p == Param.load ? 'Load' : 'Reps, on tests', isOn: (p) => p == e.shownParameter, onTap: (p) {
              e.shownParameter = p;
              store.save();
            }),
            const SizedBox(height: 6),
            Choice<Grade>(options: Grade.values, label: gradeLabel, isOn: e.shownGrades.contains, onTap: (g) {
              e.shownGrades.contains(g) ? e.shownGrades.remove(g) : e.shownGrades.add(g);
              store.save();
            }),
            const SizedBox(height: 10),
            LineChart(lines: lines, unit: e.shownParameter == Param.load ? 'kg' : 'reps', onOpen: (w) => push(context, PastWorkoutScreen(workoutId: w.id))),
            const Label('Past sets'),
            if (workouts.isEmpty) const Para('Never done.'),
            for (final w in workouts.take(30)) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('${workoutTitle(w)} · PLACE ${w.commits.indexWhere((c) => c.exerciseId == e.id) + 1}'.toUpperCase(), style: ts(11, color: supportingC, bold: true)),
              ),
              for (final c in w.commits.where((c) => c.exerciseId == e.id))
                for (final s in c.sets) Entry(setLine(s), trailing: fmtTime(s.loggedAt), onTap: () => editSet(context, e, c, s)),
            ],
          ],
        );
      });
}

class ExerciseEditScreen extends StatefulWidget {
  const ExerciseEditScreen({super.key, required this.exerciseId});
  final String exerciseId;
  @override
  State<ExerciseEditScreen> createState() => _ExerciseEditState();
}

class _ExerciseEditState extends State<ExerciseEditScreen> {
  late final Exercise e = store.exercise(widget.exerciseId)!;
  late final name = TextEditingController(text: e.name);
  late final bar = TextEditingController(text: fmtKg(e.barKg ?? 20));
  late final step = TextEditingController(text: fmtKg(e.stepKg ?? 2.5));

  Future<void> _property(Property p) async {
    final values = store.propertyValues.where((v) => v.propertyId == p.id).toList();
    final act = await pickOne<String>(context, p.name, ['Add a value', 'Rename ${p.name}', for (final v in values) 'Rename ${v.name}', for (final v in values) 'Delete ${v.name}', 'Delete ${p.name}'], (s) => s);
    if (act == null || !mounted) return;
    if (act == 'Add a value') {
      final n = await askText(context, 'New value of ${p.name}', hint: 'Such as Strict', required: true);
      if (n == null || n.isEmpty) return;
      final v = PropertyValue(propertyId: p.id, name: n);
      store.propertyValues.add(v);
      _hold(v);
    } else if (act == 'Rename ${p.name}') {
      final n = await askText(context, 'Rename ${p.name}', initial: p.name, required: true);
      if (n == null || n.isEmpty) return;
      p.name = n;
    } else if (act == 'Delete ${p.name}') {
      if (!await confirm(context, 'Delete ${p.name}?', note: 'It leaves every exercise that holds one of its values.', yes: 'Delete')) return;
      final ids = values.map((v) => v.id).toSet();
      for (final x in store.exercises) {
        x.propertyValueIds.removeAll(ids);
      }
      store.propertyValues.removeWhere((v) => ids.contains(v.id));
      store.properties.remove(p);
    } else {
      final v = values.firstWhere((v) => act.endsWith(' ${v.name}'));
      if (act.startsWith('Rename')) {
        final n = await askText(context, 'Rename ${v.name}', initial: v.name, required: true);
        if (n == null || n.isEmpty) return;
        v.name = n;
      } else {
        for (final x in store.exercises) {
          x.propertyValueIds.remove(v.id);
        }
        store.propertyValues.remove(v);
      }
    }
    store.save();
  }

  /// An exercise holds at most one value of each property.
  void _hold(PropertyValue v) {
    final siblings = store.propertyValues.where((x) => x.propertyId == v.propertyId).map((x) => x.id);
    final had = e.propertyValueIds.contains(v.id);
    e.propertyValueIds.removeAll(siblings);
    if (!had) e.propertyValueIds.add(v.id);
    store.save();
  }

  bool get _hasSides => store.workouts.any((w) => w.commits.any((c) => c.exerciseId == e.id && c.sets.any((s) => s.side != null)));

  void _cycle(MuscleGroup g) {
    // neither, main, supporting, neither again
    if (e.mainMovers.remove(g)) {
      e.supporting.add(g);
    } else if (!e.supporting.remove(g)) {
      e.mainMovers.add(g);
    }
    store.save();
  }

  @override
  Widget build(BuildContext context) => Live((context) {
        final others = store.exercises.where((x) => x.id != e.id && !x.archived).toList()..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        final activeTarget = store.goals.any((g) => g.state == GoalState.active && g.target?.exerciseId == e.id);
        final from = alternatesFrom(e);
        return Screen(title: 'Edit exercise', status: e.name, children: [
          const Label('Name'),
          Field(controller: name, onChanged: (v) {
            if (v.trim().isEmpty) return;
            e.name = v.trim();
            store.save();
          }),
          const Label('Load kind'),
          Choice<LoadKind>(options: LoadKind.values, label: loadKindLabel, isOn: (k) => k == e.loadKind, onTap: (k) {
            e.loadKind = k;
            e.barKg = k == LoadKind.plates ? (double.tryParse(bar.text) ?? 20) : null;
            e.stepKg = k == LoadKind.stack || k == LoadKind.dumbbells ? (double.tryParse(step.text) ?? 2.5) : null;
            store.save();
          }),
          if (e.loadKind == LoadKind.plates) ...[
            const Label('Bar · kg'),
            Field(controller: bar, number: true, onChanged: (v) {
              final d = double.tryParse(v.replaceAll(',', '.'));
              if (d == null || d < 0) return;
              e.barKg = d;
              store.save();
            }),
          ],
          if (e.loadKind == LoadKind.stack || e.loadKind == LoadKind.dumbbells) ...[
            const Label('Step between loads · kg'),
            Field(controller: step, number: true, onChanged: (v) {
              final d = double.tryParse(v.replaceAll(',', '.'));
              if (d == null || d <= 0) return;
              e.stepKg = d;
              store.save();
            }),
          ],
          const Label('Sides'),
          KeyButton(
            e.unilateral
                ? (activeTarget ? 'Unilateral · an active goal\'s target sits on it' : (_hasSides ? 'Unilateral · its sets have sides' : 'Unilateral · tap to unmark'))
                : (activeTarget ? 'Both sides · an active goal\'s target sits on it' : 'Both sides at once · tap to mark unilateral'),
            on: e.unilateral,
            onTap: activeTarget || (e.unilateral && _hasSides)
                ? null
                : () {
                    e.unilateral = !e.unilateral;
                    store.save();
                  },
          ),
          const Label('Properties · one value of each'),
          for (final p in store.properties) ...[
            Row(children: [
              Expanded(child: Text(p.name.toUpperCase(), style: ts(10.5, color: secondaryC))),
              SizedBox(width: 72, child: KeyButton('Edit', size: 10, height: 36, onTap: () => _property(p))),
            ]),
            const SizedBox(height: 4),
            Choice<PropertyValue>(options: store.propertyValues.where((v) => v.propertyId == p.id).toList(), label: (v) => v.name, isOn: (v) => e.propertyValueIds.contains(v.id), onTap: _hold),
            const SizedBox(height: 8),
          ],
          KeyButton('New property', size: 11, onTap: () async {
            final n = await askText(context, 'New property', hint: 'Such as Form', required: true);
            if (n == null || n.isEmpty || !context.mounted) return;
            final v = await askText(context, 'Its first value', hint: 'Such as Strict', required: true);
            if (v == null || v.isEmpty) return;
            final p = Property(name: n);
            final pv = PropertyValue(propertyId: p.id, name: v);
            store.properties.add(p);
            store.propertyValues.add(pv);
            _hold(pv);
          }),
          const Label('Muscle groups · tap: neither, main, supporting'),
          for (final g in MuscleGroup.values)
            Entry(g.label,
                glyph: e.mainMovers.contains(g) ? '[M]' : (e.supporting.contains(g) ? '[S]' : '[ ]'),
                dim: !e.mainMovers.contains(g) && !e.supporting.contains(g),
                trailing: e.mainMovers.contains(g) ? 'Main' : (e.supporting.contains(g) ? 'Supporting' : '—'),
                onTap: () => _cycle(g)),
          const Label('Gyms · at least one'),
          Choice<Gym>(options: store.gyms.where((g) => !g.archived).toList(), label: (g) => g.name, isOn: (g) => e.gymIds.contains(g.id), onTap: (g) {
            if (e.gymIds.contains(g.id)) {
              if (e.gymIds.length == 1) return; // the last gym tie stays
              e.gymIds.remove(g.id);
            } else {
              e.gymIds.add(g.id);
            }
            store.save();
          }),
          const Label('Its own alternates, in order'),
          if (from != null) Para('While ${from.name} is active, its alternates are the goal\'s. These return when it ends.'),
          for (final (i, id) in e.alternateIds.indexed)
            if (store.exercise(id) case final alt?)
              ExerciseEntry(alt,
                  before: [Tag('${i + 1}.')],
                  after: [if (!fitsAsAlternate(e, alt)) const Tag('No longer shares a main mover or a gym · not offered', kind: TagKind.mark), const Tag('Tap to remove')],
                  onTap: () {
                    e.alternateIds.remove(id);
                    store.save();
                  }),
          const SizedBox(height: 6),
          KeyButton('Add an alternate', onTap: () async {
            final pick = await pickExercise(context, 'Alternate for ${e.name}', others.where((x) => !e.alternateIds.contains(x.id) && fitsAsAlternate(e, x)).toList());
            if (pick == null) return;
            e.alternateIds.add(pick.id);
            store.save();
          }),
          const SizedBox(height: 28),
          KeyButton(
            e.archived ? 'Restore' : (activeTarget ? 'An active goal\'s target sits on it' : 'Archive'),
            onTap: !e.archived && activeTarget
                ? null
                : () {
                    e.archived = !e.archived;
                    store.save();
                  },
          ),
          const SizedBox(height: 8),
          KeyButton('Delete', onTap: () async {
            final why = cannotDelete(e);
            if (why != null) {
              await confirm(context, 'Not deleted', note: why, yes: 'OK');
              return;
            }
            if (!context.mounted || !await confirm(context, 'Delete ${e.name}?', note: 'It has no sets. It leaves every routine, goal and exercise that names it, and cannot be restored.', yes: 'Delete')) return;
            deleteExercise(e);
            store.save();
            if (context.mounted) Navigator.of(context).pop();
          }),
        ]);
      });
}
