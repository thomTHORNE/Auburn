Status: Open

# Notion Import

A one-time import of Training '26, so rest, history, and progress are right from the first day. Maps onto Foundation's terms until the Data Model exists.

## Settled

- **One-time, from a Notion CSV export.** Auburn holds no connection to Notion.
- **Goals:** name as is; page content becomes the explanation. Exercises import as primary; the user sorts primary from alternates by hand. The modality values Upper, Leg Day, and Stim become the goal's split.
- **AMAP:** no exercise imports as AMAP; the user marks them. Until then every exercise resets its goal, as in Notion.
- **Exercises:** name as is; the Observations, Settings, and Form callouts become the exercise's notes.
- **Workouts:** date as the start. The gym comes from the name — ": Iva Gyma" is Iva Gyma. Commit order is the order of the workout's exercises, which Notion shows as "Nu". Imported workouts carry no modality.
- **Mobility workouts** import with no sets and no grades.
- **Sets:** creation time is the time logged. Kg-Km is parsed as a number, reading "," as a decimal point. Grade maps one to one. Reps come from Rps-Min where present. Ungraded sets import ungraded — a state only imported sets can have. Drop-set values ("49!42") take the first load and keep the raw value as a note.
- **Dropped:** meantime, latest workout, activity, today's workout, punch-in card, bound workouts, previous and next, circuit, ignore tracking, and Match.

## Open questions

- **The export.** How Notion's CSV export writes relations, and whether it keeps the order of a workout's exercises.
- **Workouts without a gym in the name.** Which gym they were at.
- **Notion's split values.** Lower, Full Body, Gym Gap: Cardio, and Home Gap: Full Body.
- **Cardio sets.** Running, Skiing, and Cycling sets logged in Notion.

## Findings

- **"Nu" is commit order.** Notion's set displays compute it as the exercise's position in its workout's exercise list.

## Dependencies

- **Requires:** none.
- **Required by:** none yet. The Data Model's records are its targets once they exist.
