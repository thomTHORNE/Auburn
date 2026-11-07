# Sets

## What it is

Logging a set — its load and its grade, plus reps when it is a test — and correcting it afterwards. Logging the next set is always the foremost action of a workout in progress.

## Behavior

### Logging

A set is logged when its grade is tapped. Load and reps are set first; the grade commits them. Grades are Ideal, Acceptable, Light, Yielding, and Warmup, each shown distinctly. Ideal has the largest key.

### Load

The load is entered through the exercise's load kind, in kilograms (units are the [Data Model](../Data%20Model.md#every-record)'s):

| Load kind | Input | Stored load |
|---|---|---|
| Plates | Plate keys add a plate to each side; an undo key removes the last one. The bar's weight is the exercise's `barKg` | Bar plus both sides; the plates per side are kept as entered |
| Stack | Up and down by the exercise's `stepKg` | The pin's weight |
| Dumbbells | Up and down by the exercise's `stepKg` | One dumbbell's weight, as read off the rack |
| Bodyweight | Up and down by 2.5 kg | The added load; 0 with none |

Plate keys are 20, 10, 5, 2.5, and 1.25 kg.

The load starts at the previous set of this commit; for the first set, at the first working set of this exercise's last commit; for an exercise never done, at its bar, its lowest step, or 0.

### Tests

The next set can be marked a test, a level deeper than the grade keys; the mark applies to that set only. A test asks for its reps beside its load, and is logged only once they are entered. The reps input shows the reps of the exercise's last test as a placeholder. An ordinary set has no reps. Auburn never marks a set a test.

### Correcting

A logged set opens to change its load, grade, or reps, to be marked or unmarked a test, or to be deleted. Marking it a test asks for its reps; unmarking it removes them. Sets keep the order they were logged in.

## States

None. A set exists once logged.

## Constraints

- Auburn never requires a rep count to log a set that is not a test.
- One load per set.

## Edge cases

| Scenario | Behavior |
|---|---|
| A grade is tapped twice in quick succession | Two sets are logged; the second is deleted like any other |
| The last set before an exercise's history is Warmup | It is not the starting load; the first working set is |
| A plate exercise's bar weight is changed | Past sets keep their stored load |
| A test's grade is tapped before its reps are entered | Nothing is logged; the reps input is shown as owed |
| A test is marked, then the next set is logged as ordinary | The mark is cleared; nothing asks for reps |
