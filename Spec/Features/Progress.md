# Progress

## What it is

How an exercise, and a kind of cardio, has moved over time, plotted for the parameter the user chooses.

## Behavior

### An exercise's progress

Each workout the exercise was done in is one point on the workout's date, for the parameter chosen:

| Parameter | The point |
|---|---|
| Load | The heaviest set graded Ideal |
| Reps | The most reps on any set that has them |

Load is shown first; the choice is kept per exercise. A workout with no set for the chosen parameter adds no point; ungraded imported sets add none to load.

The progress is shown on the exercise, above its past sets, and under each goal it serves, as specified in [Goals](Goals.md).

### Cardio progress

For each activity of a kind, one point on the activity's date, for the parameter chosen: pace (minutes per kilometre), duration, distance, or average heart rate. The line is shown under each goal whose target sits on that kind, as specified in [Goals](Goals.md), with each counted activity's distance, duration, pace, and average heart rate listed beneath, newest first.

## States

None. Progress is computed from sets and activities; only each exercise's chosen parameter is stored here.

## Constraints

- Progress is per exercise. Two gyms' versions of a lift are two exercises and two lines.

## Edge cases

| Scenario | Behavior |
|---|---|
| An exercise with one point ever | One point, no line |
| Two sets tie as heaviest Ideal in a workout | One point at that load |
| An Ideal set's grade is corrected to Acceptable | Its point moves to the next heaviest Ideal set, or disappears |
| A bodyweight exercise, by load | Its added load is plotted; 0 when none |
| Reps are chosen for an exercise rarely rolled counted | Few points; the line covers only workouts with reps |
| Average heart rate is chosen and an activity has none | That activity adds no point |
