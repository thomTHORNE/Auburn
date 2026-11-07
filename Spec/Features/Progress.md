# Progress

## What it is

How an exercise, and a kind of cardio, has moved over time: a line drawn from the sets or activities it is given, for the parameter chosen. Progress only draws; the place the line is shown decides what it is given.

## Behavior

### Drawing an exercise's line

Each workout is one point on its date, drawn from the sets the line is given:

| Parameter | The point |
|---|---|
| Load | The heaviest set |
| Reps | The most reps on a test |

A workout with no set given adds no point. Ungraded imported sets are never given.

### What an exercise's line is given

On the exercise, above its past sets, the line is given the sets of the grades the user shows: Ideal to begin with. The grades shown and the parameter, load to begin with, are viewing choices kept on the exercise.

In a goal's chart, the line is given what the goal decides, as specified in [Goals](Goals.md).

### Cardio progress

For each activity of a kind the line is given, one point on the activity's date, for the parameter chosen: pace (minutes per kilometre), duration, distance, or average heart rate. The line is shown in the chart of each goal whose target sits on that kind, which decides the activities it is given, as specified in [Goals](Goals.md), with each of those activities' distance, duration, pace, and average heart rate listed beneath, newest first.

## States

None. Progress is drawn from sets and activities; only each exercise's viewing choices are stored.

## Constraints

- Progress is per exercise. Two gyms' versions of a lift are two exercises and two lines.

## Edge cases

| Scenario | Behavior |
|---|---|
| An exercise with one point ever | One point, no line |
| Two sets given tie as heaviest in a workout | One point at that load |
| A set's grade is corrected to one not shown | Its point moves to the next set given, or disappears |
| A test graded Yielding, with Ideal shown | Adds no point; the test stays in the exercise's past sets |
| No grade is shown | The line is empty |
| A bodyweight exercise, by load | Its added load is plotted; 0 when none |
| Reps are chosen for an exercise rarely tested | Few points; the line covers only workouts with a test |
| Average heart rate is chosen and an activity has none | That activity adds no point |
