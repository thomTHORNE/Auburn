Status: Open

# Notion Import

A one-time import of Training '26, so rest, history, and progress are right from the first day. Maps onto Foundation's terms until the Data Model exists.

## Settled

- **One-time, from a Notion CSV export.** Auburn holds no connection to Notion.
- **Goals are not imported.** Notion's goals mixed muscle groups and achievements; the user rebuilds both by hand. Exercises import with no muscle groups, goals, or alternates, and reset nothing until the user ticks their muscle groups.
- **AMAP:** no exercise imports as AMAP; the user marks them.
- **Exercises import with no gym.** The user ties them to gyms afterwards; Notion had no mechanism for gyms beyond grouping sets by workout.
- **Exercises:** name as is; the Observations, Settings, and Form callouts become the exercise's notes.
- **Workouts:** date as the start. The gym comes from the name — ": Iva Gyma" is Iva Gyma; every other workout is Gyms4You. Commit order is the order of the workout's exercises, which Notion shows as "Nu". Imported workouts carry no modality.
- **Mobility workouts** import with no sets and no grades.
- **Sets:** creation time is the time logged. Kg-Km is parsed as a number, reading "," as a decimal point. Grade maps one to one. Reps come from Rps-Min where present. Ungraded sets import ungraded — a state only imported sets can have. Variable loads ("49!42", "60-50") take the first load.
- **Dropped:** meantime, latest workout, activity, today's workout, punch-in card, bound workouts, previous and next, circuit, ignore tracking, Match, Notion's goals, modality and split values, and Running, Skiing, and Cycling with their sets — cardio arrives through Suunto.

## Open questions

- **The export.** How Notion's CSV export writes relations, and whether it keeps the order of a workout's exercises.

## Findings

- **"Nu" is commit order.** Notion's set displays compute it as the exercise's position in its workout's exercise list.

## Dependencies

- **Requires:** none.
- **Required by:** none yet. The Data Model's records are its targets once they exist.
