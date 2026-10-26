# Visual Design

The rules every screen follows, and the index of screens. Every value is in [basics.css](Visual%20Design/basics.css); each screen's look is its own `screen.html`. [Design Principles](Design%20Principles.md) holds the reasoning.

---

## Basics

### Values

Every colour, face, level, and timing a screen uses is in [basics.css](Visual%20Design/basics.css). A screen never introduces a value; a value it needs is added there first.

basics.css holds three tiers. Primitives have no context: the palette, the font families, the steps of each scale. Semantic values say what a value is for — roles, emphasis levels, faces by job, timings — and refer only to primitives. Component values belong to one part and refer only to semantic values. Screens and components use semantic and component values, never a primitive.

Every colour is a palette colour, named for what it is. A new colour joins the palette, with its name, before anything uses it; nothing takes a colour from outside the palette.

### Themes

Auburn has a dark and a light theme. It follows the device unless Settings sets dark or light. In v1 the theme changes the boot screen only; every other screen is the same in both.

### Emphasis

Every element sits on one of three levels — primary, secondary, supporting — for its text and for its lines: the accent at the level's opacity on the ground, or the set-apart colour where a screen sets an element apart.

### Lists

Every entry in a list is marked with the [entry glyph](Visual%20Design/entry-glyph.svg).

### Press and hold

An action that cannot be taken back is pressed and held. Let go before it fills, and it is not taken.

### Covers and icons

The widget covers are in [covers/](Visual%20Design/covers/); the icon set is in [icons/](Visual%20Design/icons/), each icon taken up by the screen that first uses it. A widget's cover carries no name band, since the widget names itself.

### The tube

Every screen runs under one shader: curvature, chromatic aberration kept off the centre, bloom, scanlines, a vignette, a slow rolling band, grain, and glass that moves with the phone's tilt. Its values are in basics.css; the boot runs its glass High, every other screen Low. With the system's reduce-motion setting on, the band, the grain, and the glass hold still.

The rest of the basics are not yet specified.

## Screens

Each screen is agreed one at a time, as the project's visual design process sets out.

| # | Screen | Covers | Status |
|---|---|---|---|
| 00 | [Boot](Visual%20Design/00-boot/00-boot.md) | The brand, for the moment the app takes to open | Agreed |
| 01 | [Navigation](Visual%20Design/01-navigation/01-navigation.md) | How the screens connect, and what opening Auburn shows | Agreed |
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
| 15 | Settings | The theme mode, sound and its volume, the home layout, and credits | Not yet specified |
| 16 | Power down | The tube switching off while the power-down plays | Not yet specified |

## Components

| Component | Used on | Status |
|---|---|---|
| [Header](Visual%20Design/components/header/header.md) | 01 | Agreed |
| [Widget](Visual%20Design/components/widget/widget.md) | 01 | Agreed |
| [List entry](Visual%20Design/components/entry/entry.md) | 01 | Agreed |
| [List sheet](Visual%20Design/components/list/list.md) | 01 | Agreed |
| [Hold key](Visual%20Design/components/hold/hold.md) | 01 | Agreed |
