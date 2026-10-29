# Auburn — Claude briefing

Read this at the start of every conversation. It captures the working context built up across conversations so you don't need to re-derive it from scratch.

---

## What Auburn is

A personal fitness training app, built around how the user actually trains.

Most of what the fitness apps on the market do applies to Auburn. Where it departs from them is in the specifics of how the user trains and approaches training, and those departures are the reason Auburn exists rather than an off-the-shelf app being used. [Foundation](Foundation.md) states them, and is the root everything else answers to.

Mobile only: Android and iOS phones, from v0. The stack is Flutter — see `Spec/Architecture/Architecture.md`.

Currently in the **foundation phase**, pre-spec and pre-development.

---

## The user

Solo developer and founder. Strong product instincts. Technically capable — the spec is written to a level of precision that development can follow directly.

**How they work:**
- Prefers to reason decisions out loud before writing anything down
- Reviews drafts before approving
- Values concision: no filler, no padding, no vague aspirational language
- Defers anything not fully understood rather than half-speccing it

**Background and expertise:**
- Strong Vue 3 + TypeScript frontend experience, at professional level
- Familiar with .NET and C#
- Building Northstar in Flutter/Dart
- New ground on this project: GPU shaders (GLSL fragment shaders under Impeller), the FIT file format, and Android platform specifics. Flutter and Dart are familiar from Northstar.

**Devices:** Galaxy Fold 8, Galaxy S23, Pixel 9a and iPhone 13 mini; a MacBook Air M1, the machine that builds for iOS; a Windows PC and a Windows laptop.

**Mentorship directive (applies during development):**
Take a student-professor approach for the new ground: explain the reasoning, the alternatives considered, and the tradeoffs rather than only providing the answer. For the user's professional territory, answer directly. Explaining what the user does professionally is noise.

Training knowledge runs the other way. How the user trains is their expertise, and it is what Auburn is built around. Do not correct their training approach toward the market's defaults; ask until it is understood, then specify it as it is.

The user also runs **Northstar**, a Flutter/Dart music library manager, and **Stem**, a thinking canvas. The three projects share these working conventions and nothing else — different domains, separate specs. Do not carry their *content* across.

---

## Repo structure

```
Auburn/
├── CLAUDE.md               ← this file
├── Foundation.md           ← why Auburn is shaped the way it is. The root.
├── TASKS.md                ← every version's work, spec and release, with inline reasoning notes
├── Ideas.md                ← deferred ideas, not committed to spec
├── Research/               ← ideas developed in parallel to the spec. See Research below.
├── Learning/               ← explainers. See Learning below.
├── Lab/                    ← throwaway code that answers questions. See Lab below.
│   └── Log.md              ← every attempt and where it stands
├── Tools/                  ← scripts that maintain the repo, such as rendering the screen images
├── Canvas/                 ← mirror of the design canvas, history in git
├── .claude/skills/         ← project skills. /sitrep prints a conversation checkpoint.
└── Spec/
    ├── Scope.md            ← what each version includes and excludes
    ├── Data Model.md       ← source of truth for every training record
    ├── Design Principles.md
    ├── Visual Design.md
    ├── Sound Design.md
    ├── Features/
    ├── Architecture/
    │   └── Architecture.md
    └── Integrations/
```

**Foundation holds authority over `Spec/`.** Where a spec document disagrees with Foundation, Foundation holds and the spec document is the defect.

---

## Lens

`Lens/` holds what Auburn is judged through; `Spec/` holds what is built through it.
[Lens/Glossary.md](Lens/Glossary.md) defines the vocabulary for both and the rules that
place every document. Read it at the start of every conversation, with Foundation, and use
its words only in the senses it gives them.

---

## Spec structure

`Spec/` is the complete reference for building Auburn — behavior, structure, mechanics, and technical decisions. It is divided into these domains, each with a distinct purpose:

