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
/// Rest bands for one muscle group, or for cardio. One exists for each of the 21.
class RestSettings {
  final MuscleGroup? group; // null: cardio
  final int maybeFrom;      // default 3; fewer days is repair
  final int trainFrom;      // default 4
  final int overdueFrom;    // default 5; the overdue limit
}

class Split {
  final String name;
  final Set<MuscleGroup> groups; // a group may sit in several splits
  final bool archived;
}
```

- `0 < maybeFrom < trainFrom < overdueFrom`.

## Gyms

```dart
class Gym {
  final String name; // home is a gym
  final bool archived;
}
```

## Exercises

```dart
enum ExerciseKind { hypertrophy, mobility }
enum LoadKind { plates, stack, dumbbells, bodyweight }

class Exercise {
  final String name;
  final ExerciseKind kind;
  final LoadKind? loadKind;           // hypertrophy only
  final double? barKg;                // plates only
  final double? stepKg;               // stack and dumbbells only: the step between loads
  final bool amap;                    // hypertrophy only
  final Set<MuscleGroup> muscleGroups;
  final Set<String> goalIds;
  final List<String> alternateIds;    // ordered
  final Set<String> gymIds;           // empty: the same everywhere
  final String observations;          // the notes, shown as three tabs
  final String settings;
  final String form;
  final ExerciseParameter shownParameter; // what Progress plots; default load
  final bool archived;
}

enum ExerciseParameter { load, reps }
```

- A hypertrophy exercise has a load kind and works at least one muscle group. An AMAP exercise resets none of them.
- A mobility exercise has no load kind, muscle groups, goals, alternates, or AMAP flag.
- `barKg` is set exactly when the load kind is plates; `stepKg` exactly when it is stack or dumbbells.
- An alternate is a hypertrophy exercise other than the exercise itself.

## Goals

```dart
enum ActivityKind { run, treadmill, hike }
enum GoalState { draft, active, reached, abandoned }

class Goal {
  final String name;
  final String explanation;
  final GoalState state;
  final DateTime? activatedAt;           // set when made active
  final DateTime? endedAt;               // reached or abandoned
  final String? abandonedBecause;        // abandoned only
  final String? fromGoalId;              // the goal this one was started from
  final TargetParameter? shownParameter; // what the chart plots; null: the current target's parameter
}

enum TargetParameter { load, reps, pace, duration, distance, averageHeartRate }

/// A step or a final target. A goal's targets are reached in position order; the last is the final target.
class Target {
  final String goalId;
  final int position;               // from 1, without gaps
  final String? exerciseId;         // one of the goal's exercises; or
  final ActivityKind? activityKind; // an activity kind
  final TargetParameter parameter;
  final double value;               // kg, reps, seconds per km, seconds, km, or bpm
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

- A goal's exercises are the exercises that name it.
- `activatedAt` is set exactly when the state is not draft; `endedAt` exactly when it is reached or abandoned; `abandonedBecause` exactly when abandoned, and never empty.
- A goal that is not a draft has at least one target.
- A target has exactly one of `exerciseId` and `activityKind`. On an exercise, its parameter is load or reps, the exercise names the goal, and it has at least one grade. On an activity kind, its parameter is pace, duration, distance, or average heart rate, and it has no grades.
- `minLoadKg` is set only on a reps target. `minDistanceKm ≤ maxDistanceKm` when both are set.
- `kept` is true only with `reachedAt`. A reached goal's targets are all kept.
- A target's reach is stored, not derived: the user keeps or undoes it, and an ended goal never changes.

## Workouts

```dart
enum WorkoutKind { hypertrophy, mobility }

class Workout {
  final String gymId;
  final WorkoutKind kind;
  final DateTime startedAt;
  final DateTime? endedAt; // null while in progress
  final bool rollOn;       // hypertrophy only; true when the workout starts
  final bool imported;     // from the Notion history
}
```

- One workout is in progress at a time.
- An imported workout ends at its last set's time.

```dart
enum Modality { slowAndControlled, counted, byFeel }
enum MobilityGrade { controlled, improved, poor }

/// One exercise committed to one workout.
class Commit {
  final String workoutId;
  final String exerciseId;
  final int position;                 // commit order, from 1
  final Modality? modality;           // hypertrophy only
  final MobilityGrade? mobilityGrade; // mobility only, optional
}
```

- The exercise's kind matches the workout's.
- A hypertrophy commit always has a modality, except in an imported workout, which has none. With the roll off, the modality is `byFeel`.
- A commit records the exercise actually done. An alternate taken in place of another is simply that alternate.

```dart
enum Grade { ideal, acceptable, light, yielding, warmup }

class LoggedSet {
  final String commitId;              // a hypertrophy commit
  final DateTime loggedAt;            // sets are ordered by it
  final double loadKg;                // the total; for dumbbells, one dumbbell; for bodyweight, the added load
  final List<double>? platesPerSide;  // plates only, as entered
  final Grade? grade;
  final int? reps;
}
```

Dart's core library owns `Set`, so the record is `LoggedSet`.

- A set has a grade, except in an imported workout, where it may have none.
- Reps are present only when the commit's modality is `counted`, or in an imported workout.

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

## The overdue log

```dart
class OverdueEntry {
  final DateTime answeredAt;
  final String answer; // tied to no muscle group, exercise, or workout
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

Gyms, exercises, and splits are archived, never deleted: history points at them. An archived record is kept in history and offered nowhere new. A draft goal is deleted outright with its targets, and its exercises stop naming it; a goal that has been active is never deleted. Workouts, commits, sets, and activities are deleted outright, along with anything they own. Overdue entries are never deleted.
