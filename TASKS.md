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

### `#6` Visual Design · [Spec/Visual Design.md](Spec/Visual%20Design.md)

- [ ] **`#6.1` No visual values are specified**
    `MINOR`

    The values on the design canvas and the Lab verdicts: CRT strength 0.6, glass LOW, travel SMALL. The rest bands' red reads weakly on the ember plate.

### `#9` Architecture · [Spec/Architecture/Architecture.md](Spec/Architecture/Architecture.md)

- [ ] **`#9.1` The storage engine is not specified**
    `GAP`

    The on-phone database behind the Data Model's records. Chosen when the walking skeleton begins.

## Alignment 2 — Features

### `#7` Features · [Spec/Features/](Spec/Features/)

- [ ] **`#7.1` Goals are not specified**
    `BLOCKER`

    A goal's explanation, the exercises that work toward it, and its progress. Weaknesses are goals.



- [ ] **`#7.3` The overdue log is not specified**
    `BLOCKER`

    The prompt when a goal falls overdue, and the log of answers. References the limit Rest owns. Waits on Research/Method for when the prompt appears and whether it must be answered first.





- [ ] **`#7.8` Progress is not specified**
    `BLOCKER`

    Each exercise's ideal load over time. Waits on Research/Method for what the view shows.

- [ ] **`#7.9` Mobility is not specified**
    `BLOCKER`

    Mobility workouts and their grading.

- [ ] **`#7.10` Cardio is not specified**
    `BLOCKER` · `Deps: #8.1`

    Runs, treadmill sessions, and hikes from the watch. Waits on Research/Suunto for what Auburn shows, history, when data arrives, and notes.

- [ ] **`#7.11` The Notion import is not specified**
    `BLOCKER`

    A one-time import of Training '26. Waits on Research/Notion Import for how the export writes relations and order.

- [ ] **`#7.13` The muscle figure is not specified**
    `BLOCKER`

    Front and back views, one region per muscle group, predefined zoom sections for the small groups, lighting an exercise's groups, and tinting by rest band. The art is traced from Albinus's Tabulae sceleti et musculorum (1747), engraved by Jan Wandelaar, from a public-domain scan.

## Alignment 3 — Integrations

### `#8` Integrations · [Spec/Integrations/](Spec/Integrations/)

- [ ] **`#8.1` The intervals.icu integration is not specified**
    `BLOCKER`

    Endpoints, the personal API key and how it is stored, FIT parsing, and tolerance for values newer than the parser's profile. Waits on Research/Suunto for how the key is stored.