| Domain | Purpose |
|---|---|
| **Scope** | What each version includes and excludes, and why. Foundation and the design principles stay fixed across versions; scope is what changes. |
| **Data Model** | The canonical definition of every record Auburn keeps — exercises, sessions, sets, programs, measurements — with fields, types, and rules. The single source of truth. If a field isn't defined here, it doesn't exist in Auburn. Feature specs reference it; they never redefine it. |
| **Design Principles** | The principles that govern every decision, each tracing to the Foundation section it derives from. A lens applied to every feature — not a spec in its own right. |
| **Visual Design** | Concrete values: palette, type, spacing, radii. Where Design Principles holds the reasoning, this holds the numbers. |
| **Sound Design** | The sounds, when each plays, and when Auburn is silent. Where Visual Design holds the picture, this holds the sound. |
| **Features/** | Behavioral specifications — what each feature does, the rules governing it, its states, constraints, and edge cases. No implementation detail lives here; that belongs in Architecture or Integrations. |
| **Architecture/** | Structural and technical decisions: stack, persistence, sync, build sequencing. Records the why behind major choices. |
| **Integrations/** | Source-specific implementation detail for outside systems: endpoints, tokens, payloads, platform constraints. Feature specs stay behavior-focused and reference the relevant integration spec for the how. An integration that grows in scope becomes its own subfolder. |

**Feature spec structure** — every file in `Features/` follows this format:

1. **What it is** — one paragraph, plain English
2. **Behavior** — the rules, broken into named subsections
3. **States** — meaningful states the feature or record can be in (say whether they are runtime or persisted)
4. **Constraints** — hard limits, version-scoped limitations
5. **Edge cases** — a table of scenario → behavior

**One owner per rule.** A term, unit, or calculation that several features use — how a set's load is recorded, what counts as a completed session, how volume is computed — is defined once, in the file that owns it, and referenced everywhere else. A rule that appears in four features will otherwise be defined four times and eventually disagree. This is the rule the Data Model carries for fields, applied to everything shared.

## Visual design process

`Spec/Visual Design.md` holds the rules every screen follows and the screens table; `Spec/Visual Design/basics.css` holds every value — palette, faces, emphasis, timings, the tube's numbers. Each agreed screen has its own document in its folder, linked from the table. A screen is either agreed or stated as not yet specified, with a TASKS.md item for each screen still open. The screens are agreed one at a time.

### How a screen gets agreed

1. **Explain it first.** Before any design, Claude states the screen's purpose, why it earns its place, and what it must carry. The user confirms it is understood, or the screen is cut or merged. A screen that cannot say why it exists is not designed.
2. **Wireframe the information.** On the screen's page in the canvas, every piece of information that could appear is laid out and weighed, and only what earns its place stays. Wireframes carry no look, but they carry structure: which pieces form one thing, which names which, which heads which, and which are separate sections. That structure sets every gap, from Visual Design's spacing table, before the first round.
3. **Iterate on the design canvas**, round by round, until the user approves a version. A round is built from the basics' rules first: every gap from its relationship, every text from the type scale at its emphasis level, every key at the tap area. A round that needs a value the rules don't give, or a different one, asks for it, and either the rule or the round changes.
4. **Save the approved version**: the screen's document, its HTML, and an image per state, as below.
5. **Remove its TASKS.md item.**

### An agreed screen

Its folder, `Spec/Visual Design/<nn-screen>/`, holds `<nn-screen>.md`, `screen.html` and the state images. The document opens with **Why it is shaped this way**: the reasoning from the explanation, the wireframe and the rounds — what the screen had to carry, what was weighed and set aside, and why — written in the spec's voice and kept in step with the rules below it. Then five parts. A document never describes what its design shows:

- **Purpose.** One sentence: what the user comes here to do.
- **Earns its place.** What would break or be worse without it, and why it is not folded into another screen.
- **Rules.** What the design cannot show: the data each part carries, what varies and why, and what holds in every state.
- **Controls.** Every tap and what it does, never how the key looks.
- **Images.** One per state that matters, rendered from `screen.html` by `Tools/render-screens.mjs` and never edited by hand.

`screen.html` is the approved board as one file that links `basics.css` and uses only its values, and lists the states to render.

### An agreed component

Its folder, `Spec/Visual Design/components/<name>/`, holds `<name>.md`, `component.html`
and the state images. The document follows a screen's, without **Earns its place**: **Why it
is shaped this way**, then **Purpose**, **Rules** (what each property changes, and what holds
in every state), **Controls** and **Images**. A screen's document names the components it
uses and never repeats their rules.

`component.html` is the agreed component as one template: its markup, a hole for each piece
of text it is given, and a data attribute for each property that changes its look. It links
`basics.css`, uses only semantic and component values, and lists the states to render.
`Tools/` builds `Spec/Visual Design/components.js` from every `component.html`; a screen's
`screen.html` loads it and places each component as an element, never a copy of its markup.
`components.js` is generated and never edited.

On the canvas, a component's board is generated from its `component.html`, with a tweak for
each property, and every screen board that uses it imports it.

### What owns what

- `basics.css` owns every value. A screen never introduces one; a value it needs is added there first.
- `screen.html` owns the look and layout: sizes, gaps, positions. Canvas pixels are Flutter logical pixels. The art files own the art.
- `component.html` owns a component's look and layout. A screen's `screen.html` owns where each component sits and which properties and text it is given.
- The screen's document owns reasoning, behaviour, rules, and data.
- Images are rendered, never edited.

Where two disagree, the owner holds and the other is fixed in the same edit. A change to a screen is not done until its document, HTML, and images all agree.

### The canvas

Design work happens on the canvas: the Claude Design artifact "Auburn Visual Direction",
https://claude.ai/artifact/GrWcshpnyMBXD5XAPsxaQp. Its format rules are in its `SKILL.md`,
read with the Artifact tool.

**The mirror.** `Canvas/project/` holds the canvas's `project/` folder file for file, and git
is its history. A session's first turn on the canvas reads every file, since it has no
earlier read to compare with. At the start of every turn where the canvas's edit count has gone up since
Claude last read it, Claude reads every file on the canvas and commits whatever differs from
the mirror as the user's edits, whether or not a publish follows. A publish, every time:

1. Read every file on the canvas. Where any differs from the mirror, write it in and commit
   it as the user's edits.
2. Make the change in the mirror. A board built by a script in `Tools/canvas/` is changed
   through its script, with any edit the user made to it carried into the script first.
   Each script's header says what it builds and how to run it.
3. Commit with a message starting `Canvas:`, push, then publish only the changed files,
   with `Canvas/` as the root. A refused publish means the user saved meanwhile: start
   again at 1.

A publish that changes a script in `Tools/canvas/` is looked at in the artifact emulator
before it goes out.

A publish is undone by publishing the files from the commit before it.

**Pages.** Theme first, then Components, then one page per screen named by its number and
name (its wireframes and rounds), then Explorations.

**Values.** `project/basics.css` is a copy of `Spec/Visual Design/basics.css`, and every board
links it. A board never declares a value. A screen board declares no values. Sizes and
gaps are steps of the basics' type and spacing scales; only a position on one screen is that
screen's own.

**Boards with tweaks.** Each has a tweak for every basic except the tube's, starting from the
basics, and lists what it changed as `name start → now`. A change stays on its board until it
is persisted; nothing reaches from one board to another.

- The Theme board, alone on the Theme page, shows every agreed screen. A change there shows
  on all of them at once.
- A round board, on its screen's page, shows every state of one round. A value that is not
  yet a basic, such as a new scale, is tried on the round that needs it.

Each board with tweaks has four named swatches, Trial A to D, that any colour choice on it
can use. A swatch is never persisted as it is: it joins the palette under a name first.

**Tuning.** Values are tuned in the editor's Tweaks tab, which saves them in the board's
file: ctrl+Z undoes them until the page is switched, and Claude reads them from the file.
Each board shows each value's start, has a hold-to-preview showing every start for as long
as it is held, and keeps a change log: every value change it has seen, newest first, kept
on the user's computer. An earlier value is read from the log and set back in the Tweaks tab.
Reset all is Claude republishing the board from the basics.

**Persisting.** The user says which trials persist. Claude writes those into
`Spec/Visual Design/basics.css`, copies it to the canvas, and removes the persisted and the
dropped trials from the boards, all in one commit.

**Rounds.** Every round has a status: in progress, approved, or set aside. It shows in the
round's title on the canvas and in its round board's heading. An approved round is a record
and is not changed again. Approved work changes through a new round, started from the agreed
version:

- the theme: tuned on the Theme board, then persisted, with no round;
- a screen: a new round on its screen's page;
- a component: a component round on the Components page, showing the component with every
  agreed screen that uses it.

Approving a round replaces the agreed version with it: a screen's `screen.html`, document and
images; a component's board; and the values the user keeps, into `basics.css`.

**Components.** A named part of the interface with its own states is a component, built once
and used wherever it appears. The Components page holds the agreed components, each its own
board showing each of its states and imported by every agreed screen that uses it, with
component rounds below them. A component reaches the page when the round that introduces it
is approved. A component changes only through a component round on the Components page,
showing its states with every agreed screen that uses it. A screen round that needs a component
changed opens that component round and imports the component as the round has it; the two are
approved together, and every screen that uses the component changes with it.
A component round that reshapes a component keeps its template in
`Tools/canvas/rounds/<round>/<name>/component.html`; approving the round makes it the agreed `component.html`.
A component's board has a tweak for each of its properties and none for values: its look is
tuned on the Theme board, or on the board of the round that imports it.

**Clean boards.** The tube — curvature, scanlines, glass — and any other render effect, such
as glow, flicker or bloom, is never faked on the canvas. The canvas judges layout, design,
flow and use; the tube's look is checked on the device.

**Known traps.** A `{{hole}}` is a dotted lookup only, never an expression. Text inside an
SVG takes no holes: put it in HTML over the SVG. An uploaded image is used in CSS only from
a `<helmet>` rule. Editing a `.dc.html` with `\u00b7`-style escapes fails: edit the parsed text.
The canvas ignores `style` on a `dc-import`: a placed import sits in a div that carries the
placing. A board shown inside another takes only the outer board's helmet rules, so every
board carries every component's CSS. A publish of supporting files still needs a
`file_path`: one of the changed files, with `Canvas/` as the root. The artifact emulator does
not load uploaded images; the bust missing there is not a fault.

---

## Research

`Research/` is where an idea is developed in parallel to the spec, at more length than `Ideas.md` can hold.

Research carries no authority. It does not define behavior and nothing in it constrains implementation — it is thinking in progress, not a decision. Where `Learning/` explains concepts and `Ideas.md` parks possibilities, `Research/` is the one place with a path out: a topic developed thoroughly and shown to apply to Auburn is promoted into `Spec/`, and the research document stops being the reference the moment it lands there.

### Structure

**A topic is the unit of research.** Each is a directory holding `<Topic>/<Topic>.md`, plus whatever supporting files it needs.

**An initiative is optional.** When several topics are worth more together than apart, they nest under an initiative directory carrying its own document — the case for why they belong together, the findings that live at their seams, and what would falsify the whole. A topic that stands alone sits at the top level. Grouping is read off the tree, not declared inside files.

```
Research/
├── <Topic>/                ← stands alone
│   └── <Topic>.md
└── <Initiative>/
    ├── <Initiative>.md
    ├── Origin.md           ← frozen, if seeded by a prior record
    └── <Topic>/
        └── <Topic>.md
```

**Topics are split by blocker, not by subject.** Two questions sharing a subject but waiting on different things belong in separate topics, so neither is held up by the other's blocker. Parallel development is the reason the directory exists. It follows that two topics under one initiative are still independent — an initiative explains why they matter together, it does not couple their schedules.

### Origin

A topic entering `Research/` from a prior record — an `Ideas.md` entry, a brief written to open a conversation, or research carried across from another project — carries that record across as `Origin.md`, frozen and never edited. A topic with no prior record has no `Origin.md` — it was written here from the start, and the topic document is its own first record.

`Origin.md` sits beside the document it seeded — at the initiative when an entry was promoted into one, at the topic when it was promoted into a standalone topic. References inside a frozen origin may no longer resolve; that is expected and they are not repaired.

Promoted ideas are removed from `Ideas.md`. The frozen origin is the only copy.

### Findings and dependencies

**Findings are owned by the document they change**, not the one they were discovered in. A finding at the seam between two topics belongs to the topic that must change if it holds. Every topic carries a `Dependencies` section naming both directions — what it requires from other topics, and what requires it. A topic with neither says so.

### Status and promotion

**Topic status**, carried on the first line of the topic document:

| Status | Meaning |
|---|---|
| `Open` | Under research |
| `Ready` | Cleared the promotion bar, held by a dependency. Earns a TASKS.md item carrying the `Deps:` that blocks it |
| `Promoted` | Landed in spec. The research document is no longer the reference |

Research stays out of TASKS.md's items while it is still research. A version that waits on a topic names it in its `Waits on research:` line, and the topic enters as items only at `Ready`, at which point its promotion is work like anything else. Release work already decided is tracked as items under its version, even while research around it is open.

**Promotion bar.** A topic is ready when its open questions are resolved rather than listed, and its conclusions can be stated as decisions in the spec's own voice.

Partial promotion is allowed for sections that stand on their own justification. A section whose reason depends on a topic that has not itself promoted does not go early with a forward reference — it waits, and the topics promote together. A rule in the spec justified by something that does not exist yet cannot be evaluated by the person reading it.

---

## Learning

`Learning/` holds topic-based explainers that branch off from project work into broader concepts. Files are written with Auburn as the running example but cover general ground — the technical ground the stack brings, and any training-science or data concept the spec leans on. They are not spec, do not define behavior or decisions, and carry no authority over implementation. Read them when the user references a prior explanation or asks to revisit a concept.

`Learning/Glossary.md` holds one line per term and links to the explainer that owns it.

### Explainer form

An explainer teaches by putting the reader inside a real scenario before it names anything. This structure is approved and is what a new section should follow:

1. **Open on something the user would actually do.** Not "consider a record" — "you've just logged your last set and you want to see whether today beat last week." The concept then arrives as the answer to a problem they already have, rather than as material to get through.
2. **State the problem as a cost, and let it build.** Concrete numbers, escalating. Do not rush this part. The weight of the problem is what makes the solution land as necessary rather than arbitrary.
3. **Turn once, explicitly.** A single line pivoting from problem to answer. One turn, clearly marked, not a gradual drift into the solution.
4. **Deliver the solution and its picture together.** The moment the answer arrives it needs a diagram or a worked calculation in the same breath. Prose alone at this point does not land, however clear it is.
5. **Ground it in what the reader does.** Once the mechanism is on the page, restate it in the reader's own vocabulary before charging for it: the concept as a sentence they would actually say, a test they can run themselves that separates it from its neighbours, and a mapping from their real actions onto the part of the system each one touches. An abstraction the reader cannot locate in their own behavior will not survive the tradeoff that follows.
6. **Then charge for it.** Every technique has a price, and the explainer is not finished until the price is shown — worked through the *same* example, not a fresh one.
7. **Name the alternative that was rejected, and why.** The tradeoff is the teaching. A solution presented without its alternatives is a fact to be memorised, which is what the mentorship directive exists to avoid.
8. **Close by connecting to a rule already in the spec.** The section ends by making an existing decision legible — the reader should finish it understanding something they had already agreed to.

Supporting rules:

- **One example, carried the whole way through.** The same session, the same sets, demonstrates the win, then the failure, then the tradeoff. Introducing a second example resets the reader's working memory and costs more than it explains.
- **Demonstrate, then name.** Show the thing working before introducing the word for it.
- **Real numbers, taken from the spec.** Where the spec states a figure, use that figure. Invented numbers make a worked example read as hypothetical, which is the one thing it must not be.
- **Failures stated as symptoms, not as incorrectness.** "Last week's best set disappears from your history" lands. "The query returns a stale row" does not.
- **Pace generously, then stop.** Length spent building a problem is earned. Length spent restating a solution is padding.

---

## Lab

`Lab/` holds throwaway code that answers a question the spec cannot answer by reasoning. It runs alongside Research and the spec, not after them.

### The range

Two tracks, two scopes each. The track is the kind of question; the scope is how much of the app it touches.

```
              one point         a whole path or flow
can it work?  Probe    ──────►  Spike
is it right?  Sketch   ──────►  Prototype
```

| Level | Answers | Fidelity | Timebox |
|---|---|---|---|
| **Probe** | One fact about a platform or library. "Does intervals.icu give a Flutter app the original FIT file of a Suunto run?" | No UI. Console output is enough. | Hours |
| **Spike** | Whether a technical path works end to end. "Can a Suunto run be read, stored locally, and survive a restart?" | Minimal UI, no structure worth keeping. | 1–2 days |
| **Sketch** | How one interaction feels in the hand. "Can a set be logged one-handed between sets?" | One screen, real device, fake data. | 1–2 days |
| **Prototype** | Whether a whole flow holds up in real use. "Does a full gym session log without friction for a week?" | Several screens, realistic data, used in the gym. | Days to build, a week of use |

Past the range is the walking skeleton: thin, end to end, and kept. That is development, not Lab. The line between them is the one *The Pragmatic Programmer* draws between prototypes and tracer bullets — one is thrown away, the other is built on.

### Rules

- **Question first.** Every attempt opens with an entry in `Lab/Log.md`: level, the one question, the pass condition, the timebox. The entry is the draft the user approves. Code inside an approved attempt needs no further approval.
- **One question per attempt.** A second question found along the way gets its own entry.
- **A standing attempt** asks its one question of each new subject as it arrives — every approved screen, say — rather than opening a near-identical entry each time. It stays running, takes a verdict line per subject, and shares one codebase.
- **Shortcuts everywhere except the thing being tested.**
- **Running out of time is an answer.** The question was bigger than it looked; say so and re-scope.
- **The verdict is what counts.** It is written into the log entry and, as a finding, into the Research topic or spec item that asked the question.
- **The code is never built on.** Product code may borrow from it as a reference, never extend it.
- **Kept until superseded.** An attempt's code stays in `Lab/<attempt>/` until product code covers the same ground, then it is deleted and the entry is marked retired.
- **Attempts run on the user's phone.** A cloud session has no Flutter SDK: it clones Flutter's stable branch into its scratchpad to analyse and compile an attempt, and loses it with the container.

---

## Tone and writing style

- **Plain, direct prose.** No marketing language. No hedging. No motivational fitness copy.
- **Decisions are stated as facts.** "A set is logged when its reps are entered." Not "A set could be logged when..."
- **Open questions are resolved before writing.**
- **Anything not fully understood is deferred to Ideas.md.** A half-specced feature is worse than no spec.
- **No padding.** If a section doesn't have meaningful content, say so briefly and move on.
- **State a rule once, in the file that owns it.** Data Model owns fields, Architecture owns technical decisions. Everywhere else references them.

---

## Threads

The user triages conversation by thread and assigns finite attention to each. Volume is
never the problem; an unnavigable message is. Never withhold a finding to keep a message
short — index it instead.

### Vocabulary

- **Finding** — one true thing discovered. It holds or it doesn't. Costs nothing alone.
- **Thread** — one unit of the user's attention. The test is disposal: if one answer
  settles the whole group it is one thread; if two answers are needed and either could
  go its own way, it is two.
- **Topic** — what the conversation is about. Contains many threads, changes rarely, and
  is the user's to set. A `PIVOT` is a thread that changes it. Unrelated to a `Research/`
  topic, which is a directory with a status.

### What is a thread

Threads are what the user did not ask for. Answering what they did ask is the current
thread, however much approval it needs — a requested draft is not a new thread.

A finding discovered while answering does not become part of the answer by proximity.
If it needs something from the user, it is a thread and it goes in the index.

### When this applies

Any message introducing something the user has not already agreed to. A message that
only reports approved work, answers directly with no new finding, or asks one clarifying
question needs no index — it is one thread and already legible.

### Structure

1. **The answer** to what was asked.
2. **The index** — every thread, one line, tagged, ordered by tag.
3. **The threads**, numbered to match the index, each visually delimited.

Index lines state the finding, not its subject: "A superset has no record that ties its
sets together", not "Superset fields". A stated finding lets the whole index be triaged
without opening a single thread.

### Tags

Tags say what the thread costs the user, not what the finding is. `TASKS.md` severity
(`BLOCKER` / `GAP` / `MINOR`) is a different axis and stays in `TASKS.md`.

| Tag | Means | Test |
|---|---|---|
| `CORRECTION` | Something stated earlier was wrong | Acting on the old statement would now be a mistake |
| `PIVOT` | Changes where the current work is heading | Taking it reorders or invalidates work in progress |
| `APPROVE` | A drafted change, yes or no | The exact text exists and one word disposes of it |
| `DECIDE` | A genuine choice | More than one path is viable and the user picks |
| `NOTE` | Surfaced, needs nothing | It could be skipped and nothing downstream breaks |

The index is ordered by that table, top to bottom. Corrections invalidate, pivots
redirect, then the asks, then the rest.

Where two tags fit, the higher one wins. A pivot that also needs a decision is a `PIVOT`.

### Unanswered threads

A thread is expanded in full once. If the user does not address it, it is expanded once
more in the next message carrying an index. After that it drops to a standing line at
the end of the message:

`Open threads — 3 Load units · 5 Deload detection`

Named, not re-explained, expanded on request. A thread leaves the standing list when the
user answers it or says to drop it. Nothing is ever dropped silently.

### Form

Never remove information to save space — categorize and index it. Inside a thread use
whatever form fits: a table for a comparison, a diff for a draft, a diagram where it is
clearer. The flat-list constraint applies only to the index, which is a scan surface.

Skills print what their skill file specifies. This section governs conversation.

---

## Spec & docs workflow

- Never write to files without explicit approval of a specific draft. "Sure" or "ok" in response to "want me to write it?" means show a draft first — not write to files.
- TASKS.md tracks all of Auburn's work by version: the spec each version needs, and the release work that puts it in people's hands. Versions are `##` headings, each opening with the research it waits on. Alignments are `###` headings; a version's release work is an alignment of its own. Goals are `####` headings carrying a `#N` ID and a link to the file they cover. Items carry `#N.N` decimal IDs scoped to their goal, unique across versions. TASKS.md holds no second index of items — the Version → Alignment → Goal → Item hierarchy is the whole file.
- TASKS.md item format: a list item whose first line is the checkbox and the bold ID and title; the next line, indented by 4 spaces, carries the tags — severity, then `Deps: #X.X` if any, separated by ` · `; a description, if any, follows after a blank line, indented by 4 spaces. A blank line separates consecutive items. Status: `[ ]` Unresolved (default), `[x]` Pending review (drafted, awaiting review).

  Example:
  ```
  #### `#3` Sets · [Spec/Features/Sets.md](Spec/Features/Sets.md)

  - [ ] **`#3.2` A set logged in pounds against a program written in kilograms**
      `GAP` · `Deps: #1.1`

      The program prescribes 100 kg and the set is entered as 225 lb. Whether the set is stored as entered or converted…
  ```
- Before drafting any spec section, check the item's `Deps:` field in TASKS.md. Surface all listed dependencies and propose batching them into the current work. Do not use an inline `[#N.N]` reference as a substitute for resolving a dependency.
- Every decision made in conversation must be written into the spec before the task is considered done. Marking a task complete or moving on without writing the decision into the relevant spec file is not acceptable — the goal is to build the spec, not tick off tasks.
- When an item is resolved, remove it from TASKS.md entirely. Do not leave completed items in TASKS.md.
- **A document says what its artifact cannot.** Where a design, a sound file, or another asset exists, the document holds the reasons, rules, and behaviour around it, never a description of it.
- Decisions recorded in the spec are settled. Reopen one when something new is known — not because it feels uncertain again.
- **No todos in the spec, ever.** No TBDs, no "revisit this", no work items parked in the deliverable, no pointers to the tracker. An open question is resolved in the session that raised it, or the feature is deferred to Ideas.md — a half-specced feature is worse than no spec. The single permitted deferral is a statement that something is **not yet specified**, which is a fact about the spec's coverage addressed to its reader, not a note-to-self about work outstanding. It must have a corresponding TASKS.md item so the gap stays visible, and it is a last resort rather than a way to close a section: reach for it when a decision genuinely cannot be made yet, not when making one is inconvenient.
- **The spec never references TASKS.md.** No item IDs, no "see TASKS", no pointers to the tracker in any form. TASKS.md tracks work against the spec; the spec is the product of that work and has no knowledge of it. A spec file may state that something is not yet specified — that is a fact about the spec — but naming the item that will resolve it is tracker bookkeeping leaking into the deliverable, and it dangles the moment that item is renumbered or, on resolution, removed.
- Diagrams are derived, never authoritative. Where a diagram and the prose it illustrates disagree, the prose wins and the diagram is the defect. A change to any field, relationship, or rule a diagram depicts is not complete until that diagram is updated in the same edit. A spec whose picture disagrees with its text is worse than one with no picture, because the picture is what gets read.

---

## Session continuity

There is no work log on disk. The user keeps their own notes off-repo and will brief
you when context from previous work matters. `/sitrep` prints a checkpoint of the
current conversation for them to write from — manual only, never invoked unprompted.

---

## Verification & sourcing

- Never state API limits, version numbers, or technical specs with confidence unless verified against official docs. If unsure, say so and offer to look it up.
- This applies with particular force to platform health and fitness APIs (Apple HealthKit, Android Health Connect, wearable vendors' SDKs and data export), background execution limits on mobile, and anything about how a device records heart rate, sleep, or activity. Verify before contradicting or extending what the spec states about them.
- Training-science claims — volume, intensity, frequency, rest intervals, recovery, progression models — are stated with their source or not at all. Where the evidence is contested, say so. Where the user's own approach departs from the literature, the user's approach is what Auburn specifies; note the departure, do not argue it away.
- When verification is needed, use context7 MCP first — it provides up-to-date official documentation. Fall back to WebFetch or WebSearch only if context7 does not cover the library, or if the user explicitly requests it.
- When the user asks for sources, provide them. Do not retract a source under pressure without actually checking it first.

---

## Where things stand

See `TASKS.md` for the current phase breakdown and status.
