# The overdue log

## What it is

When a muscle group or cardio falls overdue, Auburn asks why it was not trained, and keeps the answer in a log of its own, so slack is seen rather than forgotten. An answer is tied to nothing: it is the reason training did not happen.

## Behavior

### When it asks

A group falls overdue on the day its rest reaches its overdue limit, as defined in [Rest](Rest.md). Auburn asks when any tracked group or cardio has fallen overdue since the last answer was given. One answer covers every group that fell overdue in that time; a group that stays overdue is not asked about again until it has been trained and falls overdue once more.

### The prompt

The prompt appears when Auburn is opened with no workout in progress. It names the groups that fell overdue and asks why. It cannot be dismissed, and no workout can be started until it is answered; rest at a glance and past workouts stay readable behind it.

The answer is free text and cannot be empty.

### The log

The log lists every answer, newest first, with its date and the groups that were overdue then, worked out from the records. An answer can be corrected, never deleted.

## States

| State | Kind | Meaning |
|---|---|---|
| Owed | Runtime, derived | A group has fallen overdue since the last answer |
| Answered | Runtime, derived | Nothing has fallen overdue since the last answer |

## Constraints

- Every prompt is answered. There is no skip, snooze, or setting that turns the log off.
- An answer is never deleted, and never tied to a muscle group, exercise, or workout.

## Edge cases

| Scenario | Behavior |
|---|---|
| Five groups fall overdue on the same day | One prompt, naming all five |
| A sick week: chest falls overdue Monday, legs Wednesday | Asked on Monday's first opening; asked again from Wednesday, for legs |
| Auburn is not opened for a week | One prompt on the next opening, covering everything that fell overdue meanwhile |
| A workout is in progress when a group falls overdue | No prompt until the workout has ended and Auburn is next opened |
| A group's overdue limit is lowered so it is overdue today | It counts as falling overdue today |
| A group not yet trained | Never overdue, never asked about |
