# Tasks

Auburn spec writing tracker. Structure: Alignment → Goal → Item.

## Status

- `[ ]` **Unresolved** — default state. No spec work drafted yet.
- `[x]` **Pending review** — spec work drafted and committed, awaiting user review.

Resolved tasks are removed from TASKS.md.

## Severity

- `BLOCKER` — missing spec that would produce broken or undefined behavior at implementation time.
- `GAP` — incomplete or inconsistent spec that would cause a developer to make a wrong assumption.
- `MINOR` — should be addressed but low risk if deferred; implementation can proceed without it.



## Alignment 1 — Spec top level

### `#4` Data Model · [Spec/Data Model.md](Spec/Data%20Model.md)

- [ ] **`#4.1` No records are specified**
    `BLOCKER`

### `#6` Visual Design · [Spec/Visual Design.md](Spec/Visual%20Design.md)

- [ ] **`#6.1` No visual values are specified**
    `MINOR`

## Alignment 2 — Features

### `#7` Features · [Spec/Features/](Spec/Features/)

- [ ] **`#7.1` Goals are not specified**
    `BLOCKER` · `Deps: #4.1`

    A goal's explanation, the exercises that work toward it, and its progress. Weaknesses are goals.

- [ ] **`#7.12` Muscle groups are not specified**
    `BLOCKER` · `Deps: #4.1`

    The standard list, the muscle groups an exercise works, the AMAP rule, and splits.

- [ ] **`#7.2` Rest is not specified**
    `BLOCKER` · `Deps: #4.1`

    Each muscle group's rest, its bands, its overdue limit, cardio's rest, and every rest at a glance. Owns the limit the overdue log reads.

- [ ] **`#7.3` The overdue log is not specified**
    `BLOCKER` · `Deps: #4.1`

    The prompt when a goal falls overdue, and the log of answers. References the limit Rest owns. Waits on Research/Method for when the prompt appears and whether it must be answered first.

- [ ] **`#7.4` Workouts are not specified**
    `BLOCKER` · `Deps: #4.1`

    Choosing the gym, committing exercises in order, duration, and past workouts.

- [ ] **`#7.5` Sets are not specified**
    `BLOCKER` · `Deps: #4.1`

    Load, grade, and reps when counted.

- [ ] **`#7.6` The modality roll is not specified**
    `BLOCKER` · `Deps: #4.1`

    The roll, on when a workout starts and switched off or on during it.

- [ ] **`#7.7` Exercises are not specified**
    `BLOCKER` · `Deps: #4.1`

    The user's exercises, the muscle groups each works, alternates, gym ties, notes, and past sets by workout.

- [ ] **`#7.8` Progress is not specified**
    `BLOCKER` · `Deps: #4.1`

    Each exercise's ideal load over time. Waits on Research/Method for what the view shows.

- [ ] **`#7.9` Mobility is not specified**
    `BLOCKER` · `Deps: #4.1`

    Mobility workouts and their grading.

- [ ] **`#7.10` Cardio is not specified**
    `BLOCKER` · `Deps: #4.1, #8.1`

    Runs, treadmill sessions, and hikes from the watch. Waits on Research/Suunto for what Auburn shows, history, when data arrives, and notes.

- [ ] **`#7.11` The Notion import is not specified**
    `BLOCKER` · `Deps: #4.1`

    A one-time import of Training '26. Waits on Research/Notion Import for how the export writes relations and order.

- [ ] **`#7.13` The muscle figure is not specified**
    `BLOCKER` · `Deps: #4.1, #7.12`

    Front and back views, one region per muscle group, lighting an exercise's groups, and tinting by rest band. The art is traced from Albinus's Tabulae sceleti et musculorum (1747), engraved by Jan Wandelaar, from a public-domain scan.

## Alignment 3 — Integrations

### `#8` Integrations · [Spec/Integrations/](Spec/Integrations/)

- [ ] **`#8.1` The intervals.icu integration is not specified**
    `BLOCKER`

    Endpoints, the personal API key and how it is stored, FIT parsing, and tolerance for values newer than the parser's profile. Waits on Research/Suunto for how the key is stored.
