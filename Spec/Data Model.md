# Data Model

This document defines every record Auburn keeps — its fields, its types, and the rules that govern it. All feature specs reference this document. If something isn't defined here, it doesn't exist in Auburn.

The model is stated in the type language of the stack Auburn is built with, rather than prose tables — the type system states precisely what a table would only approximate.

---

## Every record

Every stored record carries an `id` (a UUIDv7 generated on the phone), `createdAt`, and `updatedAt`. They are left out of the types below.

Loads are kilograms to 0.25 kg. Distances are kilometres. Nothing stored is derived: rest, overdue, a workout's title and duration, and progress are computed from the records.

## Muscle groups

```dart
enum MuscleGroup {
  chest, frontDelts, sideDelts, rearDelts, biceps, triceps, forearms,
  lats, upperBack, traps, lowerBack, abs, obliques,
  quads, hamstrings, glutes, calves, adductors, abductors, neck,
}
```

The list is fixed. A muscle group is not a record; what the user sets for it is.

```dart
/// Rest steps set by hand for one muscle group, or for cardio. Absent: its steps follow its rhythm.
class RestSteps {
  final MuscleGroup? group; // null: cardio
  final int maybeFrom;
  final int shouldFrom;
  final int overdueFrom;
}

class Split {
  final String name;
  final Set<MuscleGroup> groups; // a group may sit in several splits
  final bool archived;
}
```

- `0 < maybeFrom < shouldFrom < overdueFrom`. At most one exists per group, and one for cardio.

## Gyms

```dart
class Gym {
  final String name; // home is a gym
  final bool archived;
}
```

## Exercises

```dart
enum LoadKind { plates, stack, dumbbells, bodyweight }

class Exercise {
  final String name;
  final LoadKind loadKind;
  final double? barKg;                // plates only
  final double? stepKg;               // stack and dumbbells only: the step between loads
  final bool unilateral;              // its sets record a side
  final Set<MuscleGroup> mainMovers;
  final Set<MuscleGroup> supporting;
  final List<String> alternateIds;    // ordered; its own, used while it is no active goal's target
  final Set<String> gymIds;           // at least one
  final Set<String> propertyValueIds; // at most one value of each property
  final String observations;          // the notes, shown as three tabs
  final String settings;
  final String form;
  final ExerciseParameter shownParameter; // what Progress plots; default load
  final Set<Grade> shownGrades;           // the grades its line is given; default Ideal
  final bool archived;
}

enum ExerciseParameter { load, reps }

/// A property the user made, such as Form.
class Property {
  final String name;
}

class PropertyValue {
  final String propertyId;
  final String name;                  // such as Strict
}
```

- A group is never in both `mainMovers` and `supporting`.
- `barKg` is set exactly when the load kind is plates; `stepKg` exactly when it is stack or dumbbells.
- An alternate is an exercise other than the exercise itself.
- `gymIds` is never empty.

## Goals

```dart
enum ActivityKind { run, treadmill, hike }
enum GoalState { draft, active, reached, abandoned }

class Goal {
  final String name;
  final List<String> alternateIds;       // ordered
  final String why;                      // the start answers; empty when unanswered
  final String reachedMeans;
  final String hardestExpected;
  final String? whatGotYouThere;         // reached only; the end answer
  final GoalState state;
  final DateTime? activatedAt;           // set when made active
  final DateTime? endedAt;               // reached or abandoned
  final String? abandonedBecause;        // abandoned only
  final String? fromGoalId;              // the goal this one was started from
  final TargetParameter? shownParameter; // what the chart plots; null: the current target's parameter
  final Set<String> hiddenExerciseIds;   // exercises whose lines the chart hides; never the target's
  final Set<Grade> shownGrades;          // the grades its alternates' lines are given; default Ideal
}

enum TargetParameter { load, reps, pace, duration, distance, averageHeartRate }
enum TargetSide { left, right, both }

/// A goal's target.
class Target {
  final String goalId;
  final String? exerciseId;         // the exercise it sits on; or
  final ActivityKind? activityKind; // an activity kind
  final TargetParameter? parameter; // set before the goal is made active
  final double? value;              // kg, reps, seconds per km, seconds, km, or bpm
  final TargetSide? side;           // set exactly when its exercise is unilateral
  final Set<Grade> grades;          // targets on an exercise: the grades that count
  final double? minLoadKg;          // reps targets: the least load that counts
  final double? minDistanceKm;      // targets on an activity kind: only activities in this range count
  final double? maxDistanceKm;
  final DateTime? reachedAt;        // the date of the fact that reached it
  final String? reachedById;        // that set or activity
  final bool kept;                  // the user kept the mark
  final DateTime? passedUntil;      // after an undo: facts up to here never reach it
}
```

