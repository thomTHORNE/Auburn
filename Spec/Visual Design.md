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
| 15 | Settings | The theme mode, sound and its volume, and credits | Not yet specified |
| 16 | Power down | The tube switching off while the power-down plays | Not yet specified |
