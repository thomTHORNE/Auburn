# Muscle groups

## What it is

The fixed list of muscle groups Auburn keeps rest for, how an exercise names the groups it works, and the splits that group them. A muscle group is tracked once an exercise resets it; from then on it is owed.

## Behavior

### The list

The twenty groups of the [Data Model](../Data%20Model.md#muscle-groups), shown by name: Chest, Front delts, Side delts, Rear delts, Biceps, Triceps, Forearms, Lats, Upper back, Traps, Lower back, Abs, Obliques, Quads, Hamstrings, Glutes, Calves, Adductors, Abductors, Neck. The list cannot be edited.

### What an exercise works

A hypertrophy exercise names the muscle groups it works, at least one. There is no primary or secondary: a named group is worked in full. The groups are ticked when the exercise is created and can be changed at any time; a change applies to past sets too, since rest is computed from the records.

### AMAP

An AMAP exercise still names the groups it works, and the muscle figure still lights them, but it resets none of their rest.

### Tracked groups

A muscle group is tracked while at least one exercise that is neither archived nor AMAP names it. Only tracked groups appear in rest at a glance and can fall overdue. An untracked group keeps its history and returns, with its rest intact, the moment an exercise resets it again. Every tracked group is owed: no setting stops it from falling overdue.

### Splits

A split is a name and a set of muscle groups, created by the user. A group may sit in several splits or none. Splits group rest at a glance; they change nothing about rest itself.

## States

| State | Kind | Meaning |
|---|---|---|
| Tracked | Runtime, derived | At least one non-archived, non-AMAP exercise names the group |
| Untracked | Runtime, derived | None does; the group is hidden from rest at a glance |

## Constraints

- The list is fixed in v0. No custom groups, and no group can be hidden by hand.
- Mobility exercises name no muscle groups.

## Edge cases

| Scenario | Behavior |
|---|---|
| The only exercise resetting Neck is made AMAP | Neck becomes untracked and leaves rest at a glance; its sets stay in history |
| Neck's exercise is archived, then a new neck exercise is created | Neck is tracked again; its rest counts from its last set, archived exercise included |
| An exercise's ticks change from Chest to Chest and Triceps | Triceps' rest now counts that exercise's past sets as well |
| A split's last group is removed | The split stays, empty, until it is archived |
| A group sits in two splits | It appears under both in rest at a glance |
