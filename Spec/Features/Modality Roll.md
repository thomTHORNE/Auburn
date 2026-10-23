# Modality roll

## What it is

The modality an exercise is done with in a hypertrophy workout — slow and controlled, counted, or by feel — rolled when the exercise is committed, so training stays varied by design.

## Behavior

### The roll

While a workout's roll is on, each commit rolls one of the three modalities, each equally likely. With it off, a commit is by feel. A new hypertrophy workout starts with the roll on; it can be switched off and on at any time, and commits already made keep their modality.

### Never re-rolled

A commit's modality never changes. Swapping a commit for an alternate keeps the commit's modality, and an exercise removed and committed again in the same workout gets back the modality it was first given.

### Shown

The modality is shown prominently on the exercise for as long as it is being done. A counted modality brings up the reps input specified in [Sets](Sets.md).

## States

| State | Kind | Meaning |
|---|---|---|
| Roll on, roll off | Persisted, per workout | Whether the next commit rolls |

## Constraints

- Hypertrophy only. Mobility and cardio have no modality.
- Imported workouts carry no modality.

## Edge cases

| Scenario | Behavior |
|---|---|
| The roll is switched off between two commits | The first keeps its rolled modality; the second is by feel |
| The roll is switched back on | The next commit rolls |
| A commit is swapped for its alternate | The alternate is done with the modality already rolled |
