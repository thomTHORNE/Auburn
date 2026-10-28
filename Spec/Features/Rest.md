# Rest

## What it is

How long each tracked muscle group, and cardio, has gone untrained, which band that puts it in, and every rest at a glance. Rest owns the overdue limit; the overdue log reads it.

## Behavior

### Counting

A muscle group's rest is the number of calendar days, in the phone's local time, from the day of its latest resetting set to today. A set trained today gives 0. A resetting set is any set of a non-AMAP exercise that names the group, at any gym, except a set graded Warmup; ungraded imported sets reset. A Light set resets: it still works the muscle. Only a Warmup is preparation. A set counts the moment it is logged, while the workout is still in progress.

Cardio's rest counts the same way from the day the latest imported activity started, of any kind.

Rest is never stored. Deleting a set or an activity, or changing an exercise's muscle groups, recomputes it.

### Bands

Each tracked group, and cardio, has its own settings (the Data Model's [`RestSettings`](../Data%20Model.md#muscle-groups)), defaulting to:

| Band | Days | Meaning |
|---|---|---|
| Repair | 0–2 | Still recovering |
| Maybe | 3 | Trainable if the body agrees |
| Train | 4 | Ready |
| Overdue | 5 and more | Ready and late |

A band starts at its `…From` value: Maybe at `maybeFrom`, Train at `trainFrom`, Overdue at `overdueFrom`. Settings are edited per group, and the three values must rise in that order.

### The overdue limit

A group is overdue from `overdueFrom` days. That is the limit the overdue log reads; it is defined here and nowhere else.

### Rest at a glance

One screen shows every tracked group and cardio, each with its days and its band's colour, and the muscle figure tinted the same way. Groups are listed under each split they belong to, then the groups in no split, then cardio; within a list, in the order of the muscle group list. Nothing is sorted by rest, and nothing is recommended.

### Never trained

A tracked group with no resetting set yet shows "not yet trained". It has no band and is not overdue.

## States

| State | Kind | Meaning |
|---|---|---|
| Repair, Maybe, Train, Overdue | Runtime, derived | The band the group's rest falls in |
| Not yet trained | Runtime, derived | Tracked, with no resetting set |

## Constraints

- Rest is counted in whole days. Hours do not count: a set at 23:00 and a set at 07:00 the next day are a day apart.
- `0 < maybeFrom < trainFrom < overdueFrom`.

## Edge cases

| Scenario | Behavior |
|---|---|
| A workout runs past midnight | Each set counts on the day it was logged |
| The phone's time zone changes | Days are counted in the zone the phone is in now |
| A run has finished but not yet been imported | Cardio shows its rest from the last imported activity until the import runs |
| A workout of warmups only | Resets nothing |
| `overdueFrom` is lowered below the current rest | The group is overdue at once |
| The only set of the day is deleted | Rest goes back to the previous resetting set |
