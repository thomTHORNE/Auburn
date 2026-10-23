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
Foundation is the root every other document answers to, and it holds only its premise. Nothing below it can be written in Auburn's own voice until it says how the user trains and where that departs from the market.

[Foundation.md](Foundation.md)
- - -
- [ ] `#1.1` `BLOCKER` **The departures from market fitness apps are not stated**
    Foundation says Auburn follows the market except where the user's training differs, and does not yet say where. Every pillar, principle, and scope line depends on this list.
<br>
- [ ] `#1.2` `BLOCKER` `Deps: #1.1` **The problem is not written**
    What the market's apps get wrong for this way of training, and what it costs in practice.
<br>
- [ ] `#1.3` `GAP` `Deps: #1.1` **Pillars are incomplete**
    Weaknesses is written and has no refusal. The remaining departures are not yet stated.
<br>
- [ ] `#1.4` `GAP` `Deps: #1.1` **Terms are not written**
    The words Auburn uses with a meaning of its own — session, set, program, and whatever the user's training adds.
:::



## Alignment 1 — Spec top level

::: toggle `#2` Scope
[Spec/Scope.md](Spec/Scope.md)
- - -
- [ ] `#2.1` `BLOCKER` `Deps: #1.1` **v1 inclusions are not specified**
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
