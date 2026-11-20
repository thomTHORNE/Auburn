// Checks the prototype's reading of the spec where a mistake would mislead: rest's rhythm, a goal's reach, and the screens laying out.
import 'dart:convert';
import 'dart:io';

import 'package:auburn_gym_week/logic.dart';
import 'package:auburn_gym_week/model.dart';
import 'package:auburn_gym_week/screens/exercises.dart';
import 'package:auburn_gym_week/screens/goals.dart';
import 'package:auburn_gym_week/screens/home.dart';
import 'package:auburn_gym_week/screens/rest.dart';
import 'package:auburn_gym_week/screens/routines.dart';
import 'package:auburn_gym_week/screens/workout.dart';
import 'package:auburn_gym_week/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final today = DateTime.now();
DateTime ago(int days, [int hour = 18]) => DateTime(today.year, today.month, today.day - days, hour);

Workout workoutOn(int daysAgo, Gym gym, Exercise ex, {Grade grade = Grade.ideal, bool test = false, int? reps, double load = 60}) => Workout(
      gymId: gym.id, startedAt: ago(daysAgo), endedAt: ago(daysAgo, 19),
      commits: [Commit(exerciseId: ex.id, sets: [LoggedSet(loggedAt: ago(daysAgo), loadKg: load, grade: grade, test: test, reps: reps)])],
    );

void seed() {
  store.gyms = [Gym(name: 'Iva Gyma'), Gym(name: 'Gyms4You')];
  store.exercises = [];
  store.goals = [];
  store.routines = [];
  store.routineGroups = [];
  store.workouts = [];
  store.restSteps = [];
  store.properties = [];
  store.propertyValues = [];
}

