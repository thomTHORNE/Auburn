# Exercises

## What it is

The user's own exercises: what each is, what it works, where it is done, what stands in for it, its notes, and its past sets.

## Behavior

### An exercise

An exercise has a name, a load kind and the equipment value it needs, whether it is unilateral, the muscle groups it mainly trains and those it supports, its property values, the goals it serves, its alternates, and the gyms it is tied to. The fields are the [Data Model](../Data%20Model.md#exercises)'s. Names need not be unique: the gym ties tell two versions of a lift apart.

A way of doing an exercise that is to be tracked apart, such as slow and controlled, is an exercise of its own; otherwise it belongs in the exercise's notes.

### Gym ties

An exercise is tied to at least one gym, and is offered only at its gyms. One done at two gyms is tied to both. Wherever an exercise is offered, its gyms are shown with it.

### Properties

A property is a name and its values, made by the user, such as Form: Strict or Freeform. An exercise holds at most one value of each property. A property or a value is made by typing it on an exercise; every exercise can then pick it. Property values show beside an exercise's name, and every list of exercises can be filtered by them. Auburn reads nothing else from them.

A property or a value can be renamed or deleted. Deleting one removes it from every exercise.

### Unilateral

A unilateral exercise is done one side at a time: each of its sets records left or right, as specified in [Sets](Sets.md). An exercise can be marked unilateral while it already has sets; those keep no side. It cannot be unmarked once a set has a side.

### Alternates

An exercise's alternates are offered in its place: a commit of it is swapped for one when its equipment is taken, as specified in [Workouts](Workouts.md), and a goal offers its alternates on demand, as specified in [Goals](Goals.md). While the exercise is an active goal's target, its alternates are the goal's. Otherwise it names its own, in order; they stay named while a goal holds it, and return when the goal ends.

An alternate shares at least one main mover with the exercise and is tied to every gym the exercise is; only those are offered when one is named. The link runs one way: naming Hack Squat on Leg Press does not name Leg Press on Hack Squat.

### Notes

The notes are three texts — Observations, Settings, and Form — shown as tabs. They are on screen whenever the exercise is being done, and editable there.

### Past sets

An exercise's past sets are grouped by workout, newest first, each group showing the workout's date and gym and the exercise's place in it.

### Archiving

An archived exercise is offered nowhere new and stays in every workout it appears in. It can be restored, and is then offered again with its history whole.

An exercise with no sets can be deleted outright instead. It leaves every routine, every list of alternates and every goal that names it. Deleting is refused while a goal's target sits on it, or while an ended goal names it.

## States

| State | Kind | Meaning |
|---|---|---|
| Active, archived | Persisted | Whether the exercise is offered |

## Constraints

- The load kind cannot change once the exercise has sets.
- An exercise is tied to at least one gym.
- An exercise cannot be unmarked unilateral once a set has a side.

## Edge cases

| Scenario | Behavior |
|---|---|
| An alternate is archived | It is no longer offered as an alternate |
| An exercise's gym tie is removed while it has sets at that gym | Its history is kept; it is no longer offered there |
| A stack exercise's step changes | Past loads are kept; the input steps by the new value |
| A plate total below the bar | Not possible: the bar is the floor |
| An exercise a target of an active goal sits on is archived | Refused, as specified in [Goals](Goals.md) |
| An exercise's last gym tie is removed | Refused |
| An alternate stops sharing a main mover or a gym after an edit | It stays named, marked, and is not offered |
| An exercise with sets is marked unilateral | Allowed; its past sets keep no side |
| An exercise an active goal's target sits on is marked or unmarked unilateral | Refused until the goal ends |
| A property value is deleted | Every exercise that held it holds no value of that property |
