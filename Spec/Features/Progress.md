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

A unilateral exercise draws a line per side, each from that side's sets. Sets with no side are given to neither.

### What an exercise's line is given

On the exercise, above its past sets, the line is given the sets of the grades the user shows: Ideal to begin with. The grades shown and the parameter, load to begin with, are viewing choices kept on the exercise.

In a goal's chart, the line is given what the goal decides, as specified in [Goals](Goals.md).

### Cardio progress

For each activity of a kind the line is given, one point on the activity's date, for the parameter chosen: pace (minutes per kilometre), duration, distance, or average heart rate. The line is shown in the chart of each goal whose target sits on that kind, which decides the activities it is given, as specified in [Goals](Goals.md), with each of those activities' distance, duration, pace, and average heart rate listed beneath, newest first.

### Reading a point

A point is selected by touching the chart: the point nearest the touch, on its line. Dragging moves the selection from point to point along that line. One point is selected at a time, and the selection ends when the chart is left.

A selected exercise point shows its date and gym, its line, its value, and the set behind it: its grade, its reps on a test, and its side on a unilateral exercise. It also shows how many of that workout's sets the line was given. On the line a goal's target sits on, it shows how far the point is from the target. The readout opens the workout the point came from.

A selected activity point shows its date, distance, duration, pace, and average heart rate.

## States

| State | Kind | Meaning |
|---|---|---|
| A point selected | Runtime | A point's readout is shown; it ends when the chart is left |

Progress is drawn from sets and activities; only each exercise's viewing choices are stored.

## Constraints

- Progress is per exercise. Two gyms' versions of a lift are two exercises and two lines.

## Edge cases

| Scenario | Behavior |
|---|---|
| An exercise with one point ever | One point, no line |
| Two sets tie as a workout's heaviest | The readout shows the first logged |
| Two lines' points fall where the touch lands | The nearer one is selected |
| The set behind a selected point is corrected or deleted | The selection follows the point, or ends if the point is gone |
| A line with one point | It can be selected like any other |
| A unilateral exercise whose sets all predate its marking | Both lines are empty; the sets stay in its past sets |
| Two sets given tie as heaviest in a workout | One point at that load |
| A set's grade is corrected to one not shown | Its point moves to the next set given, or disappears |
| A test graded Yielding, with Ideal shown | Adds no point; the test stays in the exercise's past sets |
| No grade is shown | The line is empty |
| A bodyweight exercise, by load | Its added load is plotted; 0 when none |
| Reps are chosen for an exercise rarely tested | Few points; the line covers only workouts with a test |
| Average heart rate is chosen and an activity has none | That activity adds no point |
