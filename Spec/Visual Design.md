# Visual Design

This document holds the concrete values — palette, type, spacing, radii — and every screen of the app. [Design Principles](Design%20Principles.md) holds the reasoning that produced them.

---

## Basics

### Themes

Auburn has a dark and a light theme. It follows the device unless Settings sets dark or light. In v1 the theme changes the boot screen only; every other screen is the same in both.

### Palette

| Name | Hex |
|---|---|
| Tube | `#1A1D1A` |
| Obsidian | `#121215` |
| Ember | `#D9573B` |
| Cyan White | `#DDF7F5` |
| Graphite | `#212220` |

### Type

| Face | Use |
|---|---|
| Gelasio 700 | The wordmark |
| Saira 300 / 600 | The mark's letters and its line |
| Courier Prime 400 / 700 | Interface text: labels, lists, status, and information |

### Emphasis

Every element sits on one of three levels: Ember at an opacity on the screen colour, or Cyan White where a screen sets it apart.

| Level | Text | Lines |
|---|---|---|
| Primary | 90%, Regular | 90%, 2 px |
| Secondary | 62%, Bold | 55%, 2 px |
| Supporting | 42%, Bold | 12%, 3 px |

### The entry glyph

A chevron and an underscore on a 24-unit grid, drawn with a 2-unit stroke, square ends and square corners: `M4 7 L9 12 L4 17 M12 17 H20`. It marks every entry in a list, at the supporting level.

### Press and hold

An action that cannot be taken back is pressed and held. The control fills with Ember from its leading edge over 1.5 s, and each character turns Obsidian as the fill passes it. Let go early and the fill drains in 0.3 s.

### Covers and icons

A square on a 200-unit grid: a 7-unit Ember frame and, inside it, a solid Ember object turned 45° and clipped by the frame, its details cut in the screen colour. An icon crosses its object with a dark band carrying its short name in Gelasio 700, ruled 1 px above and below. A widget's cover has no band. The art is in [Visual Design/covers/](Visual%20Design/covers/).

### The tube

Every screen runs under one shader: curvature, chromatic aberration kept off the centre, bloom, scanlines, a vignette, a slow rolling band, grain, and glass that moves with the phone's tilt.

| | |
|---|---|
| Strength | 0.6 |
| Glass | Low (0.6); High (1.2) on the boot |
| Glass travel with tilt | Small (0.35) |

With the system's reduce-motion setting on, the band, the grain, and the glass hold still.

The rest of the basics are not yet specified.

## Screens

Each screen is agreed one at a time, as the project's visual design process sets out.

| # | Screen | Covers | Status |
|---|---|---|---|
| 00 | Boot | The brand, for the moment the app takes to open | Agreed |
| 01 | Navigation | How the screens connect, and what opening Auburn shows | Agreed |
| 02 | Rest at a glance | Every tracked group's rest, on the figure and in a list, with cardio | Not yet specified |
| 03 | The overdue prompt | Asking why training did not happen | Not yet specified |
| 04 | Starting a workout | Choosing the gym, then the kind | Not yet specified |
| 05 | Committing an exercise | The exercises offered here, and swapping for an alternate | Not yet specified |
| 06 | Logging a set | Load, grade, reps when counted, the modality, and the notes | Not yet specified |
| 07 | A mobility workout | Mobility exercises and their optional grades | Not yet specified |
| 08 | Past workouts | Past workouts, and one opened for corrections | Not yet specified |
| 09 | Exercises | The list, and one exercise with its notes, progress, past sets, and figure | Not yet specified |
| 10 | Creating or editing an exercise | Its fields, and ticking muscle groups on the figure | Not yet specified |
| 11 | Goals | Goals, and one goal with its progress | Not yet specified |
| 12 | A muscle group | Its rest and its band settings | Not yet specified |
| 13 | Splits and gyms | Managing splits and gyms | Not yet specified |
| 14 | The overdue log | Every answer, newest first | Not yet specified |
| 15 | Settings | The theme mode, sound and its volume, and credits | Not yet specified |
| 16 | Power down | The tube switching off while the power-down plays | Not yet specified |

### 00 · Boot

**Purpose.** Shows Auburn's mark, its name, and a line for the moment the app takes to start, then fades into the first screen.

