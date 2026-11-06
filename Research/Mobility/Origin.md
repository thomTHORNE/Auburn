The spec's mobility text as it stood when mobility was taken out of the spec, quoted from each file.

## Spec/Scope.md

| **Mobility** | Mobility workouts, with a grading system of their own. |

## Spec/Features/Workouts.md

> One visit to train at a gym: starting it, committing exercises to it in order, ending it, and the record of past workouts. A workout is hypertrophy or mobility.

> A workout starts by choosing the gym, then the kind: hypertrophy, unless mobility is chosen.

> The exercises offered are those of the workout's kind that are tied to its gym or to no gym, and are not archived.

> In a mobility workout, a commit takes an optional grade — controlled, improved, or poor — and nothing else.

> Sets, grades, and commits can be corrected or deleted afterwards; the gym and kind cannot be changed once there are commits.

> - A workout is hypertrophy or mobility, never both. Cardio is never a workout; it arrives as activities.

> | A mobility exercise's grade is left blank | The commit stands ungraded |

## Spec/Data Model.md

```dart
enum ExerciseKind { hypertrophy, mobility }
  final ExerciseKind kind;
  final LoadKind? loadKind;           // hypertrophy only
  final bool amap;                    // hypertrophy only
enum WorkoutKind { hypertrophy, mobility }
  final WorkoutKind kind;
  final bool rollOn;       // hypertrophy only; true when the workout starts
enum MobilityGrade { controlled, improved, poor }
  final Modality? modality;           // hypertrophy only
  final MobilityGrade? mobilityGrade; // mobility only, optional
  final String commitId;              // a hypertrophy commit
```

> - A hypertrophy exercise has a load kind and works at least one muscle group. An AMAP exercise resets none of them.
> - A mobility exercise has no load kind, muscle groups, goals, alternates, or AMAP flag.
> - An alternate is a hypertrophy exercise other than the exercise itself.
> - The exercise's kind matches the workout's.
> - A hypertrophy commit always has a modality, except in an imported workout, which has none. With the roll off, the modality is `byFeel`.

## Spec/Features/Exercises.md

> A hypertrophy exercise has a name, a load kind and the equipment value it needs, the muscle groups it works, the AMAP flag, the goals it serves, its alternates, and its gym ties. A mobility exercise has a name, gym ties, and notes.

> - A hypertrophy exercise works at least one muscle group.

## Spec/Features/Muscle Groups.md

> A hypertrophy exercise names the muscle groups it works, at least one.

> - Mobility exercises name no muscle groups.

## Spec/Features/Modality Roll.md

> - Hypertrophy only. Mobility and cardio have no modality.

## Spec/Screens/Screens.md

| 07 | A mobility workout | Mobility exercises and their optional grades | Not yet specified |