void main() {
  setUpAll(() async {
    // The real faces, so layouts are judged at their true widths.
    for (final (family, files) in [('Saira', ['Saira-Regular.ttf', 'Saira-Bold.ttf']), ('Gelasio', ['Gelasio.ttf'])]) {
      final loader = FontLoader(family);
      for (final f in files) {
        loader.addFont(File('fonts/$f').readAsBytes().then((b) => ByteData.view(b.buffer)));
      }
      await loader.load();
    }
  });

  test('rest reads the rhythm from the last six gaps', () {
    seed();
    final squat = Exercise(name: 'Squat', loadKind: LoadKind.plates, barKg: 20, mainMovers: {MuscleGroup.quads}, supporting: {MuscleGroup.lowerBack});
    store.exercises.add(squat);
    // Gaps, oldest first: 5 6 5 4 5 6, then 5 days of rest.
    var d = 5;
    final days = [d];
    for (final gap in [6, 5, 4, 5, 6, 5]) {
      d += gap;
      days.add(d);
    }
    for (final day in days) {
      store.workouts.add(workoutOn(day, store.gyms.first, squat));
    }
    final r = readRest()[MuscleGroup.quads]!;
    expect(r.days, 5);
    expect(r.gaps, [5, 6, 5, 4, 5, 6]);
    expect(r.usualGap, 5);
    expect([r.maybeFrom, r.shouldFrom, r.overdueFrom], [4, 5, 8]);
    expect(r.step, RestStep.should);
    expect(r.source, StepSource.rhythm);
    final lower = readRest()[MuscleGroup.lowerBack]!;
    expect(lower.tracked, false);
    expect(lower.days, null);
    expect(lower.lastSupporting, dayOf(ago(5)));
  });

  test('under three gaps the steps are fixed, a warmup resets nothing, and steps set by hand hold', () {
    seed();
    final curl = Exercise(name: 'Curl', mainMovers: {MuscleGroup.biceps});
    store.exercises.add(curl);
    store.workouts..add(workoutOn(9, store.gyms.first, curl))..add(workoutOn(4, store.gyms.first, curl))..add(workoutOn(1, store.gyms.first, curl, grade: Grade.warmup));
    var r = readRest()[MuscleGroup.biceps]!;
    expect(r.days, 4);
    expect(r.source, StepSource.fixed);
    expect(r.step, RestStep.should);
    store.restSteps.add(RestSteps(group: MuscleGroup.biceps, maybeFrom: 6, shouldFrom: 8, overdueFrom: 12));
    r = readRest()[MuscleGroup.biceps]!;
    expect(r.source, StepSource.hand);
    expect(r.step, RestStep.shouldnt);
  });

  test('a long gap is flagged', () {
    seed();
    final squat = Exercise(name: 'Squat', mainMovers: {MuscleGroup.quads});
    store.exercises.add(squat);
    var d = 2;
    final days = [d];
    for (final gap in [23, 6, 7, 6, 6]) {
      d += gap;
      days.add(d);
    }
    for (final day in days) {
      store.workouts.add(workoutOn(day, store.gyms.first, squat));
    }
    expect(readRest()[MuscleGroup.quads]!.backAfter, 23);
  });

  test('a reps target is reached only by a test its rules let through, and an undo passes over it', () {
    seed();
    final pull = Exercise(name: 'Pull-up', loadKind: LoadKind.bodyweight, mainMovers: {MuscleGroup.lats});
    store.exercises.add(pull);
    final goal = Goal(name: 'Bodyweight pull-up', state: GoalState.active, activatedAt: ago(20),
        target: Target(exerciseId: pull.id, parameter: Param.reps, value: 8, grades: {Grade.ideal, Grade.acceptable}));
    store.goals.add(goal);
    store.workouts
      ..add(workoutOn(30, store.gyms.first, pull, test: true, reps: 9, load: 0)) // before it was active
      ..add(workoutOn(10, store.gyms.first, pull, test: true, reps: 9, load: 0, grade: Grade.yielding)) // grade does not count
      ..add(workoutOn(8, store.gyms.first, pull, test: true, reps: 5, load: 0, grade: Grade.acceptable));
    checkGoals();
    expect(goal.target!.reachedAt, null);
    expect(goalGap(goal).gap, 3);
    store.workouts.add(workoutOn(3, store.gyms.first, pull, test: true, reps: 8, load: 0));
    checkGoals();
    expect(goal.target!.reachedAt, ago(3));
    expect(owedPrompts(), [goal]);
    undoReach(goal);
    expect(goal.target!.reachedAt, null);
    store.workouts.add(workoutOn(1, store.gyms.first, pull, test: true, reps: 8, load: 0));
    checkGoals();
    keepReach(goal);
    expect(goal.state, GoalState.reached);
    expect(goal.endedAt, ago(1));
  });

  test('a routine offers a goal\'s target up front and its alternates on demand, and nothing from another gym', () {
    seed();
    final iva = store.gyms[0], g4y = store.gyms[1];
    final band = Exercise(name: 'Band negatives', gymIds: {iva.id}, mainMovers: {MuscleGroup.lats});
    final assisted = Exercise(name: 'Assisted negatives', gymIds: {g4y.id}, mainMovers: {MuscleGroup.lats});
    final pull = Exercise(name: 'Pull-up', gymIds: {iva.id, g4y.id}, mainMovers: {MuscleGroup.lats});
    store.exercises.addAll([band, assisted, pull]);
    final goal = Goal(name: 'Pull-up', alternateIds: [band.id, assisted.id], state: GoalState.active, activatedAt: ago(1), target: Target(exerciseId: pull.id, value: 8, parameter: Param.reps));
    store.goals.add(goal);
    final r = Routine(name: 'Pull', gymId: iva.id, items: [RoutineItem(goalId: goal.id), RoutineItem(exerciseId: pull.id), RoutineItem(exerciseId: band.id)]);
    final offer = routineOffer(r, iva.id);
    expect(offer.first.goal, goal);
    expect(offer.first.exercises.map((e) => e.name), ['Pull-up']);
    expect(offer.first.alternates.map((e) => e.name), ['Band negatives']); // Assisted negatives is at the other gym
    expect(offer.length, 1); // Pull-up and Band negatives are offered once, through the goal
  });

  test('alternates are the goal\'s while its target is active, the exercise\'s own otherwise, and must fit', () {
    seed();
    final iva = store.gyms[0], g4y = store.gyms[1];
    final press = Exercise(name: 'Shoulder press', gymIds: {iva.id}, mainMovers: {MuscleGroup.frontDelts});
    final db = Exercise(name: 'Dumbbell press', gymIds: {iva.id, g4y.id}, mainMovers: {MuscleGroup.frontDelts, MuscleGroup.sideDelts});
    final raise = Exercise(name: 'Lateral raise', gymIds: {iva.id}, mainMovers: {MuscleGroup.sideDelts});
    final elsewhere = Exercise(name: 'Machine press', gymIds: {g4y.id}, mainMovers: {MuscleGroup.frontDelts});
    press.alternateIds = [raise.id];
    store.exercises.addAll([press, db, raise, elsewhere]);
    expect(fitsAsAlternate(press, db), true);
    expect(fitsAsAlternate(press, raise), false); // no shared main mover
    expect(fitsAsAlternate(press, elsewhere), false); // not tied to every gym the press is
    expect(alternatesOf(press).map((e) => e.name), ['Lateral raise']);
    final goal = Goal(name: 'Press', alternateIds: [db.id], target: Target(exerciseId: press.id, value: 50));
    store.goals.add(goal);
    expect(alternatesOf(press).map((e) => e.name), ['Lateral raise']); // a draft does not win
    goal.state = GoalState.active;
    goal.activatedAt = ago(1);
    expect(alternatesOf(press).map((e) => e.name), ['Dumbbell press']);
    expect(targetTakenBy(press.id), goal);
    abandon(goal, 'Shoulder hurt.');
    expect(alternatesOf(press).map((e) => e.name), ['Lateral raise']);
    expect(targetTakenBy(press.id), null);
  });

  test('a set limit refuses the set past it, counts no warmup, holds per side, and the lower of two goals holds', () {
    seed();
    final raise = Exercise(name: 'Lateral raise', unilateral: true, mainMovers: {MuscleGroup.sideDelts});
    final press = Exercise(name: 'Shoulder press', mainMovers: {MuscleGroup.sideDelts, MuscleGroup.frontDelts});
    final other = Exercise(name: 'Front raise', mainMovers: {MuscleGroup.frontDelts});
    store.exercises.addAll([raise, press, other]);
    final a = Goal(name: 'Level the shoulders', target: Target(exerciseId: raise.id, value: 12, side: TargetSide.left));
    a.setLimit(raise.id, 4);
    a.setLimit(raise.id, 3); // a draft replaces
    expect(a.setLimits.length, 1);
    final b = Goal(name: 'Press', alternateIds: [raise.id], target: Target(exerciseId: press.id, value: 50));
    b.setLimit(raise.id, 2);
    store.goals.addAll([a, b]);
    expect(setLimitOn(raise.id), null); // drafts limit nothing
    for (final g in [a, b]) {
      g.state = GoalState.active;
      g.activatedAt = ago(2);
    }
    expect(setLimitOn(raise.id), 2);
    b.setLimit(raise.id, 5); // active: kept with its date
    expect(b.setLimits.length, 2);
    expect(setLimitOn(raise.id), 3);
    final c = Commit(exerciseId: raise.id, sets: [
      for (final side in [Side.left, Side.left, Side.left]) LoggedSet(loggedAt: DateTime.now(), loadKg: 10, grade: Grade.ideal, side: side),
      LoggedSet(loggedAt: DateTime.now(), loadKg: 4, grade: Grade.warmup, side: Side.left),
    ]);
    expect(refusedByLimit(c, raise, Grade.ideal, Side.left), true);
    expect(refusedByLimit(c, raise, Grade.warmup, Side.left), false);
    expect(refusedByLimit(c, raise, Grade.ideal, Side.right), false);
    expect(refusedByLimit(Commit(exerciseId: other.id), other, Grade.ideal, null), false);
  });

  test('a target on both sides is reached only when each side meets it in one workout', () {
    seed();
    final raise = Exercise(name: 'Lateral raise', unilateral: true, mainMovers: {MuscleGroup.sideDelts});
    store.exercises.add(raise);
    final goal = Goal(name: 'Both shoulders at 12', state: GoalState.active, activatedAt: ago(10),
        target: Target(exerciseId: raise.id, value: 12, side: TargetSide.both));
    store.goals.add(goal);
    Workout one(int daysAgo, List<(Side, double)> sets) => Workout(gymId: store.gyms.first.id, startedAt: ago(daysAgo), endedAt: ago(daysAgo, 19), commits: [
          Commit(exerciseId: raise.id, sets: [for (final (i, (side, kg)) in sets.indexed) LoggedSet(loggedAt: ago(daysAgo).add(Duration(minutes: i)), loadKg: kg, grade: Grade.ideal, side: side)]),
        ]);
    store.workouts..add(one(6, [(Side.left, 12), (Side.right, 10)]))..add(one(4, [(Side.left, 10), (Side.right, 12)]));
    checkGoals();
    expect(goal.target!.reachedAt, null);
    expect(goalGap(goal).gap, 0); // each side has reached 12 on its own; the gap is the farther side's
    store.workouts.add(one(2, [(Side.left, 12), (Side.right, 12.5)]));
    checkGoals();
    expect(goal.target!.reachedAt, ago(2).add(const Duration(minutes: 1)));
    final left = exerciseLine(raise.id, Param.load, (s) => true, side: Side.left);
    expect(left.map((p) => p.value), [12, 10, 12]);
    expect(left.last.given, 1);
  });

  test('records from before 0.4 are tied to gyms, and a goal\'s explanation and exercises carry over', () {
    seed();
    final iva = store.gyms[0], g4y = store.gyms[1];
    final v1 = {
      'gyms': [iva.toJson(), g4y.toJson()],
      'exercises': [
        {'id': 'squat', 'name': 'Squat', 'loadKind': 'plates', 'barKg': 20, 'gymIds': []},
        {'id': 'curl', 'name': 'Curl', 'loadKind': 'dumbbells', 'stepKg': 2, 'gymIds': []},
        {'id': 'press', 'name': 'Leg press', 'loadKind': 'stack', 'stepKg': 5, 'gymIds': []},
      ],
      'goals': [
        {'id': 'g', 'name': 'Squat 100', 'explanation': 'Heavier, with control.', 'exerciseIds': ['squat', 'press'], 'state': 'active',
          'activatedAt': ago(5).toIso8601String(), 'target': {'exerciseId': 'squat', 'parameter': 'load', 'value': 100, 'grades': ['ideal']}},
      ],
      'routines': [{'id': 'r', 'name': 'Legs', 'gymIds': [], 'items': []}],
      'workouts': [
        {'id': 'w', 'gymId': g4y.id, 'routineId': 'r', 'startedAt': ago(3).toIso8601String(), 'endedAt': ago(3, 19).toIso8601String(),
          'commits': [{'id': 'c', 'exerciseId': 'squat', 'sets': [{'id': 's', 'loggedAt': ago(3).toIso8601String(), 'loadKg': 80, 'grade': 'ideal'}]}]},
      ],
    };
    store.read(jsonDecode(jsonEncode(v1)));
    expect(store.exercise('squat')!.gymIds, {g4y.id}); // the gyms it was done at
    expect(store.exercise('curl')!.gymIds, {iva.id, g4y.id}); // never done: every gym, as it was offered before
    final g = store.goal('g')!;
    expect(g.why, 'Heavier, with control.');
    expect(g.alternateIds, ['press']);
    expect(g.exerciseIds, ['squat', 'press']);
    expect(store.routine('r')!.gymId, g4y.id); // the gym it was last started at
  });

  test('everything written out reads back the same', () {
    seed();
    final gym = store.gyms.first;
    final pull = Exercise(name: 'Pull-up', loadKind: LoadKind.bodyweight, mainMovers: {MuscleGroup.lats}, supporting: {MuscleGroup.biceps}, gymIds: {gym.id}, observations: 'Slow.');
    store.exercises.add(pull);
    store.goals.add(Goal(name: 'Pull-up', why: 'Strength.', state: GoalState.active, activatedAt: ago(9), target: Target(exerciseId: pull.id, parameter: Param.reps, value: 8, minLoadKg: 0)));
    store.routineGroups.add(RoutineGroup(name: 'PPL'));
    store.properties.add(Property(name: 'Form'));
    store.propertyValues.add(PropertyValue(propertyId: store.properties.first.id, name: 'Strict'));
    pull.propertyValueIds.add(store.propertyValues.first.id);
    store.goals.first.setLimit(pull.id, 3);
    store.routines.add(Routine(name: 'Pull', gymId: gym.id, groupId: store.routineGroups.first.id, items: [RoutineItem(goalId: store.goals.first.id), RoutineItem(exerciseId: pull.id)]));
    store.workouts.add(workoutOn(3, gym, pull, test: true, reps: 6, load: 0));
    store.restSteps.add(RestSteps(group: MuscleGroup.lats, maybeFrom: 2, shouldFrom: 3, overdueFrom: 6));
    final written = jsonEncode(store);
    seed();
    store.read(jsonDecode(written));
    expect(jsonEncode(store), written);
    expect(store.workouts.single.commits.single.sets.single.reps, 6);
  });

  testWidgets('every screen lays out on a narrow phone', (tester) async {
    seed();
    tester.view.physicalSize = const Size(360 * 3, 720 * 3);
    tester.view.devicePixelRatio = 3;
    final gymIds = {store.gyms.first.id};
    store.properties.add(Property(name: 'Form'));
    store.propertyValues..add(PropertyValue(propertyId: store.properties.first.id, name: 'Freeform'))..add(PropertyValue(propertyId: store.properties.first.id, name: 'Strict'));
    final bench = Exercise(name: 'Chest Press Incline', loadKind: LoadKind.plates, barKg: 20, gymIds: gymIds, mainMovers: {MuscleGroup.chest, MuscleGroup.frontDelts}, supporting: {MuscleGroup.triceps},
        propertyValueIds: {store.propertyValues.first.id});
    final fly = Exercise(name: 'Chest Fly', stepKg: 7, gymIds: {...gymIds}, unilateral: true, mainMovers: {MuscleGroup.chest}, propertyValueIds: {store.propertyValues.last.id});
    store.exercises.addAll([bench, fly]);
    for (final day in [30, 25, 19, 14, 9, 4]) {
      store.workouts.add(workoutOn(day, store.gyms.first, bench));
    }
    final goal = Goal(name: 'Master the incline press', why: 'Heavier, with control.', alternateIds: [fly.id], state: GoalState.active, activatedAt: ago(20), target: Target(exerciseId: bench.id, value: 80));
    goal.setLimit(fly.id, 4);
    store.goals.add(goal);
    final routine = Routine(name: 'Push', gymId: store.gyms.first.id, items: [RoutineItem(goalId: goal.id), RoutineItem(exerciseId: fly.id)]);
    store.routines.add(routine);
    final w = Workout(gymId: store.gyms.first.id, routineId: routine.id, startedAt: DateTime.now(), commits: [Commit(exerciseId: bench.id), Commit(exerciseId: fly.id)]);
    final screens = <Widget>[
      const HomeScreen(), const RestScreen(), const MuscleScreen(group: MuscleGroup.chest), const ExercisesScreen(),
      ExerciseScreen(exerciseId: bench.id), ExerciseEditScreen(exerciseId: bench.id), const GoalsScreen(), GoalScreen(goalId: goal.id),
      const RoutinesScreen(), RoutineScreen(routineId: routine.id), const StartWorkoutScreen(), const PastWorkoutsScreen(), const GymsScreen(),
    ];
    for (final s in screens) {
      await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: s));
      await tester.pump();
      expect(tester.takeException(), null, reason: '${s.runtimeType}');
    }
    // Touching the chart selects the nearest point and shows its readout.
    await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: ExerciseScreen(exerciseId: bench.id)));
    await tester.pump();
    final chart = find.byType(LineChart);
    await tester.ensureVisible(chart);
    await tester.tapAt(tester.getTopRight(chart) + const Offset(-12, 60));
    await tester.pump();
    expect(find.textContaining('GIVEN 1 OF 1 SETS'), findsOneWidget);
    expect(tester.takeException(), null);
    store.workouts.add(w);
    for (final s in <Widget>[const WorkoutScreen(), SetScreen(workoutId: w.id, commitId: w.commits[0].id), SetScreen(workoutId: w.id, commitId: w.commits[1].id)]) {
      await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: s));
      await tester.pump();
      expect(tester.takeException(), null, reason: '${s.runtimeType}');
    }
    // Logging a set: the grade commits it.
    await tester.tap(find.text('IDEAL'));
    await tester.pump();
    expect(w.commits[1].sets.length, 1);
    expect(w.commits[1].sets.single.loadKg, 7);
    expect(w.commits[1].sets.single.side, Side.left);
    // A test is logged only with its reps.
    await tester.tap(find.text('MARK NEXT SET A TEST'));
    await tester.pump();
    await tester.tap(find.text('IDEAL'));
    await tester.pump();
    expect(w.commits[1].sets.length, 1);
    expect(find.text('A TEST IS LOGGED ONLY WITH ITS REPS'), findsOneWidget);
  });
}
