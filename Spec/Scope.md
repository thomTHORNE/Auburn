# Scope

What each version of Auburn includes and excludes, and why.

[Foundation](../Foundation.md) and the [design principles](Design%20Principles.md) stay fixed across versions; scope is what changes. Something not yet decided either way is not listed here — it is in [Ideas.md](../Ideas.md) or `Research/`.

A version includes a feature as a commitment to what the product is. How the feature behaves is specified in `Features/` once it is understood, not before.

A version may withhold a pillar of Foundation, but never break one of its refusals. What ships must stay true to Foundation even where it does not yet deliver all of it.

---

## v1

### Included

| | |
|---|---|
| **Platforms** | Android phones. |
| **Muscle groups** | The standard list, the exercises that work each group, and the AMAP rule. Every muscle group is owed. A muscle group may carry a split. |
| **Rest** | Each muscle group's rest, rest bands, and overdue limit, set per group; cardio rests the same way. Every rest at a glance, as the basis for choosing the day's training. |
| **The muscle figure** | A classical figure, engraved in the style of a terminal boot screen, shown front and back, with one region per muscle group. It lights the groups an exercise works, and tints every group by its rest band. |
| **Goals** | Goals with the user's explanation, a target the facts prove — reached in steps when the user sets them — and the exercises that work toward it, shown with the gap to the target. A goal is drafted, made active, and ends reached or abandoned. Weaknesses are goals. |
| **The overdue log** | The prompt when a muscle group or cardio falls overdue, and the log of answers. |
| **Workouts** | Starting a workout by choosing the gym, which limits the exercises on offer to that gym's; committing exercises to it in order; its duration; and past workouts. |
| **Sets** | Load and grade, plus reps when the modality counts them. |
| **Modality** | The modality roll, on when a workout starts and switched off or on during it. With it off, every exercise is done by feel. |
| **Exercises** | The user's own exercises, each with the muscle groups it works and its alternates, optionally tied to gyms, with its notes and its past sets, grouped by workout and showing the gym and the exercise's place in that workout. |
| **Progress** | Each exercise's ideal load over time. |
| **Mobility** | Mobility workouts, with a grading system of their own. |
| **Cardio** | Runs, treadmill sessions, and hikes recorded on the Suunto watch, read from intervals.icu, which syncs them from the Suunto app. |
| **Notion history** | A one-time import of Training '26: exercises and their notes, workouts, and sets. Its goals are rebuilt by hand as muscle groups and goals. |
| **Sound** | The boot, the ambience, and the power-down. |
| **Settings** | The theme: dark, light, or following the device. Sound, on or off, and its volume. The home layout: the widgets' order and widths. The credit a sound's licence requires. |

### Excluded

| Excluded | |
|---|---|
| iOS, watch, desktop, and web | v1 is built for the phone training happens with. The stack keeps iOS within reach. |
| Manual cardio entry | Cardio comes from the watch, or not at all. |
| A built-in exercise library | Exercises are the user's own. A catalog needs sourcing and upkeep, and nothing in current training uses one. |
| A rest timer | Nothing in current training depends on one. |
| A body-weight log | Nothing in v1 reads it. |

Excluding these is what makes the rest of v1 small enough to finish. Anything here worth reconsidering later lives in [Ideas.md](../Ideas.md), not in this table.
