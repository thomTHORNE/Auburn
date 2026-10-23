# Sets

## What it is

Logging a set — its load and its grade, plus reps when the modality counts them — and correcting it afterwards. Logging the next set is always the foremost action of a workout in progress.

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

### Reps

Reps are asked for only when the commit's modality is counted. The input shows the exercise's last known rep count as a placeholder. Reps are optional: a set graded without entering reps is logged without them.

### Correcting

A logged set opens to change its load, grade, or reps, or to be deleted. Sets keep the order they were logged in.

## States

None. A set exists once logged.

## Constraints

- Auburn never requires a rep count to log a set.
- One load per set.

## Edge cases

| Scenario | Behavior |
|---|---|
| A grade is tapped twice in quick succession | Two sets are logged; the second is deleted like any other |
| The last set before an exercise's history is Warmup | It is not the starting load; the first working set is |
| A plate exercise's bar weight is changed | Past sets keep their stored load |
| A counted set's reps are entered after grading | The set is opened and corrected |
