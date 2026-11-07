# Routines

## What it is

A workout prepared in advance: exercises and goals, in order, picked when a workout starts so the gym is for doing it. A routine stands alone or belongs to a routine group, and may be tied to gyms. It offers what to do; it commits nothing and decides nothing.

## Behavior

### A routine

A routine has a name and holds exercises and goals in the order the user sets, and nothing more about them: no sets, reps, load, or way of doing an exercise. Any number of routines can exist. A routine is created and edited on a screen of its own, never while a workout starts.

### Goals in a routine

A goal in a routine stays a goal: it is shown as itself, never dissolved into or replaced by its exercises. A routine holds the goal, never a copy of its exercises. Its exercises are read when a workout starts and come with it at its place in the order, in whatever order the goal holds them. A goal has no order of its own; the routine applies what the goal brings.

Only active goals are added to a routine. A goal that ends, reached or abandoned, leaves every routine it was in.

A goal whose target sits on an activity kind brings only its supporting exercises; the activity that proves it arrives from the watch.

### Gyms

A routine is tied to gyms or to none, as an exercise is. A tied routine is offered only at its gyms, and holds only exercises available at one of them. A goal whose target sits on an exercise joins a tied routine only if that exercise is available at one of the routine's gyms; a goal whose target sits on an activity kind joins any routine.

A goal whose target's exercise stops being available at a tied routine's gyms stays in the routine, shown on its edit screen as not provable there.

### Routine groups

A routine stands alone or belongs to one routine group: a name and its routines. Grouped routines are shown together, apart from standalone ones. A group implies no order among its routines.

### Starting from a routine

When a workout starts at a gym, the routines tied to that gym or to none are offered, and the user picks one or none. A workout started from a routine offers the routine's exercises available at its gym; an exercise tied to another gym is replaced by its alternate available here, or left out. This holds for the exercises a goal brings, and the goal stays.

The routine commits nothing. Whether to commit any of its exercises is the user's choice; each is committed as it is done, so commit order records what happened, and an exercise skipped leaves nothing behind. The offered list shows which have been committed. Every other exercise on offer at the gym can still be committed at any time.

Auburn never suggests which routine is next, and never schedules one.

## States

| State | Kind | Meaning |
|---|---|---|
| Active, archived | Persisted | Whether the routine is offered |
| Committed, not yet | Runtime, derived | Whether an offered exercise has been committed in this workout |

## Constraints

- An exercise or a goal sits in a routine at most once.
- A routine holds no activity; cardio is never a workout.

## Edge cases

| Scenario | Behavior |
|---|---|
| An exercise sits in a routine both on its own and through a goal | It is offered once, at its first place in the order |
| An exercise in a routine is archived | It is no longer offered from the routine; it stays in the routine's edit screen, marked archived |
| A goal in a routine ends | It leaves the routine |
| A routine is edited while a workout started from it is in progress | The offered list follows the routine as it now stands |
| The phone dies during a workout started from a routine | The offered list is there when Auburn reopens; what was committed stays committed |
| A routine's group is deleted | Its routines stand alone |
| An untied routine is started at a gym where none of its exercises is available | It offers nothing; every exercise on offer at the gym can still be committed |
