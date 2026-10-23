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



## Alignment 0 — Foundation

::: toggle `#1` Foundation
Foundation is the root every other document answers to. Its departures from the market are stated; what remains is listed below.

[Foundation.md](Foundation.md)
- - -
- [ ] `#1.3` `GAP` **Pillars are incomplete**
    Goal, Variety, Exercise notes, and Weaknesses have no refusal.
<br>
- [ ] `#1.4` `GAP` **Terms are incomplete**
    Overdue is not yet defined.
:::



## Alignment 1 — Spec top level

::: toggle `#2` Scope
[Spec/Scope.md](Spec/Scope.md)
- - -
- [ ] `#2.1` `BLOCKER` **v1 inclusions are not specified**
    Which of the market's general concepts v1 carries, and which of Auburn's departures it delivers.
<br>
- [ ] `#2.2` `GAP` `Deps: #2.1` **v1 exclusions are not specified**
:::

::: toggle `#3` Design Principles
[Spec/Design Principles.md](Spec/Design%20Principles.md)
- - -
- [ ] `#3.1` `BLOCKER` `Deps: #1.3` **No principles are specified**
    Each traces to a Foundation pillar.
:::

::: toggle `#4` Data Model
[Spec/Data Model.md](Spec/Data%20Model.md)
- - -
- [ ] `#4.1` `BLOCKER` `Deps: #1.4, #5.1` **No records are specified**
    Waits on Foundation's terms for what the records are, and on the stack for the type language they are stated in.
:::

::: toggle `#5` Architecture
[Spec/Architecture/Architecture.md](Spec/Architecture/Architecture.md)
- - -
- [ ] `#5.1` `BLOCKER` **The tech stack is not specified**
    Under research in `Research/Platforms/`. Enters as spec once that topic reaches `Ready`.
:::

::: toggle `#6` Visual Design
[Spec/Visual Design.md](Spec/Visual%20Design.md)
- - -
- [ ] `#6.1` `MINOR` `Deps: #3.1` **No visual values are specified**
:::