**Earns its place.** It costs about eight seconds a few times a day and nothing more. It plays only when Auburn starts cold — never when it returns from the background, and never while a workout is in progress, when Auburn opens straight to the workout. It is the one place the brand is shown whole.

**Contents.** Centred, top to bottom:

- **The mark:** an Ember plate, 220 × 264, with a double Obsidian rule inside it. Within the rule, three Obsidian pillars 5 apart, lettered at their feet in Saira light — H, C, M: hypertrophy, cardio, mobility. Beneath them a rule, and under it the line, in Saira uppercase on one row.
- **AUBURN** in Gelasio, 14 below the mark, spread to the mark's visible width.
- **The line**, one of nine, picked at random each boot and never the same twice running, shown bare: "More human than human.", "Introducing, the new You.", "Human, improved.", "Built better. By you.", "Engineered to endure.", "Strength is a protocol.", "Advancement is mandatory.", "Obsolescence is optional.", "Flesh: the first machine." A line is at most 26 characters.
- **A 9 px dot grid** across the screen.

The themes differ in three things only:

| | Dark | Light |
|---|---|---|
| Screen | Tube, Ember dots | Ember, Obsidian dots |
| Wordmark | Ember, 220 wide: the plate's edge | Obsidian, 200 wide: the outer rule's edge, since the plate merges with the screen |

**The sequence**, 8 s: a Cyan White line across the middle, the picture opening from it, the plate, the pillars rising one after another, the wordmark settling, the line flickering in, a hold, then the fade into the first screen. The timeline is in `screen.html`.

**Controls.** None. The boot ignores taps and plays to the end.

**Images.**

![Boot, dark](Visual%20Design/00-boot/dark.png) ![Boot, light](Visual%20Design/00-boot/light.png)

### 01 · Navigation

**Purpose.** Home: shows where training stands at a glance and leads to every other screen.

**Earns its place.** Every screen is reached from here, by one tap on a widget or an entry, so there is one predictable way around. It is not folded into rest at a glance, because it also carries goals, cardio, the list and power down.

**Opening Auburn.** A cold start plays the boot and then shows home; with a workout in progress there is no boot, and Auburn opens straight to the workout. Returning from the background shows wherever Auburn was left. When an overdue answer is owed, the prompt opens over home. Android's back gesture on home sends Auburn to the background.

**Contents.** Three layers: the content, the list over it, and Power down over both. Top to bottom:

- **AUBURN**, in Gelasio 700, with an Ember cursor blinking once every 1.1 s, always on home.
- **The status**: the last workout, when and where — "LAST WORKOUT · 2 DAYS AGO · CITY GYM" — at the secondary level.
- **The widgets**, in the order and widths the user sets; a full-width widget takes a row and half-width widgets pair up, in reading order. They start as Rest at a glance at full width, then Goals and Cardio at half width. Each has its cover — 96 at full width, 72 at half — its name on an Ember fill in Obsidian, its information at the secondary level, and an EDIT key. The area scrolls under the list.

  | Widget | Information |
  |---|---|
  | Rest at a glance | How many groups are in Train and Overdue; which groups are overdue |
  | Goals | How many goals; the latest progress |
  | Cardio | Days since the last activity; the last run |

- **The list**, on Graphite, edged at the secondary level: a handle reading "3 MORE" or "HIDE", then the entries, each with the entry glyph — Start workout (Resume workout while one is in progress), Past workouts, Exercises, Splits and gyms, Overdue log, Settings. Down, it shows the first three; raised, it rises to just below the status.
- **Power down**, fixed at the bottom edge on Tube, in Cyan White, always visible.

**Controls.**

| Tap | Does |
|---|---|
| A widget | Opens its screen: Rest at a glance, Goals, Cardio |
| EDIT | Opens the widget's controls: ▲ and ▼ move it one place in reading order, HALF and FULL set its width, DONE closes them. The other widgets step back to 42% |
| The list's handle, tap or drag | Raises or lowers the list |
| An entry | Opens its screen |
| Power down, press and hold | Plays the power-down, then Auburn quits |

Every key's tap area is at least 44 px.

**Images.**

![Home](Visual%20Design/01-navigation/home.png) ![List raised](Visual%20Design/01-navigation/raised.png) ![Workout in progress](Visual%20Design/01-navigation/workout.png) ![Editing a widget](Visual%20Design/01-navigation/editing.png) ![Power down, held](Visual%20Design/01-navigation/power-down.png)
