# A week in the gym — prototype

Throwaway code. The question, pass condition, and verdict live in [`Lab/Log.md`](../Log.md).

A whole session on the phone, on Training '26's history: start at a gym, pick a routine or none, commit exercises as they are done, log load and grade, mark a test now and then. Goals, their charts, and rest by rhythm read what the week records.

- `lib/model.dart` — the records, after `Spec/Data Model.md`, kept in one JSON file on the phone and written on every change.
- `lib/logic.dart` — rest and its rhythm, progress lines, a goal's reach, what a routine offers, a set's starting load.
- `lib/ui.dart` — plain parts from the visual basics: the palette, a 48 px tap area. No tube. Saira and secondary and supporting text at 70% are a trial for the prototype only.
- `lib/screens/` — home, workouts and sets, exercises, routines, goals, rest, gyms, and export and import.
- `tool/convert_notion.py` — turns the Notion export into `assets/history.json`.
- `test/logic_test.dart` — checks rest's rhythm, a goal's reach and undo, a routine's offer, and that every screen lays out.

## The history

`assets/history.json` is personal data and is never committed. Write it before building:

```
python3 tool/convert_notion.py <the unzipped Notion export>
```

A build that carries it imports it on first launch: exercises with their notes, workouts, and sets. Mobility workouts, cardio, and sets with no workout are left out, as Research/Notion Import says. A build without it starts empty.

## Running it

From this folder, with the phone connected:

```
flutter run --release
```

or build an APK to install by hand:

```
flutter build apk --release --split-per-abi
```

Put `lab.keystore` at `android/app/lab.keystore` first. It is not committed. Builds signed with it install over each other, so the week's data survives an update; a build signed with another key has to replace the app, which wipes its data.

## First steps on the phone

1. **Exercises** — every imported exercise names no muscle group yet, so rest counts nothing. Open each one you use, **Edit**, and tap its muscle groups: one tap main, two supporting, three neither. Check its load kind, and a stack's or dumbbells' step: the import starts every step at 2.5 kg.
2. **Routines** and **Goals** — make the ones you train by. A goal joins a routine once it is active.
3. **Start workout**.

## Keeping the data

**Export data** on home writes every record to one file, `auburn-<date>.json`, wherever you choose. **Import data** replaces everything on the phone with such a file. Export before installing a build signed with another key, and import after.

## What to note during the week

Every friction, with the moment it happened. Most of all:

- committing — how long it takes to find an exercise outside the routine. The rest of the gym's exercises are listed alphabetically, on purpose;
- logging — whether load, grade, and a test can be set one-handed between sets;
- whether the routine's offered list, with a goal shown as itself above its exercises, reads right;
- whether rest's four steps say what you would say about each muscle that morning.

## Shortcuts, and where it leaves the spec

- Plain screens: only screens 00 and 01 are agreed, so every layout and word here is a stand-in.
- No tube, sound, figure, splits, settings, or cardio. A goal's target sits on an exercise only.
- A reach prompt appears on home; home is a list, not screen 01's widgets and sheet.
- An exercise's load kind can be changed after it has sets, since the import guesses it from the name.
- Loads are corrected in 2.5 kg steps on plates, without the plate keys.
- Fonts: Saira and Gelasio are bundled under the SIL Open Font License (`fonts/OFL-*.txt`).
