Status: Open

# Method

The mechanics of how the user trains, as run in Notion (Training '26) since December 2025, and what Auburn takes from them. The why is Foundation's. Seeded by [Origin](Origin.md).

## Settled

- **Rest is per muscle group**, as Foundation defines it. Rest bands default to ≤2 days red (repair), 3 blue (maybe), 4 green (train), 5+ orange (train, urgent), and are edited per group. **The overdue limit is where orange begins**: a group in orange is overdue.
- **Cardio rests like a muscle group**, with its own bands and limit, reset by a run, treadmill session, or hike from the watch.
- **The overdue log** is standalone. It is tied to no muscle group, exercise, or workout: an entry is an answer to why training did not happen, kept so slack can be looked at over time. Every prompt is answered; a sick week is answered and kept, and passed over when the log is reviewed.
- **A workout records its gym**, and is titled by date and gym — Iva Gyma in the hometown, Gyms4You locally. Home is a gym like any other.
- **A workout starts with the gym.** Auburn asks which gym first; only exercises tied to it, or to no gym, are offered.
- **A workout is hypertrophy or mobility, never both.** Hypertrophy, mobility, and cardio on the same day are separate entries.
- **Exercises are gym-specific where the equipment is.** An exercise may be tied to one or more gyms, or to none when the lift is the same everywhere. Progress is per exercise, and so per gym wherever it matters.
- **Alternates stand in for a busy machine.** An exercise names its alternates; when its equipment is taken, an alternate is committed in its place. Only alternates available at the current gym are offered.
- **Commit order is kept.** An exercise's past sets show its place in each workout.
- **Each exercise declares its load kind**, and its load is entered through that kind's input: plates (a bar plus plates per side), stack (a pin-machine or cable stack, moved a step at a time), dumbbells (a pair from a rack), or bodyweight. **A set has one load.**
- **The roll** applies to hypertrophy only. Its three modalities — slow and controlled; counted, to test strength; by feel — are equally likely. Every workout starts with the roll on, and it can be switched off and back on at any time. An exercise keeps the modality it was committed with and is never re-rolled; while the roll is off, commits are done by feel. The rolled modality is shown prominently on the exercise for that workout.
- **A grade describes the set, nothing more.** Auburn keeps no Yielding hold and proposes no next load; what follows a grade is the user's trial and error. Each grade is shown distinctly, as Notion colours its rows.
- **Reps are prefilled, not prescribed.** When the modality counts reps, the input shows the exercise's last known rep count as a placeholder, replaced by what is entered.
- **Mobility is exercises without load.** A mobility exercise has a title, notes, and gym ties. Committed to a mobility workout, it takes an optional grade — controlled (balanced and fluid throughout), improved (better than poor, short of controlled), or poor (unbalanced, helped through the motion) — and nothing else: no load, no sets, no modality. Variations and partial movements go in notes. Mobility is done when the user feels the need; nothing rests or falls due.
- **A goal shows its explanation and its exercises' progress**; a cardio goal shows its runs' times. Nothing more is shown until goals have been used.

## Open questions

- **The overdue prompt.** When it appears, and whether answering is required before anything else.
- **Progress view.** Notion charts each exercise's ideal load over time. What Auburn shows.

## Findings

- **Reps were dropped in practice.** 30 of 850 sets carry a rep count, none since August 2026.
- **Built, then abandoned:** fixed splits and previous/next links (unused since May 2026), drop-set notation, intended reps, ignore-tracking, and activity counts. Each is structure that did not earn its place.
- **AMAP moved from goal to exercise.** Older Notion boards marked whole goals "[AMAP]"; the rule now marks exercises.
- **Notion's goals were two kinds.** Seven were muscle groups trained on a cycle; four were achievements — "Master bodyweight pull up", "Master weighted hinge movement", "Master weighted squat movement", "Level the quad imbalance" — with no more than one exercise each. Holding both in one record is what made rest depend on the gym.

## Dependencies

- **Requires:** none.
- **Required by:** the Data Model.
