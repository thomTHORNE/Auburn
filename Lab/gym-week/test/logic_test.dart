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
}

void main() {
  setUpAll(() async {
    // The real faces, so layouts are judged at their true widths.
    for (final (family, files) in [('Courier Prime', ['CourierPrime-Regular.ttf', 'CourierPrime-Bold.ttf']), ('Gelasio', ['Gelasio.ttf'])]) {
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
    final goal = Goal(name: 'Bodyweight pull-up', exerciseIds: {pull.id}, state: GoalState.active, activatedAt: ago(20),
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

  test('a routine offers each exercise once, and an alternate where its own gym is elsewhere', () {
    seed();
    final iva = store.gyms[0], g4y = store.gyms[1];
    final band = Exercise(name: 'Band negatives');
    final assisted = Exercise(name: 'Assisted negatives', gymIds: {g4y.id}, alternateIds: [band.id]);
    final pull = Exercise(name: 'Pull-up');
    store.exercises.addAll([band, assisted, pull]);
    final goal = Goal(name: 'Pull-up', exerciseIds: {pull.id, assisted.id}, state: GoalState.active, activatedAt: ago(1), target: Target(exerciseId: pull.id, value: 8, parameter: Param.reps));
    store.goals.add(goal);
    final r = Routine(name: 'Pull', items: [RoutineItem(goalId: goal.id), RoutineItem(exerciseId: pull.id), RoutineItem(exerciseId: band.id)]);
    final offer = routineOffer(r, iva.id);
    expect(offer.first.goal, goal);
    expect(offer.first.exercises.map((e) => e.name), ['Pull-up', 'Band negatives']);
    expect(offer.length, 1);
    expect(routineOffer(r, g4y.id).first.exercises.map((e) => e.name), ['Pull-up', 'Assisted negatives']);
  });

  test('everything written out reads back the same', () {
    seed();
    final gym = store.gyms.first;
    final pull = Exercise(name: 'Pull-up', loadKind: LoadKind.bodyweight, mainMovers: {MuscleGroup.lats}, supporting: {MuscleGroup.biceps}, gymIds: {gym.id}, observations: 'Slow.');
    store.exercises.add(pull);
    store.goals.add(Goal(name: 'Pull-up', exerciseIds: {pull.id}, state: GoalState.active, activatedAt: ago(9), target: Target(exerciseId: pull.id, parameter: Param.reps, value: 8, minLoadKg: 0)));
    store.routineGroups.add(RoutineGroup(name: 'PPL'));
    store.routines.add(Routine(name: 'Pull', groupId: store.routineGroups.first.id, items: [RoutineItem(goalId: store.goals.first.id), RoutineItem(exerciseId: pull.id)]));
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
    final bench = Exercise(name: 'Chest Press Incline : bar', loadKind: LoadKind.plates, barKg: 20, mainMovers: {MuscleGroup.chest, MuscleGroup.frontDelts}, supporting: {MuscleGroup.triceps});
    final fly = Exercise(name: 'Chest Fly : : pin-machine', stepKg: 7, mainMovers: {MuscleGroup.chest});
    store.exercises.addAll([bench, fly]);
    for (final day in [30, 25, 19, 14, 9, 4]) {
      store.workouts.add(workoutOn(day, store.gyms.first, bench));
    }
    final goal = Goal(name: 'Master the incline press', explanation: 'Heavier, with control.', exerciseIds: {bench.id, fly.id}, state: GoalState.active, activatedAt: ago(20), target: Target(exerciseId: bench.id, value: 80));
    store.goals.add(goal);
    final routine = Routine(name: 'Push', items: [RoutineItem(goalId: goal.id), RoutineItem(exerciseId: fly.id)]);
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
    // A test is logged only with its reps.
    await tester.tap(find.text('MARK NEXT SET A TEST'));
    await tester.pump();
    await tester.tap(find.text('IDEAL'));
    await tester.pump();
    expect(w.commits[1].sets.length, 1);
    expect(find.text('A TEST IS LOGGED ONLY WITH ITS REPS'), findsOneWidget);
  });
}
