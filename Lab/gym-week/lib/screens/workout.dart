// Starting a workout, committing exercises, logging sets, and past workouts.
// Behaviour: Spec/Features/Workouts.md, Routines.md and Sets.md.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic.dart';
import '../model.dart';
import '../ui.dart';

String workoutTitle(Workout w) => '${fmtDay(w.startedAt)} · ${store.gym(w.gymId)?.name ?? '?'}';

String _duration(Workout w) {
  final d = (w.endedAt ?? DateTime.now()).difference(w.startedAt);
  return '${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}';
}

/// Choosing the gym, then a routine or none.
class StartWorkoutScreen extends StatefulWidget {
  const StartWorkoutScreen({super.key});
  @override
  State<StartWorkoutScreen> createState() => _StartWorkoutState();
}

class _StartWorkoutState extends State<StartWorkoutScreen> {
  Gym? gym;

  void _start(Routine? routine) {
    final w = Workout(gymId: gym!.id, routineId: routine?.id, startedAt: DateTime.now());
    store.workouts.add(w);
    store.save();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const WorkoutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final gyms = store.gyms.where((g) => !g.archived).toList();
    if (gym == null) {
      return Screen(title: 'Start workout', status: 'Which gym?', children: [
        if (gyms.isEmpty) const Para('No gym yet. Add one under Gyms.'),
        for (final g in gyms) Entry(g.name, onTap: () => setState(() => gym = g)),
      ]);
    }
    final routines = store.routines.where((r) => !r.archived && r.offeredAt(gym!.id)).toList();
    final grouped = <String?, List<Routine>>{};
    for (final r in routines) {
      grouped.putIfAbsent(store.routineGroups.any((g) => g.id == r.groupId) ? r.groupId : null, () => []).add(r);
    }
    return Screen(title: 'Start workout', status: '${gym!.name} · a routine, or none', children: [
      for (final g in store.routineGroups)
        if (grouped[g.id] != null) ...[
          Label(g.name),
          for (final r in grouped[g.id]!) Entry(r.name, sub: '${r.items.length} in it', onTap: () => _start(r)),
        ],
      if (grouped[null] != null) ...[
        if (grouped.length > 1) const Label('Standalone'),
        for (final r in grouped[null]!) Entry(r.name, sub: '${r.items.length} in it', onTap: () => _start(r)),
      ],
      const SizedBox(height: 16),
      KeyButton('No routine', onTap: () => _start(null)),
    ]);
  }
}

String _restSummary(Exercise e, Map<MuscleGroup, RestReading> rest) => [
      for (final g in e.mainMovers)
        '${g.label} ${rest[g]!.days == null ? 'not yet trained' : '${rest[g]!.days}d ${restStepLabels[rest[g]!.step!.index]}'}'
    ].join(' · ');

