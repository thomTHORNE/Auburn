# Goals

## What it is

Something to reach — a movement mastered, an imbalance levelled, a time run — with a target the facts prove, the exercise it sits on and the alternates that serve it, and what the user says about it at its start and its end. A weakness is a goal the user names. A goal is never owed: it shows the gap to its target, not rest.

## Behavior

### A goal

A goal starts from what its target sits on: an exercise, or an activity kind. It has a name, one target, and alternates. On an exercise, the alternates offered are those that share at least one main mover with it and are tied to every gym it is; they are the exercise's alternates while the goal is active, as specified in [Exercises](Exercises.md). On an activity kind, any exercise can be an alternate. An exercise is the target of at most one goal that is a draft or active. An exercise shows the goals it serves.

An active goal can sit in any number of routines, as specified in [Routines](Routines.md).

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

Only a test carries reps, so a reps target is reached only by a test.

A target on a unilateral exercise names a side: left, right, or both. Both is reached by a workout in which each side has a set that meets the rules.

A set and an imported activity are facts alike. The exercise or kind a target sits on proves it; the goal's alternates serve it and prove nothing.

### Draft, active, ended

A goal starts as a draft. Everything in a draft can change, and a draft can be deleted.

Making a goal active requires its target's parameter and value. Before it does, Auburn says that nothing in the goal but its alternates can change after. From that day the goal is locked: its name, its start answers and its target hold. Alternates can still be added and removed.

An active goal ends in one of two ways: reached or abandoned. It cannot be paused.

### The start and the end

A draft asks three questions, each optional: Why this goal? What does reaching it mean, in your words? What do you expect to be hardest? The answers can change while it is a draft, and lock when it is made active. They are written for the end of the goal, which shows them again.

At the end, the goal asks one question, with the start answers shown beside it. Reached: what got you there? It is asked when the mark is kept, and is optional. Abandoned: why? It is required, as below.

### Set limits

Each exercise a goal names, its target's exercise and each alternate, can carry a limit of sets per workout. A limit is optional. While the goal is active, a workout holds at most that many sets of the exercise, Warmups not counted: once it holds that many, the exercise's next set is refused, and deleting a set frees its place. On a unilateral exercise, the limit holds for each side. An exercise named by two active goals takes the lower limit. While the exercise is done, it shows its limit and the sets logged toward it.

The limit on the target's exercise is set in the draft and locks when the goal is made active. An alternate's limit is set when it is added, and can be changed or removed while the goal is active. Each change is kept on the goal with its date, and the goal shows them.

### Reaching a target

The target is reached by the first fact that meets its rules, dated after the goal was made active. Auburn marks it on that fact's date.

Auburn then asks how to proceed. It never asks during a workout: the prompt appears when Auburn is opened with no workout in progress, and it cannot be dismissed. Keep it, keep it and start a new goal from this one, or undo it. Keeping it also asks what got you there, beside the start answers. An undone mark passes over that fact and every fact before it; the target waits for the next.

A kept target ends the goal as reached on that day.

### Abandoning

An active goal can be abandoned at any time. Auburn asks why; the answer is free text, cannot be empty, and is kept on the goal. The goal ends as abandoned on that day.

### An ended goal

A reached or abandoned goal is frozen: a permanent record that never changes. Its progress is shown up to the day it ended. It keeps its exercises as history, and none can be added to it.

A new goal can be started from an ended one: a draft holding its name, its target unreached, and its alternates, linked to the goal it came from. Its questions start unanswered; the link shows the old goal's answers. The link shows on both.

### What a goal shows

Its start answers, and once it has ended, its end answer. Then one chart holding a line for the target's exercise and each alternate, and for the activity kind its target sits on. The target's exercise or kind is given only the facts the target's rules let through, whatever else the chart shows, so the line and the target's reach never disagree; the target is a line across it, and the gap is stated. The gap runs from the best point since the goal was made active to the target; until a point arrives, from the last point before it. Each alternate is given the sets of the grades shown on the goal, Ideal to begin with, a viewing choice kept on the goal. [Progress](Progress.md) draws every line. The parameter plotted is a viewing choice kept on the goal, starting from the target's own, and every line follows it; a line with no point in that parameter is left out. The target's line and gap show only on the target's own parameter. On a unilateral target exercise, the target sits on the side it names; on both, it runs across both sides' lines, and the gap is the farther side's.

Each line can be shown or hidden, a viewing choice kept on the goal; every line is shown to begin with. The line of the exercise or kind the target sits on is always shown, since the target and its gap sit on it. Viewing choices can change on an ended goal: they are not part of what it froze.

A reached goal also shows the days from active to reached. An abandoned goal shows the days it ran and why it was abandoned.

## States

| State | Kind | Meaning |
|---|---|---|
| Draft, active, reached, abandoned | Persisted | Where the goal is in its life |
| Prompt owed | Runtime, derived | A target is marked, and not yet kept or undone |

## Constraints

- A goal never affects rest, and is never overdue.
- Nothing in an active goal changes but its alternates.
- An exercise is the target of at most one goal that is a draft or active.
- A set beyond an active goal's limit on its exercise is never logged.
- An ended goal never changes.
- Auburn never sets or moves a target.

## Edge cases

| Scenario | Behavior |
|---|---|
| A draft's target has no value | Cannot be made active |
| A draft's target is moved to another exercise | Allowed; alternates that no longer share a main mover or a gym with it stay, marked, until removed |
| The exercise a draft's target sits on is archived | Allowed; the draft cannot be made active until its target sits on an exercise that is not archived |
| An alternate is archived | It stays in the goal, marked archived; its line keeps its history and no longer grows |
| An archived exercise is added to a goal | Not offered: an archived exercise is offered nowhere new |
| The target's exercise of an ended goal is archived | Allowed; the ended goal is unchanged |
| The fact that marked a target is edited or deleted before the prompt is answered | If it no longer meets the rules, the mark is withdrawn and the target waits |
| The fact behind a kept target is deleted later | The target stays reached |
| An exercise a target of an active goal sits on is archived | Refused until the goal ends |
| A goal is drafted on an exercise that is already a draft or active goal's target | Refused; once that goal ends, a new one can start on it |
| A target on both sides, with the left reached in one workout and the right in the next | Not reached; both sides meet it in one workout |
| A Warmup is logged with the limit reached | Logged; Warmups do not count |
| A Warmup is corrected to a working grade with the limit reached | Refused |
| An alternate's limit is lowered below the sets already logged in the workout in progress | Those sets stay; no more are logged |
| The exercise is committed in a swap for another | Its own limit applies, if a goal names it |
| A target on runs, and a treadmill session meets it | It does not count; only the target's own kind does |
| Sets imported from Notion, dated before a goal was made active | Never reach its targets |
| A bodyweight exercise's load target | The added load counts; 0 when none |
| A distance range lets no activity through | The chart is empty until one fits |
| The chosen parameter is not the target's | The line shows; the target's line and gap do not |
| The chosen parameter does not apply to the current target — reps against a run | The chart shows the target's own parameter |
