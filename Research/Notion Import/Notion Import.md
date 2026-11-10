Status: Open

# Notion Import

A one-time import of Training '26, so rest, history, and progress are right from the first day. Maps onto Foundation's terms until the Data Model exists.

## Settled

- **One-time, from a Notion CSV export.** Auburn holds no connection to Notion.
- **Goals are not imported.** Notion's goals mixed muscle groups and achievements; the user rebuilds both by hand. Exercises import with no muscle groups, goals, or alternates, and reset nothing until the user names their main movers.
- **Load kind comes from the name's equipment suffix.** "bar" is plates on a 20 kg bar; "pin-machine", "machine" and "cable" are a stack; "db" and "preacher~db" are dumbbells; no suffix is bodyweight. "db~bar" is asked at import. A stack's or dumbbells' step is asked once per exercise at import, 2.5 kg to begin with.
- **A set with no load takes the exercise's starting load:** 0 on bodyweight, the bar on plates. On a stack or dumbbells it is skipped.
- **Exercises import with no gym.** The user ties them to gyms afterwards; Notion had no mechanism for gyms beyond grouping sets by workout.
- **Exercises:** name as is; the Observations, Settings, and Form callouts become the exercise's notes.
- **Workouts:** date as the start. The gym comes from the name — ": Iva Gyma" is Iva Gyma; every other workout is Gyms4You. Commit order is the order of the workout's exercises, which Notion shows as "Nu". Imported workouts carry no modality.
- **Mobility workouts are not imported in v0.** Mobility is out of the spec; they stay in the export until Mobility decides.
- **Sets:** creation time is the time logged. Kg-Km is parsed as a number, reading "," as a decimal point. Grade maps one to one. Reps come from Rps-Min where present, and **sets with reps import as tests**: Rps-Min was entered only when a set was counted. Ungraded sets import ungraded — a state only imported sets can have. Variable loads ("49!42", "60-50") take the first load.
- **Dropped:** meantime, latest workout, activity, today's workout, punch-in card, bound workouts, previous and next, circuit, ignore tracking, Match, Notion's goals, modality and split values, and Running, Skiing, and Cycling with their sets — cardio arrives through Suunto.

## Open questions

None.

## Findings

- **"Nu" is commit order.** Notion's set displays compute it as the exercise's position in its workout's exercise list.
- **The export writes a relation as the related page's name with its link,** and each exercise's page carries its Observations, Settings and Form as headed sections.
- **Commit order survives:** "Nu" is present on 835 of 850 sets.
- **The export holds 35 exercises, 850 sets and 90 workouts**, from 5 December 2025 to 16 October 2026; 30 sets carry reps.

## Dependencies

- **Requires:** none.
- **Required by:** none yet. The Data Model's records are its targets once they exist.