/// The workout in progress: what the routine offers, what is committed, and every other exercise.
class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});
  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final open = <String>{}; // goals whose alternates are shown
  final filter = <String>{};

  void _open(BuildContext context, Workout w, Exercise e) {
    var commit = w.commits.where((c) => c.exerciseId == e.id).firstOrNull;
    if (commit == null) {
      commit = Commit(exerciseId: e.id);
      w.commits.add(commit);
      store.save();
    }
    push(context, SetScreen(workoutId: w.id, commitId: commit.id));
  }

  Future<void> _end(BuildContext context, Workout w) async {
    if (!await confirm(context, 'End workout?', yes: 'End')) return;
    if (w.commits.isEmpty) {
      store.workouts.remove(w);
    } else {
      w.endedAt = DateTime.now();
    }
    store.save();
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Live((context) {
        final w = store.current;
        if (w == null) return const Screen(title: 'Workout', children: [Para('No workout in progress.')]);
        final rest = readRest();
        final committed = {for (final c in w.commits) c.exerciseId: c};
        final routine = store.routine(w.routineId);
        final offer = routine == null ? <OfferedGroup>[] : routineOffer(routine, w.gymId);
        final offeredIds = {for (final g in offer) ...[for (final e in g.exercises) e.id, for (final e in g.alternates) e.id]};
        final others = store.exercises
            .where((e) => !e.archived && e.availableAt(w.gymId) && !offeredIds.contains(e.id) && !committed.containsKey(e.id) && passesFilter(e, filter))
            .toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        Widget row(Exercise e) {
          final c = committed[e.id];
          return Entry(nameWithValues(e),
              glyph: c == null ? '>_' : 'OK',
              sub: _restSummary(e, rest),
              trailing: c == null ? null : '${c.sets.length} set${c.sets.length == 1 ? '' : 's'}',
              onTap: () => _open(context, w, e));
        }

        return Screen(
          title: workoutTitle(w),
          status: 'In progress · ${_duration(w)}${routine == null ? '' : ' · ${routine.name}'}',
          bottom: KeyButton('End workout', onTap: () => _end(context, w)),
          children: [
            if (w.commits.isNotEmpty) ...[
              const Label('Committed, in order'),
              for (final (i, c) in w.commits.indexed)
                Entry(store.exercise(c.exerciseId)?.name ?? '?',
                    glyph: '${i + 1}.',
                    trailing: '${c.sets.length} set${c.sets.length == 1 ? '' : 's'}',
                    onTap: () => push(context, SetScreen(workoutId: w.id, commitId: c.id))),
            ],
            if (routine != null) ...[
              Label('From ${routine.name}'),
              if (offer.every((g) => g.exercises.isEmpty)) const Para('Nothing in this routine is available at this gym.'),
              for (final g in offer) ...[
                if (g.goal != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    color: ember,
                    child: Row(children: [
                      Expanded(child: Text('GOAL · ${g.goal!.name}'.toUpperCase(), style: ts(12, color: obsidian, bold: true, spacing: 1.5))),
                      if (goalGap(g.goal!).gap != null) Text('GAP ${fmtKg(goalGap(g.goal!).gap!)}', style: ts(11, color: obsidian, bold: true)),
                    ]),
                  ),
                for (final e in g.exercises) row(e),
                if (g.alternates.isNotEmpty) ...[
                  KeyButton(open.contains(g.goal!.id) ? 'Hide its alternates' : 'Its alternates · ${g.alternates.length}', size: 11, height: 40, on: open.contains(g.goal!.id),
                      onTap: () => setState(() => open.contains(g.goal!.id) ? open.remove(g.goal!.id) : open.add(g.goal!.id))),
                  if (open.contains(g.goal!.id)) for (final e in g.alternates) row(e),
                ],
              ],
            ],
            Label(routine == null ? 'Exercises at this gym' : 'Every other exercise here'),
            ValueFilter(on: filter, onToggle: (id) => setState(() => filter.contains(id) ? filter.remove(id) : filter.add(id))),
            if (others.isEmpty) const Para('None.'),
            for (final e in others) row(e),
          ],
        );
      });
}

/// One committed exercise: its notes, the load, marking a test, and the grade keys that log the set.
class SetScreen extends StatefulWidget {
  const SetScreen({super.key, required this.workoutId, required this.commitId});
  final String workoutId;
  final String commitId;
  @override
  State<SetScreen> createState() => _SetScreenState();
}

class _SetScreenState extends State<SetScreen> {
  double? load;
  List<double> plates = [];
  bool test = false;
  bool repsOwed = false;
  Side? side;
  int tab = 0;
  final reps = TextEditingController();
  final note = TextEditingController();
  String? noteFor;

  Workout? get w => store.workouts.where((x) => x.id == widget.workoutId).firstOrNull;
  Commit? get commit => w?.commits.where((c) => c.id == widget.commitId).firstOrNull;

  void _initLoad(Exercise ex) {
    if (load != null) return;
    load = startLoad(w!, commit!, ex);
    if (ex.loadKind == LoadKind.plates) {
      final last = commit!.sets.lastOrNull;
      plates = [...(last?.platesPerSide ?? platesFor(load!, ex.barKg ?? 20))];
      load = (ex.barKg ?? 20) + 2 * plates.fold(0.0, (a, b) => a + b);
    }
  }

