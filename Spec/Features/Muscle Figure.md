# The muscle figure

## What it is

A classical figure, engraved, shown front and back, with one region for each muscle group. It shows which groups an exercise works and how rested every group is, and it is how an exercise's muscle groups are chosen.

## Behavior

### The figure

Two views, front and back, each drawn with a region for every muscle group visible from that side; groups seen from both sides have a region in each. A control turns the figure. Five zoom sections — Full, Shoulders, Torso, Hips, Legs — frame the small groups; the figure always opens on the front, at Full.

### Where it appears

| Place | The figure shows | Tapping a region |
|---|---|---|
| Rest at a glance | Each tracked group tinted by its band, as defined in [Rest](Rest.md) | Shows that group's rest, band, and settings |
| An exercise | The groups it works, lit; an AMAP exercise's groups light too | Names the group |
| Creating or editing an exercise | The groups ticked so far, lit | Ticks or unticks the group |

### Tint

Only tracked groups with a band are tinted. Untracked groups and groups not yet trained stay plain. Cardio has no region; it appears in rest at a glance as a line of its own.

## States

| State | Kind | Meaning |
|---|---|---|
| Front, back | Runtime | The view shown |
| Full, Shoulders, Torso, Hips, Legs | Runtime | The zoom section shown |

## Constraints

- One region per muscle group per view; the figure cannot show a group the list does not have.
- The look, colours, and art are [visual language](../../Lens/Language/Visual/Visual.md)'s.

## Edge cases

| Scenario | Behavior |
|---|---|
| A group is tapped where its region is too small to hit | Zoom to its section; the sections exist for this |
| An exercise works only back-view groups | The figure still opens on the front; turning it shows them |
| Every group is untracked, as before any exercise exists | The figure is drawn plain |
| A tick is removed from an exercise while editing | The region unlights; rest recomputes as [Muscle groups](Muscle%20Groups.md) specifies |
