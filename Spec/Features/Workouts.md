# Workouts

## What it is

One visit to train at a gym: starting it, committing exercises to it in order, ending it, and the record of past workouts. A workout is hypertrophy or mobility.

## Behavior

### Starting

A workout starts by choosing the gym, then the kind: hypertrophy, unless mobility is chosen. Its start time is the moment it is started. A hypertrophy workout starts with the roll on; the roll is specified in [Modality roll](Modality%20Roll.md). One workout is in progress at a time.

### Committing

The exercises offered are those of the workout's kind that are tied to its gym or to no gym, and are not archived. Committing one adds it after the last. An exercise is committed to a workout at most once; returning to it later adds sets to the same commit.

A commit with no sets can be swapped for one of its exercise's alternates available at this gym, or removed. A commit with sets is removed together with its sets.

In a mobility workout, a commit takes an optional grade — controlled, improved, or poor — and nothing else.

### Ending

The user ends the workout; its end time is that moment, and its duration is end minus start. A workout ended with no commits is deleted. A workout still open on a later day ends at its last set's time the next time Auburn is opened, or at its start if it has none.

### Past workouts

Past workouts are listed newest first, titled by date and gym. One opens to its commits in order, each with its sets. Sets, grades, and commits can be corrected or deleted afterwards; the gym and kind cannot be changed once there are commits. Imported workouts are listed alongside and corrected the same way.

## States

| State | Kind | Meaning |
|---|---|---|
| In progress | Persisted | `endedAt` is empty |
| Ended | Persisted | `endedAt` is set |

## Constraints

- One workout in progress at a time.
- A workout is hypertrophy or mobility, never both. Cardio is never a workout; it arrives as activities.

## Edge cases

| Scenario | Behavior |
|---|---|
| A workout is started while another is in progress | The open one must be ended first |
| The phone dies mid-workout | The workout is still in progress when Auburn reopens; nothing logged is lost |
| The same exercise is committed again later in the workout | It returns to its existing commit |
| A workout is ended immediately after starting | Deleted, since it has no commits |
| A mobility exercise's grade is left blank | The commit stands ungraded |