  void _log(Exercise ex, Grade grade) {
    if (refusedByLimit(commit!, ex, grade, side)) return;
    int? r;
    if (test) {
      r = int.tryParse(reps.text.trim());
      if (r == null || r <= 0) {
        setState(() => repsOwed = true);
        return;
      }
    }
    commit!.sets.add(LoggedSet(
      loggedAt: DateTime.now(), loadKg: load!, platesPerSide: ex.loadKind == LoadKind.plates ? [...plates] : null,
      grade: grade, test: test, reps: r, side: ex.unilateral ? side : null,
    ));
    HapticFeedback.mediumImpact();
    test = false;
    repsOwed = false;
    reps.clear();
    checkGoals();
    store.save();
  }

  String _noteText(Exercise ex) => [ex.observations, ex.settings, ex.form][tab];

  void _syncNote(Exercise ex) {
    final key = '${ex.id}/$tab';
    if (noteFor != key) {
      noteFor = key;
      note.text = _noteText(ex);
    }
  }

  Future<void> _swap(Exercise ex) async {
    final pick = await pickExercise(context, 'Swap for an alternate', _alternatesHere(ex));
    if (pick == null) return;
    commit!.exerciseId = pick.id;
    load = null;
    side = null;
    noteFor = null;
    store.save();
  }

  /// The alternates offered for a swap: the goal's or its own, as they hold now, tied to this gym.
  List<Exercise> _alternatesHere(Exercise ex) =>
      alternatesOf(ex).where((a) => !a.archived && a.availableAt(w!.gymId) && !w!.commits.any((c) => c.exerciseId == a.id)).toList();

