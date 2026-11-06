# Goals

## What it is

Something to reach — a movement mastered, an imbalance levelled, a time run — with the user's own explanation of what it is for and how it is meant to be achieved, a target the facts prove, and the exercises that work toward it. A weakness is a goal the user names. A goal is never owed: it shows the gap to its target, not rest.

## Behavior

### A goal

A goal has a name and an explanation, both the user's, and one target. Its exercises are the exercises that name it; they are added and removed from the exercise or from the goal.

### Targets

A target says what reaching the goal looks like, in rules the user writes. It sits on one source of facts — one of the goal's exercises, or an activity kind — and names a parameter and a value:

| Sits on | Parameter | Reached by a fact at |
|---|---|---|
| An exercise | Load | the value or more |
| | Reps | the value or more |
| An activity kind | Distance | the value or more |
| | Pace | the value or less |
| | Duration | the value or less |
| | Average heart rate | the value or less |

Its conditions say which facts count. A target on an exercise names the grades that count, at least one; a reps target may also name the least load that counts. A target on an activity kind may set a distance range. Auburn writes none of these rules.

A set and an imported activity are facts alike. The exercise or kind a target sits on proves it; the goal's other exercises support it and prove nothing.

### Draft, active, ended

A goal starts as a draft. Everything in a draft can change, and a draft can be deleted.

Making a goal active requires its target. Before it does, Auburn says that nothing in the goal but its supporting exercises can change after. From that day the goal is locked: its name, explanation and target hold, and the exercise its target sits on stays in it. Supporting exercises can still be added and removed.

An active goal ends in one of two ways: reached or abandoned. It cannot be paused.

### Reaching a target

The target is reached by the first fact that meets its rules, dated after the goal was made active. Auburn marks it on that fact's date.

Auburn then asks how to proceed. It never asks during a workout: the prompt appears when Auburn is opened with no workout in progress, after the overdue prompt when both are owed, and it cannot be dismissed. Keep it, keep it and start a new goal from this one, or undo it. An undone mark passes over that fact and every fact before it; the target waits for the next.

A kept target ends the goal as reached on that day.

### Abandoning

An active goal can be abandoned at any time. Auburn asks why; the answer is free text, cannot be empty, and is kept on the goal. The goal ends as abandoned on that day.

### An ended goal

A reached or abandoned goal is frozen: a permanent record that never changes. Its progress is shown up to the day it ended. Its exercises keep naming it as history, and no exercise can newly name it.

A new goal can be started from an ended one: a draft holding its name, explanation, exercises and targets, unreached, and linked to the goal it came from. The link shows on both.

### What a goal shows

Its explanation. Then one chart holding a line for every exercise in the goal, and for the activity kind its target sits on. The target's exercise or kind is drawn only from the facts the target's rules let through, with the target as a line across it and the gap stated. The gap runs from the best point since the goal was made active to the target; until a point arrives, from the last point before it. Each supporting exercise is drawn as [Progress](Progress.md) draws it. The parameter plotted is a viewing choice kept on the goal, starting from the target's own, and every line follows it; a line with no point in that parameter is left out. The target's line and gap show only on the target's own parameter.

A reached goal also shows the days from active to reached. An abandoned goal shows the days it ran and why it was abandoned.

## States

| State | Kind | Meaning |
|---|---|---|
| Draft, active, reached, abandoned | Persisted | Where the goal is in its life |
| Prompt owed | Runtime, derived | A target is marked, and not yet kept or undone |

## Constraints

- A goal never affects rest, and is never overdue.
- Nothing in an active goal changes but its supporting exercises.
- An ended goal never changes.
- Auburn never sets or moves a target.

## Edge cases

| Scenario | Behavior |
|---|---|
| A draft with no target | Cannot be made active |
| The fact that marked a target is edited or deleted before the prompt is answered | If it no longer meets the rules, the mark is withdrawn and the target waits |
| The fact behind a kept target is deleted later | The target stays reached |
| An exercise a target of an active goal sits on is archived | Refused until the goal ends |
| Two goals' targets sit on the same exercise | Each is watched on its own; one set can reach both |
| A target on runs, and a treadmill session meets it | It does not count; only the target's own kind does |
| Sets imported from Notion, dated before a goal was made active | Never reach its targets |
| A bodyweight exercise's load target | The added load counts; 0 when none |
| A distance range lets no activity through | The chart is empty until one fits |
| The chosen parameter is not the target's | The line shows; the target's line and gap do not |
| The chosen parameter does not apply to the current target — reps against a run | The chart shows the target's own parameter |
