// The exercises: the list, one exercise with its rest, notes, progress and past sets, and editing one.
// Behaviour: Spec/Features/Exercises.md, Muscle Groups.md and Progress.md.
import 'package:flutter/material.dart';

import '../logic.dart';
import '../model.dart';
import '../ui.dart';
import 'workout.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});
  @override
  Widget build(BuildContext context) => Live((context) {
        final all = [...store.exercises]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        final unnamed = all.where((e) => !e.archived && e.mainMovers.isEmpty && e.supporting.isEmpty).length;
        return Screen(
          title: 'Exercises',
          status: '${all.where((e) => !e.archived).length} exercises${unnamed == 0 ? '' : ' · $unnamed with no muscle groups named'}',
          bottom: KeyButton('New exercise', onTap: () async {
            final name = await askText(context, 'New exercise', hint: 'Name', required: true);
            if (name == null || name.isEmpty) return;
            final e = Exercise(name: name, loadKind: LoadKind.stack, stepKg: 2.5);
            store.exercises.add(e);
            store.save();
            if (context.mounted) push(context, ExerciseEditScreen(exerciseId: e.id));
          }),
          children: [
            for (final e in all.where((e) => !e.archived))
              Entry(e.name,
                  sub: e.mainMovers.isEmpty ? 'No main mover named' : e.mainMovers.map((g) => g.label).join(', '),
                  onTap: () => push(context, ExerciseScreen(exerciseId: e.id))),
            if (all.any((e) => e.archived)) const Label('Archived'),
            for (final e in all.where((e) => e.archived)) Entry(e.name, dim: true, onTap: () => push(context, ExerciseScreen(exerciseId: e.id))),
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
        if (e == null) return const Screen(title: 'Exercise', children: [Para('Gone.')]);
        final rest = readRest();
        final line = exerciseLine(e.id, e.shownParameter, (s) => e.shownGrades.contains(s.grade));
        final served = goalsServedBy(e.id);
        final workouts = store.workouts.where((w) => w.commits.any((c) => c.exerciseId == e.id && c.sets.isNotEmpty)).toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
        final notes = [e.observations, e.settings, e.form];
        return Screen(
          title: e.name,
          status: '${loadKindLabel(e.loadKind)}${e.archived ? ' · archived' : ''}${e.gymIds.isEmpty ? ' · every gym' : ' · ${e.gymIds.map((id) => store.gym(id)?.name ?? '?').join(', ')}'}',
          bottom: KeyButton('Edit', onTap: () => push(context, ExerciseEditScreen(exerciseId: e.id))),
          children: [
            if (e.mainMovers.isEmpty && e.supporting.isEmpty) const Para('No muscle groups named: it resets no rest.', apart: true),
            for (final g in e.mainMovers) RestMeter(rest[g]!),
            if (e.supporting.isNotEmpty) Text('SUPPORTING · ${e.supporting.map((g) => g.label).join(', ')}'.toUpperCase(), style: ts(10.5, color: secondaryC)),
            if (served.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text('SERVES · ${served.map((g) => g.name).join(', ')}'.toUpperCase(), style: ts(10.5, color: secondaryC))),
            if (e.alternateIds.isNotEmpty)
              Padding(padding: const EdgeInsets.only(top: 6), child: Text('ALTERNATES · ${e.alternateIds.map((id) => store.exercise(id)?.name ?? '?').join(', ')}'.toUpperCase(), style: ts(10.5, color: secondaryC))),
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
            LineChart(lines: [ChartLine(line)]),
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
          const Label('Muscle groups · tap: neither, main, supporting'),
          for (final g in MuscleGroup.values)
            Entry(g.label,
                glyph: e.mainMovers.contains(g) ? '[M]' : (e.supporting.contains(g) ? '[S]' : '[ ]'),
                dim: !e.mainMovers.contains(g) && !e.supporting.contains(g),
                trailing: e.mainMovers.contains(g) ? 'Main' : (e.supporting.contains(g) ? 'Supporting' : '—'),
                onTap: () => _cycle(g)),
          const Label('Gyms · none ticked: the same everywhere'),
          Choice<Gym>(options: store.gyms.where((g) => !g.archived).toList(), label: (g) => g.name, isOn: (g) => e.gymIds.contains(g.id), onTap: (g) {
            e.gymIds.contains(g.id) ? e.gymIds.remove(g.id) : e.gymIds.add(g.id);
            store.save();
          }),
          const Label('Alternates, in order'),
          for (final (i, id) in e.alternateIds.indexed)
            Entry(store.exercise(id)?.name ?? '?', glyph: '${i + 1}.', trailing: 'Remove', onTap: () {
              e.alternateIds.remove(id);
              store.save();
            }),
          const SizedBox(height: 6),
          KeyButton('Add an alternate', onTap: () async {
            final pick = await pickOne<Exercise>(context, 'Alternate for ${e.name}', others.where((x) => !e.alternateIds.contains(x.id)).toList(), (x) => x.name);
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
        ]);
      });
}