  @override
  Widget build(BuildContext context) => Live((context) {
        final c = commit;
        final ex = store.exercise(c?.exerciseId);
        if (c == null || ex == null) return const Screen(title: 'Set', children: [Para('This commit is gone.')]);
        _initLoad(ex);
        if (ex.unilateral) side ??= startSide(w!, c);
        final limit = setLimitOn(ex.id);
        final atLimit = refusedByLimit(c, ex, Grade.ideal, side);
        _syncNote(ex);
        final rest = readRest();
        final inProgress = w!.endedAt == null;
        final step = loadStep(ex);
        final lowest = lowestLoad(ex);
        final lastReps = lastTestReps(ex.id);

        return Screen(
          title: nameWithValues(ex),
          status: '${workoutTitle(w!)} · ${c.sets.length} set${c.sets.length == 1 ? '' : 's'}',
          children: [
            for (final g in ex.mainMovers) RestMeter(rest[g]!),
            if (ex.supporting.isNotEmpty) Text('SUPPORTING · ${ex.supporting.map((g) => g.label).join(', ')}'.toUpperCase(), style: ts(10.5, color: secondaryC)),
            if (ex.mainMovers.isEmpty && ex.supporting.isEmpty) Text('NO MUSCLE GROUPS NAMED YET', style: ts(10.5, color: secondaryC)),
            const SizedBox(height: 10),
            Choice<int>(options: const [0, 1, 2], label: (i) => const ['Observations', 'Settings', 'Form'][i], isOn: (i) => i == tab, onTap: (i) => setState(() => tab = i)),
            const SizedBox(height: 6),
            Field(
              controller: note,
              lines: 2,
              hint: 'Nothing noted.',
              onChanged: (v) {
                if (tab == 0) ex.observations = v;
                if (tab == 1) ex.settings = v;
                if (tab == 2) ex.form = v;
                store.save();
              },
            ),
            if (inProgress) ...[
              if (ex.unilateral) ...[
                const Label('Side'),
                Choice<Side>(options: Side.values, label: sideLabel, isOn: (x) => x == side, onTap: (x) => setState(() => side = x)),
              ],
              if (limit != null) ...[
                const SizedBox(height: 10),
                Text('LIMIT $limit SETS${ex.unilateral ? ' A SIDE' : ''} · ${setsTowardLimit(c, ex.unilateral ? side : null)} LOGGED${ex.unilateral ? ' ON THE ${sideLabel(side!).toUpperCase()}' : ''} · WARMUPS NOT COUNTED',
                    style: ts(11, color: atLimit ? cyanWhite : secondaryC, bold: atLimit)),
                if (atLimit) Text('THE LIMIT IS REACHED: ONLY A WARMUP CAN BE LOGGED', style: ts(11, color: cyanWhite, bold: true)),
              ],
              const Label('Load · kg'),
              if (ex.loadKind == LoadKind.plates) ...[
                Center(child: Text(fmtKg(load!), style: ts(30, color: cyanWhite))),
                Center(child: Text('BAR ${fmtKg(ex.barKg ?? 20)} + ${plates.isEmpty ? 'NO PLATES' : plates.map(fmtKg).join(' + ')} A SIDE', style: ts(10.5, color: secondaryC))),
                const SizedBox(height: 8),
                Row(children: [
                  for (final p in plateKeys)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: KeyButton(fmtKg(p), size: 12, onTap: () => setState(() {
                              plates.add(p);
                              load = load! + 2 * p;
                            })),
                      ),
                    ),
                  Expanded(
                    child: KeyButton('Undo', size: 10, onTap: plates.isEmpty ? null : () => setState(() => load = load! - 2 * plates.removeLast())),
                  ),
                ]),
              ] else
                Stepper2(
                  text: fmtKg(load!),
                  onMinus: load! - step < lowest - 1e-9 ? null : () => setState(() => load = load! - step),
                  onPlus: () => setState(() => load = load! + step),
                ),
              const SizedBox(height: 14),
              KeyButton('Ideal', filled: !atLimit, height: 72, size: 18, onTap: atLimit ? null : () => _log(ex, Grade.ideal)),
              const SizedBox(height: 6),
              Row(children: [
                for (final g in [Grade.acceptable, Grade.light, Grade.yielding, Grade.warmup])
                  Expanded(child: Padding(padding: EdgeInsets.only(left: g == Grade.acceptable ? 0 : 6), child: KeyButton(gradeLabel(g), size: 10, height: 56, onTap: atLimit && g != Grade.warmup ? null : () => _log(ex, g)))),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: KeyButton(test ? 'Test · on' : 'Mark next set a test', on: test, size: 11, onTap: () => setState(() {
                      test = !test;
                      repsOwed = false;
                    }))),
                if (test) ...[
                  const SizedBox(width: 8),
                  SizedBox(width: 120, child: Field(controller: reps, number: true, hint: lastReps == null ? 'reps' : '$lastReps reps')),
                ],
              ]),
              if (repsOwed) Padding(padding: const EdgeInsets.only(top: 6), child: Text('A TEST IS LOGGED ONLY WITH ITS REPS', style: ts(11, color: cyanWhite, bold: true))),
            ],
            const Label('Sets'),
            if (c.sets.isEmpty) const Para('None yet.'),
            for (final (i, s) in c.sets.indexed) Entry(setLine(s), glyph: '${i + 1}.', trailing: fmtTime(s.loggedAt), onTap: () => editSet(context, ex, c, s)),
            const SizedBox(height: 16),
            if (c.sets.isEmpty && inProgress) ...[
              KeyButton('Swap for an alternate', onTap: _alternatesHere(ex).isEmpty ? null : () => _swap(ex)),
              const SizedBox(height: 6),
            ],
            KeyButton(c.sets.isEmpty ? 'Remove from workout' : 'Remove with its sets', onTap: () async {
              if (c.sets.isNotEmpty && !await confirm(context, 'Remove ${ex.name} and its ${c.sets.length} sets?', yes: 'Remove')) return;
              w!.commits.remove(c);
              checkGoals();
              store.save();
              if (context.mounted) Navigator.of(context).pop();
            }),
          ],
        );
      });
}

