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

The progress is shown on the exercise, above its past sets, and under each goal it serves.

### Cardio progress

For each activity of a kind, one point on the activity's date, for the parameter chosen: pace (minutes per kilometre), duration, distance, or average heart rate. Pace is shown first; the choice is kept per goal. A goal may also set a distance range, and then only activities within it count. The line is shown under each cardio goal naming that kind, with each counted activity's distance, duration, pace, and average heart rate listed beneath, newest first.

## States

None. Progress is computed from sets and activities; only each exercise's and goal's chosen parameter and a goal's distance range are stored.

## Constraints

- Progress is per exercise. Two gyms' versions of a lift are two exercises and two lines.
- A distance range's lower bound does not exceed its upper bound.

## Edge cases

| Scenario | Behavior |
|---|---|
| An exercise with one point ever | One point, no line |
| Two sets tie as heaviest Ideal in a workout | One point at that load |
| An Ideal set's grade is corrected to Acceptable | Its point moves to the next heaviest Ideal set, or disappears |
| A bodyweight exercise, by load | Its added load is plotted; 0 when none |
| Reps are chosen for an exercise rarely rolled counted | Few points; the line covers only workouts with reps |
| Average heart rate is chosen and an activity has none | That activity adds no point |
| A distance range lets no activity through | The goal shows no cardio progress until one fits |
| A goal's chosen parameter was distance, and the app is reopened | The goal still shows distance |
