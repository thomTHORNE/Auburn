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

- [ ] **`#6.1` The visual basics are not specified**
    `MINOR`

    The values on the design canvas and the Lab verdicts: CRT strength 0.6, glass LOW, travel SMALL. The rest bands' red reads weakly on the ember plate. The muscle figure's engraving, lit and band colours, source plates, and asset format: one shape per muscle group per view, named after the group.

- [ ] **`#6.2` The muscle figure's art is not traced**
    `MINOR`

    Front and back plates from Albinus's Tabulae sceleti et musculorum (1747), engraved by Jan Wandelaar, traced into one region per muscle group from a public-domain scan. Refined placeholder shapes stand in until it is done.

- [ ] **`#6.5` Screen 02, rest at a glance, is not specified**
    `GAP`

- [ ] **`#6.6` Screen 03, the overdue prompt, is not specified**
    `GAP`

- [ ] **`#6.7` Screen 04, starting a workout, is not specified**
    `GAP`

- [ ] **`#6.8` Screen 05, committing an exercise, is not specified**
    `GAP`

- [ ] **`#6.9` Screen 06, logging a set, is not specified**
    `GAP`

- [ ] **`#6.10` Screen 07, a mobility workout, is not specified**
    `GAP`

- [ ] **`#6.11` Screen 08, past workouts, is not specified**
    `GAP`

- [ ] **`#6.12` Screen 09, exercises, is not specified**
    `GAP`

- [ ] **`#6.13` Screen 10, creating or editing an exercise, is not specified**
    `GAP`

- [ ] **`#6.14` Screen 11, goals, is not specified**
    `GAP`

- [ ] **`#6.15` Screen 12, a muscle group, is not specified**
    `GAP`

- [ ] **`#6.16` Screen 13, splits and gyms, is not specified**
    `GAP`

- [ ] **`#6.17` Screen 14, the overdue log, is not specified**
    `GAP`

- [ ] **`#6.18` Screen 15, settings, is not specified**
    `GAP`

    Edit home layout opens a screen of its own: home's widgets in their order and widths, all editable at once, each with its information replaced by ▲ ▼ and HALF/FULL. The widget's state for it is designed with this screen. The cover and name band stay; only the two lines give way to the keys, so each widget keeps its size on home.

- [ ] **`#6.19` Screen 16, power down, is not specified**
    `GAP`

- [ ] **`#6.20` Screen 01's round 3 is not approved**
    `MINOR`

    Screen 01 on the type and spacing scales, with text colours, a 48 px tap area, and no EDIT key: the home layout is edited in Settings. Entries are as tall as the tap area and the list sits lower by their growth; the handle keeps its look and its tap area reaches up over the screen. Approving it persists the scales, the text colours and the tap area into basics.css, replaces screen 01's screen.html, document and images, and the five components with their component rounds; the widget loses its EDIT key and its editing and stepped-back states.

    The tap area lands as agreed. Visual Design.md gains, after Press and hold: "### Tap areas — Every key's tap area is at least the tap area value in each direction. A key drawn smaller keeps its look and takes the rest as an invisible margin; keys closer together than that are set apart until their areas do not overlap." Its Values section reads: "Semantic values say what a value is for — roles, emphasis levels, faces by job, timings, the tap area — and refer only to primitives, except a measure no scale holds, such as the tap area." basics.css gains, in the semantic tier, `/* Tap area: Android's least touch target */ --tap-area: 48px;`. 01-navigation.md drops "Every key's tap area is at least 44 px."

### `#9` Architecture · [Spec/Architecture/Architecture.md](Spec/Architecture/Architecture.md)

- [ ] **`#9.1` The storage engine is not specified**
    `GAP`

    The on-phone database behind the Data Model's records. Chosen when the walking skeleton begins.

## Alignment 2 — Features

### `#7` Features · [Spec/Features/](Spec/Features/)



- [ ] **`#7.10` Cardio is not specified**
    `BLOCKER` · `Deps: #8.1`

    Runs, treadmill sessions, and hikes from the watch. Waits on Research/Suunto for what Auburn shows, history, when data arrives, and notes.

    Cardio is reached from navigation. Whether it opens a screen of its own, and what that screen lists, is not yet decided.

- [ ] **`#7.11` The Notion import is not specified**
    `BLOCKER`

    A one-time import of Training '26. Waits on Research/Notion Import for how the export writes relations and order.


## Alignment 3 — Integrations

### `#8` Integrations · [Spec/Integrations/](Spec/Integrations/)

- [ ] **`#8.1` The intervals.icu integration is not specified**
    `BLOCKER`

    Endpoints, the personal API key and how it is stored, FIT parsing, and tolerance for values newer than the parser's profile. Waits on Research/Suunto for how the key is stored.