- A goal names its target's exercise through its target, and its alternates; an exercise serves the goals that name it.
- `activatedAt` is set exactly when the state is not draft; `endedAt` exactly when it is reached or abandoned; `abandonedBecause` exactly when abandoned, and never empty.
- A goal has exactly one target, made with it. A goal that is not a draft has its target's parameter and value set.
- An exercise is the target of at most one goal that is a draft or active.
- `whatGotYouThere` is set only when reached.
- A target has exactly one of `exerciseId` and `activityKind`. On an exercise, its parameter is load or reps, and it has at least one grade. A goal that is not a draft has its target's exercise not archived; a draft's may be archived until it is made active. On an activity kind, its parameter is pace, duration, distance, or average heart rate, and it has no grades.
- `minLoadKg` is set only on a reps target. `minDistanceKm ≤ maxDistanceKm` when both are set.
- `kept` is true only with `reachedAt`. A reached goal's target is kept.
- A target's reach is stored, not derived: the user keeps or undoes it, and an ended goal never changes.

```dart
/// A limit of sets per workout on one exercise a goal names. From activation, every change is a new record, and the latest holds.
class SetLimit {
  final String goalId;
  final String exerciseId;
  final int? sets;       // at least 1; null: the limit was removed
  final DateTime setAt;
}
```

- While a goal is a draft, its set limits are replaced, not kept. From activation, the target's exercise's limit never changes, and each change to an alternate's is a new record.

## Routines

```dart
class RoutineGroup {
  final String name;
}

class Routine {
  final String name;
  final String? groupId;     // null: standalone
  final String gymId;
  final bool archived;
}

/// One exercise or goal in a routine, in order.
class RoutineItem {
  final String routineId;
  final int position;        // from 1, without gaps
  final String? exerciseId;  // exactly one of these two
  final String? goalId;
}
```

- An exercise or a goal appears in a routine at most once.
- A routine's goals are active.
- A routine's exercises are tied to its gym when added; a goal whose target sits on an exercise is added only if that exercise is.

## Workouts

```dart
class Workout {
  final String gymId;
  final String? routineId; // the routine it was started from
  final DateTime startedAt;
  final DateTime? endedAt; // null while in progress
  final bool imported;     // from the Notion history
}
```

- One workout is in progress at a time.
- An imported workout ends at its last set's time.

```dart

/// One exercise committed to one workout.
class Commit {
  final String workoutId;
  final String exerciseId;
  final int position;                 // commit order, from 1
}
```

- A commit records the exercise actually done. An alternate taken in place of another is simply that alternate.

```dart
enum Grade { ideal, acceptable, light, yielding, warmup }
enum Side { left, right }

class LoggedSet {
  final String commitId;
  final DateTime loggedAt;            // sets are ordered by it
  final double loadKg;                // the total; for dumbbells, one dumbbell; for bodyweight, the added load
  final List<double>? platesPerSide;  // plates only, as entered
  final Grade? grade;
  final bool test;
  final int? reps;
  final Side? side;                   // unilateral exercises; null on sets logged before it was marked, and on imported sets
}
```

Dart's core library owns `Set`, so the record is `LoggedSet`.

- A set has a grade, except in an imported workout, where it may have none.
- A set has reps exactly when it is a test.
- A set on a unilateral exercise has a side, unless it was logged before the exercise was marked unilateral, or imported.

## Activities

```dart
/// A run, treadmill session, or hike imported from intervals.icu.
class Activity {
  final String sourceId;   // the intervals.icu activity id; unique
  final ActivityKind kind;
  final DateTime startedAt;
  final Duration duration; // timer time
  final double distanceKm;
  final int? averageHeartRate;
}
```

## Settings

```dart
enum ThemeMode { system, dark, light }

enum HomeWidgetKind { rest, goals, cardio }

class HomeWidget {
  final HomeWidgetKind kind;
  final bool fullWidth;
}

/// One exists.
class Settings {
  final ThemeMode themeMode; // default system
  final bool sound; // default true
  final int soundVolume; // percent, 0–100, default 100
  final List<HomeWidget> homeWidgets; // in reading order; default rest full, goals half, cardio half
}
```

## Deleting

Gyms, exercises, splits, and routines are archived, never deleted: history points at them. An exercise with no sets has no history, and can be deleted outright, as specified in [Exercises](Features/Exercises.md#archiving); so can a routine no workout was started from, as specified in [Routines](Features/Routines.md#archiving). An archived record is kept in history and offered nowhere new, until it is restored; restored, it is offered again with its history whole. A routine group is deleted outright; its routines stand alone. A draft goal is deleted outright with its target; a goal that has been active is never deleted. Workouts, commits, sets, and activities are deleted outright, along with anything they own. Rest steps set by hand are deleted outright when handed back to the rhythm. Properties and property values are deleted outright, and leave the exercises that held them.
