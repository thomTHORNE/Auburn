# Rest

## What it is

How long each muscle group, and cardio, has gone without being trained, read in four steps against the user's own rhythm. Rest shows; the user decides.

## Behavior

### Counting

A muscle group's rest is the number of calendar days, in the phone's local time, from the last day it was a main mover to today. It was a main mover on a day a set was logged for an exercise that names it as a main mover, at any gym, except a set graded Warmup; ungraded imported sets count. A Light set counts: it still works the muscle. A set counts the moment it is logged, while the workout is still in progress.

Supporting work is never counted. Beside its rest, a muscle group shows the last day it worked as a supporting muscle.

Cardio's rest counts the same way, from the day the latest imported activity started, of any kind.

Rest is never stored. Deleting a set or an activity, or changing an exercise's muscle groups, recomputes it.

### The four steps

Rest reads as one of four steps: Shouldn't, Maybe, Should, Overdue. A muscle group's steps, or cardio's, come from its rhythm:

- **Its usual gap** is the middle of its last six gaps: the days between consecutive days it was a main mover, or for cardio, between activities. With an even number of gaps, it is halfway between the two in the middle.
- **Should** starts at the usual gap, rounded up. **Maybe** starts a day earlier. **Overdue** starts at half again the usual gap, rounded up. Below Maybe is Shouldn't.
- **Under three gaps,** the steps are fixed: Maybe from 3 days, Should from 4, Overdue from 5. The group shows that its steps are fixed.

Any muscle group's steps, or cardio's, can be set by hand. They hold until handed back to its rhythm. Auburn never sets them.

### Back after a long gap

When a group's latest gap is more than twice its usual gap before it, the group shows that it is back after that many days, until two more gaps have followed. Its steps are unchanged.

### Overdue

Overdue is the last step. It asks nothing.

### Where rest shows

Rest is shown per muscle group and never summed into a verdict. The rest screen lists every tracked group and cardio, with its days, its step, and its last supporting day. Groups are listed under each split they belong to, then the groups in no split, then cardio, in the order of the muscle group list; nothing is sorted by rest, and nothing is recommended. An exercise shows each of its main movers' rest. A routine shows no rest of its own; its exercises show theirs.

### Not yet trained

A tracked group with no day as a main mover yet shows as [not yet trained](../../Lens/Language/Lexicon.md#names). It has no step. A muscle group that is only ever supporting is not tracked: it shows its last supporting day and keeps no rest.

## States

| State | Kind | Meaning |
|---|---|---|
| Shouldn't, Maybe, Should, Overdue | Runtime, derived | The step the group's rest falls in |
| Fixed, rhythm, set by hand | Derived; set by hand is persisted | Where the group's steps come from |
| Back after a long gap | Runtime, derived | The latest gap was more than twice the usual one |
| Not yet trained | Runtime, derived | Tracked, with no day as a main mover |

## Constraints

- Rest is counted in whole days. Hours do not count: a set at 23:00 and a set at 07:00 the next day are a day apart.
- Steps set by hand rise in order: Maybe before Should before Overdue, from at least one day.

## Edge cases

| Scenario | Behavior |
|---|---|
| A workout runs past midnight | Each set counts on the day it was logged |
| Two exercises make a group a main mover on the same day | One day; no gap of 0 |
| The phone's time zone changes | Days are counted in the zone the phone is in now |
| A run has finished but not yet been imported | Cardio shows its rest from the last imported activity until the import runs |
| A workout of warmups only | Resets nothing |
| The only set of the day is deleted | Rest goes back to the day before it; the gaps recompute |
| An exercise's muscle groups change | Every past set is read under the new naming |
| Steps set by hand are handed back | The rhythm applies at once |
| A group has three to five gaps | The middle of those it has |