/// Correcting a logged set: its load, grade, test and reps, or deleting it.
Future<void> editSet(BuildContext context, Exercise ex, Commit commit, LoggedSet s) async {
  var load = s.loadKg;
  var grade = s.grade;
  var test = s.test;
  var side = s.side;
  final reps = TextEditingController(text: s.reps?.toString() ?? '');
  final step = ex.loadKind == LoadKind.plates ? 2.5 : loadStep(ex);
  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final repsValue = int.tryParse(reps.text.trim());
        // Correcting a Warmup to a working grade is refused when the limit is reached.
        final refused = grade != null && s.grade == Grade.warmup && grade != Grade.warmup && refusedByLimit(commit, ex, grade!, side, except: s);
        final ok = grade != null && !refused && (!test || (repsValue != null && repsValue > 0));
        return Dialog(
          backgroundColor: graphite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: primaryC, width: 2)),
          insetPadding: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('CORRECT SET · ${fmtTime(s.loggedAt)}', style: ts(14, spacing: 2)),
                const SizedBox(height: 12),
                Stepper2(text: fmtKg(load), onMinus: load - step < 0 ? null : () => setState(() => load -= step), onPlus: () => setState(() => load += step)),
                const SizedBox(height: 12),
                Choice<Grade>(options: Grade.values, label: gradeLabel, isOn: (g) => g == grade, onTap: (g) => setState(() => grade = g)),
                if (refused) Padding(padding: const EdgeInsets.only(top: 6), child: Text('THE LIMIT IS REACHED: IT STAYS A WARMUP', style: ts(11, color: cyanWhite, bold: true))),
                if (ex.unilateral) ...[
                  const SizedBox(height: 12),
                  Choice<Side>(options: Side.values, label: sideLabel, isOn: (x) => x == side, onTap: (x) => setState(() => side = x)),
                ],
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: KeyButton(test ? 'Test · on' : 'Not a test', on: test, size: 11, onTap: () => setState(() => test = !test))),
                  if (test) ...[const SizedBox(width: 8), SizedBox(width: 110, child: Field(controller: reps, number: true, hint: 'reps', onChanged: (_) => setState(() {})))],
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: KeyButton('Delete', onTap: () {
                    commit.sets.remove(s);
                    checkGoals();
                    store.save();
                    Navigator.pop(ctx);
                  })),
                  const SizedBox(width: 8),
                  Expanded(child: KeyButton('Save', filled: true, onTap: !ok ? null : () {
                    if (load != s.loadKg) s.platesPerSide = ex.loadKind == LoadKind.plates ? platesFor(load, ex.barKg ?? 20) : null;
                    s.loadKg = load;
                    s.grade = grade;
                    s.test = test;
                    s.reps = test ? repsValue : null;
                    if (ex.unilateral) s.side = side;
                    checkGoals();
                    store.save();
                    Navigator.pop(ctx);
                  })),
                ]),
              ]),
            ),
          ),
        );
      },
    ),
  );
}

class PastWorkoutsScreen extends StatelessWidget {
  const PastWorkoutsScreen({super.key});
  @override
  Widget build(BuildContext context) => Live((context) {
        final past = store.workouts.where((w) => w.endedAt != null).toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));
        return Screen(title: 'Past workouts', status: '${past.length} workouts', children: [
          for (final w in past)
            Entry(workoutTitle(w),
                sub: '${w.commits.length} exercises · ${_duration(w)}${w.imported ? ' · imported' : ''}${store.routine(w.routineId) == null ? '' : ' · ${store.routine(w.routineId)!.name}'}',
                onTap: () => push(context, PastWorkoutScreen(workoutId: w.id))),
        ]);
      });
}

class PastWorkoutScreen extends StatelessWidget {
  const PastWorkoutScreen({super.key, required this.workoutId});
  final String workoutId;
  @override
  Widget build(BuildContext context) => Live((context) {
        final w = store.workouts.where((x) => x.id == workoutId).firstOrNull;
        if (w == null) return const Screen(title: 'Workout', children: [Para('Deleted.')]);
        return Screen(
          title: workoutTitle(w),
          status: '${fmtTime(w.startedAt)} · ${_duration(w)}${w.imported ? ' · imported' : ''}',
          children: [
            for (final (i, c) in w.commits.indexed) ...[
              Label('${i + 1} · ${store.exercise(c.exerciseId)?.name ?? '?'}'),
              for (final s in c.sets)
                Entry(setLine(s), trailing: fmtTime(s.loggedAt), onTap: () {
                  final ex = store.exercise(c.exerciseId);
                  if (ex != null) editSet(context, ex, c, s);
                }),
            ],
            const SizedBox(height: 24),
            KeyButton('Delete workout', onTap: () async {
              if (!await confirm(context, 'Delete this workout and its sets?', yes: 'Delete')) return;
              store.workouts.remove(w);
              checkGoals();
              store.save();
              if (context.mounted) Navigator.of(context).pop();
            }),
          ],
        );
      });
}
