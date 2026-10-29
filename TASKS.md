# Tasks

All of Auburn's work, by version: the spec each version needs, and the release work that puts it in people's hands. Structure: Version → Alignment → Goal → Item.

## Status

- `[ ]` **Unresolved** — default state. No work done yet.
- `[x]` **Pending review** — drafted or done, awaiting user review.

Resolved tasks are removed from TASKS.md.

## Severity

- `BLOCKER` — missing spec that would produce broken or undefined behavior at implementation time, or release work the version cannot be released without.
- `GAP` — incomplete or inconsistent spec that would cause a developer to make a wrong assumption.
- `MINOR` — should be addressed but low risk if deferred; implementation or the release can proceed without it.



## v0

The developer and a small circle of trusted testers · [Scope](Spec/Scope.md#v0)

Waits on research: Suunto, Notion Import, Lore, Programming, Tests.

### Alignment 1 — Lens

#### `#12` Visual language · [Lens/Language/Visual/Visual.md](Lens/Language/Visual/Visual.md)

- [ ] **`#12.1` The visual basics are not specified**
    `MINOR`

    The values on the design canvas and the Lab verdicts: CRT strength 0.6, glass LOW, travel SMALL. The rest bands' red reads weakly on the ember plate. The muscle figure's engraving, lit and band colours, source plates, and asset format: one shape per muscle group per view, named after the group.

- [ ] **`#12.2` The muscle figure's art is not traced**
    `MINOR`

    Front and back plates from Albinus's Tabulae sceleti et musculorum (1747), engraved by Jan Wandelaar, traced into one region per muscle group from a public-domain scan. Refined placeholder shapes stand in until it is done.

#### `#13` Touch language · [Lens/Language/Touch.md](Lens/Language/Touch.md)

- [ ] **`#13.1` The haptic pulse is not specified**
    `MINOR`

    A logged set is confirmed by one (Principles: Every input answers at once). Its strength, length and pattern are specified with screen 06.

### Alignment 2 — Spec top level

#### `#6` Screens · [Spec/Screens/Screens.md](Spec/Screens/Screens.md)

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

    The tap area lands as agreed. Touch.md's Tap section becomes: "Every key's tap area is at least the tap area value in each direction. A key drawn smaller keeps its look and takes the rest as an invisible margin; keys closer together than that are set apart until their areas do not overlap." Visual.md's Values section reads: "Semantic values say what a value is for — roles, emphasis levels, faces by job, timings, the tap area — and refer only to primitives, except a measure no scale holds, such as the tap area." basics.css gains, in the semantic tier, `/* Tap area: Android's least touch target */ --tap-area: 48px;`. Visual.md also gains, after Emphasis, its spacing rule: "### Spacing — Space shows how things relate: the more closely two things belong together, the less space between them. Every gap is a step of the spacing scale, chosen by the relationship it separates, so the same relationship looks the same on every screen. | Relationship | For example | Step | — Parts of one thing | A load and its unit; the two lines of one fact | `--space-1` — A thing and what names it | A mark and its label; a field and its caption | `--space-3` — Like things in a series | List entries; keys in a row; widgets in a grid | `--space-3`, or none where a line or border divides them — A heading and what it heads | A section title and its list; a name and its details | `--space-4` — Separate sections of a screen | The header and what follows it | `--space-6` — The screen's edge | The content's inset | `--space-5` — A container's padding is never less than the largest gap inside it. A relationship the table does not name is added to it before a screen uses it. Space is measured to what the eye sees: where text meets an edge, half its leading comes off, so the space looks even." The Lexicon drops Edit, Done, Half and Full.

- [ ] **`#6.21` The widgets are reconsidered once Goals is agreed**
    `MINOR` · `Deps: #6.14`

    Agreeing screen 11, goals, shows what each widget must carry at a glance and how. Rest at a glance does not fit at half width: its name wraps to three lines and its lines are cut off.

- [ ] **`#6.22` The boot predates the scales**
    `MINOR` · `Deps: #6.20`

    The boot's sizes and gaps (14, 10, 4 and 12 px among them) are its own, from before the type and spacing scales. It is revisited in a round of its own and brought onto them.

#### `#9` Architecture · [Spec/Architecture/Architecture.md](Spec/Architecture/Architecture.md)

- [ ] **`#9.1` The storage engine is not specified**
    `GAP`

    The on-phone database behind the Data Model's records. Chosen when the walking skeleton begins.

### Alignment 3 — Features

#### `#7` Features · [Spec/Features/](Spec/Features/)

- [ ] **`#7.10` Cardio is not specified**
    `BLOCKER` · `Deps: #8.1`

    Runs, treadmill sessions, and hikes from the watch. Waits on Research/Suunto for what Auburn shows, history, when data arrives, and notes.

    Cardio is reached from navigation. Whether it opens a screen of its own, and what that screen lists, is not yet decided.

- [ ] **`#7.11` The Notion import is not specified**
    `BLOCKER`

    A one-time import of Training '26. Waits on Research/Notion Import for how the export writes relations and order.

### Alignment 4 — Integrations

#### `#8` Integrations · [Spec/Integrations/](Spec/Integrations/)

- [ ] **`#8.1` The intervals.icu integration is not specified**
    `BLOCKER`

    Endpoints, the personal API key and how it is stored, FIT parsing, and tolerance for values newer than the parser's profile. Waits on Research/Suunto for how the key is stored.

### Alignment 5 — Release

#### `#10` Testers · [Spec/Scope.md](Spec/Scope.md#v0)

- [ ] **`#10.1` A tester without a Suunto watch has cardio overdue for good**
    `GAP`

    v0's cardio comes only from a Suunto watch through intervals.icu. A tester without both never resets cardio's rest, so it falls overdue and the overdue prompt asks at every visit.

- [ ] **`#10.2` A tester's first launch is empty**
    `GAP`

    Exercises are the user's own and there is no library, so a tester opens Auburn with no exercise and no gym, and nothing to start a workout with. What the first launch does is not specified.

- [ ] **`#10.3` The Notion import is the developer's alone**
    `MINOR`

    It reads Training '26, which no tester has. Whether a tester is offered it is not specified.

- [ ] **`#10.4` Auburn is measured on the Fold 8 alone**
    `GAP`

    The CRT shader's cost and every layout were measured on the Fold 8 cover screen. v0 runs on testers' Android phones and on iPhones. The developer's devices span the range: the Fold 8, the Galaxy S23, the Pixel 9a, and the iPhone 13 mini as the small screen. Architecture requires Impeller; which testers' phones run it is not known.

#### `#11` Distribution · [Research/Launch/Distribution](Research/Launch/Distribution/Distribution.md)

- [ ] **`#11.1` The Play developer account is not opened**
    `BLOCKER`

    Personal or organisation. A personal account opened now falls under the closed-test rule; an organisation account needs a registered business.

- [ ] **`#11.2` Twelve Android testers are not recruited**
    `BLOCKER`

    At least 12, opted in to the closed test for 14 days in a row. iPhone testers on TestFlight do not count toward them.

- [ ] **`#11.3` The Play declarations are not filed**
    `BLOCKER` · `Deps: #11.1`

    The Health apps declaration, as Activity and Fitness, and the Data safety form. Whether a privacy policy is required is checked with them.

- [ ] **`#11.4` The Apple Developer Program is not joined**
    `BLOCKER`

    TestFlight comes with the membership. Builds are made and signed on the MacBook Air M1.

- [ ] **`#11.5` TestFlight is not set up**
    `BLOCKER` · `Deps: #11.4`

    Testers join as internal testers, who must be members of the App Store Connect team, or as external testers, whose first build of each version passes Beta App Review. Builds expire 90 days after upload.



## v1

The public · [Scope](Spec/Scope.md#v1)

Waits on research: Launch — Name, Distribution, Protection, Pricing, Website, Forums, Outreach.

No items yet.
