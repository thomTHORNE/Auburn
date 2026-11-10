# Muscle groups

## What it is

The fixed list of muscle groups Auburn keeps rest for, how an exercise names the groups it mainly trains and those it supports, and the splits that group them.

## Behavior

### The list

The twenty groups of the [Data Model](../Data%20Model.md#muscle-groups), shown by name: Chest, Front delts, Side delts, Rear delts, Biceps, Triceps, Forearms, Lats, Upper back, Traps, Lower back, Abs, Obliques, Quads, Hamstrings, Glutes, Calves, Adductors, Abductors, Neck. The list cannot be edited.

### What an exercise names

An exercise names its muscle groups in one list: each group is a main mover, supporting, or neither. A tap moves a group on: neither, main, supporting, neither again. A main mover's rest is reset by the exercise; a supporting group is shown, never counted, as [Rest](Rest.md) specifies. An exercise with no main mover resets nothing. The groups can be changed at any time; a change applies to past sets too, since rest is computed from the records.

### Tracked groups

A muscle group is tracked while at least one exercise that is not archived names it as a main mover. Only tracked groups have rest. An untracked group keeps its history and returns, with its rest intact, the moment an exercise names it as a main mover again.

### Splits

A split is a name and a set of muscle groups, created by the user. A group may sit in several splits or none. Splits group the rest screen; they change nothing about rest itself.

## States

| State | Kind | Meaning |
|---|---|---|
| Tracked | Runtime, derived | A non-archived exercise names the group as a main mover |
| Untracked | Runtime, derived | None does; the group shows only its last supporting day, if any |

## Constraints

- The list is fixed. No custom groups, and no group can be hidden by hand.
- A group is never both a main mover and supporting on the same exercise.

## Edge cases

| Scenario | Behavior |
|---|---|
| The only exercise naming Neck as a main mover makes it supporting | Neck becomes untracked; its history stays |
| Neck's exercise is archived, then a new neck exercise is created | Neck is tracked again; its rest counts from its last main move, archived exercise included |
| An exercise's Triceps moves from supporting to main | Triceps' rest now counts that exercise's past sets as well |
| An exercise names no group at all | Allowed; it resets nothing and shows nothing on rest |
| A split's last group is removed | The split stays, empty, until it is archived |
| A group sits in two splits | It appears under both on the rest screen |
