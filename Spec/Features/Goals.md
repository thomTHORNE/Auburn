# Goals

## What it is

Something to reach — a movement mastered, an imbalance levelled, a time run — with the user's own explanation of what it is for and how it is meant to be achieved, and the exercises that work toward it. A weakness is a goal the user names. A goal is never owed: it shows progress, not rest.

## Behavior

### A goal

A goal has a name and an explanation, both the user's. Its exercises are the exercises that name it; they are added and removed from the exercise or from the goal. A goal may have none yet.

### A cardio goal

A goal may name an activity kind — run, treadmill, or hike. Its activities are every imported activity of that kind, narrowed by the goal's distance range when it has one.

### What a goal shows

Its explanation, then each of its exercises with that exercise's progress, and for a cardio goal its activities' progress, all as specified in [Progress](Progress.md). Nothing more: a goal has no target value, no deadline, and no reached state.

### Archiving

An archived goal is offered nowhere new; its exercises keep their history and stop naming it.

## States

| State | Kind | Meaning |
|---|---|---|
| Active, archived | Persisted | Whether the goal is listed |

## Constraints

- A goal never affects rest, and is never overdue.

## Edge cases

| Scenario | Behavior |
|---|---|
| A goal with no exercises and no activity kind | Shows its explanation only |
| An exercise serving a goal is archived | It stays listed under the goal with its progress, marked archived |
| Two goals name the same activity kind | Each shows the activities its own distance range lets through |
