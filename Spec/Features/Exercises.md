# Exercises

## What it is

The user's own exercises: what each is, what it works, where it is done, what stands in for it, its notes, and its past sets.

## Behavior

### An exercise

A hypertrophy exercise has a name, a load kind and the equipment value it needs, the muscle groups it works, the AMAP flag, the goals it serves, its alternates, and its gym ties. A mobility exercise has a name, gym ties, and notes. The fields are the [Data Model](../Data%20Model.md#exercises)'s. Names need not be unique: the gym ties tell two versions of a lift apart.

### Gym ties

An exercise tied to gyms is offered only at those gyms; one tied to none is offered everywhere.

### Alternates

An exercise names its alternates in order. When its equipment is taken, a commit of it is swapped for an alternate, as specified in [Workouts](Workouts.md); only alternates available at the current gym are offered. The link runs one way: naming Hack Squat on Leg Press does not name Leg Press on Hack Squat.

### Notes

The notes are three texts — Observations, Settings, and Form — shown as tabs. They are on screen whenever the exercise is being done, and editable there.

### Past sets

An exercise's past sets are grouped by workout, newest first, each group showing the workout's date and gym and the exercise's place in it.

### Archiving

An archived exercise is offered nowhere new and stays in every workout it appears in.

## States

| State | Kind | Meaning |
|---|---|---|
| Active, archived | Persisted | Whether the exercise is offered |

## Constraints

- A hypertrophy exercise works at least one muscle group.
- The load kind cannot change once the exercise has sets.

## Edge cases

| Scenario | Behavior |
|---|---|
| An alternate is archived | It is no longer offered as an alternate |
| An exercise's gym tie is removed while it has sets at that gym | Its history is kept; it is no longer offered there |
| A stack exercise's step changes | Past loads are kept; the input steps by the new value |
| A plate total below the bar | Not possible: the bar is the floor |
