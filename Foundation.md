# Foundation

This document is the reason Auburn is shaped the way it is. The design principles, the features, and the technical decisions all answer to it. Where another document disagrees with this one, this one holds and the other is the defect.

---

## Premise

Auburn is a personal fitness training app, built around how its user actually trains.

Most of what the fitness apps on the market do applies. Auburn does not reinvent the parts that already work. It departs from them only where the way its user trains and approaches training departs from what those apps assume, and each departure is stated here with the reason for it.

Auburn is released to others as it is. It does not adapt to the way another person trains: it is for whoever trains this way.

---

## Training

The goal is lifelong: to get stronger, stay mobile, and keep good endurance with age. Each kind of training has its own job:

- **Hypertrophy training** builds muscle and, with it, strength.
- **Mobility work** addresses weaknesses — see [Weaknesses](#weaknesses).
- **Cardio** keeps the body healthy overall and supports a healthy way of living.

Which exercises are done, and when in a year, changes with life circumstances. Auburn follows that change. It never groups the three kinds of training into phases of their own, and it adds structure only where the structure brings a direct benefit.

Training happens on the gym floor. Auburn is used between sets, in one hand, with attention on the body.

---

## The problem

The apps on the market assume training is planned in advance and measured by counting. A programme says what today is; a set is weight times reps; progress is a number going up.

That fits a routine. It does not fit training chosen each day from what has rested and how the body feels, where a set is worth the control it was done with, and where the way an exercise is done changes on purpose. Used for that, such an app demands data that is not the measure — reps typed in for a set judged by feel — and offers structure that goes unused. The Notion system that came before Auburn shows both: rep counts were dropped in practice, and fixed splits were built and then abandoned.

---

## Pillars

Each pillar is one departure from the market's defaults: what Auburn does instead, why, and what it refuses to do. The pillars below are not yet the complete set.

### Rest and feel choose the training

What is trained on a given day is chosen from two things: how long each muscle group has rested, and how the body feels. Auburn shows the first. The user brings the second, and decides.

Rest has a limit. When a muscle group rests past it, Auburn asks why it was not trained and keeps the answer in a log of its own, so slack is seen rather than forgotten.

Auburn never prescribes the day's training.

### A set is graded by feel

A set is recorded as its load and a grade of how it went — the control and form it was done with — not as a count. Learning to read the body this way has proven worth more than rep counts, and it lowers the risk of injury. Counting is still a tool, and it is used when the modality calls for it.

Auburn never requires a rep count to log a set.

### Muscles set the pace

Rest is kept per muscle group, from a standard list. A muscle is worked wherever training happens, by whichever exercise works it, so its rest counts the days since any exercise worked it, at any gym. Each exercise names the muscle groups it trains, and those are the rests it resets.

Every muscle group is owed. A group appears once an exercise resets it, and an AMAP exercise resets none, so no group can be held only by work that never lets it fall due.

### A goal says why

A goal is something to reach: a movement mastered, an imbalance levelled, a time run. It holds the user's own explanation of what it is for and how it is meant to be achieved, and the exercises that work toward it. A goal is never owed. It shows the gap to its target, not rest.

Its target says what reaching it looks like, in the user's own rules, and only the facts prove it: a goal is reached by a set or an activity, never by being marked. A target committed to cannot be trusted unless it holds, so once a goal is active its target does not move. The goal is reached or abandoned, never paused, and an abandoned goal keeps the reason why.

Auburn never sets a target, and never moves one.

### Variety on purpose

A fixed routine goes stale and leaves gaps. Every workout starts with the modality roll on: each exercise committed to it gets a rolled modality — slow and controlled, reps counted to test strength, or by feel. Training stays fresh, experimenting is built in, and the counted sets give a measured check on progress. With the roll off, every exercise is done by feel.

A roll is never re-rolled.

### Each exercise keeps its own notes

Observations, settings, and form notes belong to the exercise. They are in front of the user each time it is done, and editable on the spot.

Auburn never hides an exercise's notes while it is being done.

### Weaknesses

Some of what training has to address is specific: a weakness found in your own body, such as weak motor recruitment through one leg and its hip. A weakness is a goal the user names: what it is, how it is meant to be levelled, and the exercises that work it.

Auburn never names or diagnoses a weakness. Weaknesses are found by the user.

---

## Two realms

Auburn exists in two realms.

In reality, it is the training app this document describes. A user who wants only that gets only that.

In fiction, Auburn is a corporation that commercialises humanity. It sells a way of living that distances people from themselves and turns them into a loyal, dependent consumer base, and the body and the identity are its product. Its culture is warm on the surface and turns uncanny through its practices, its rules of behaviour, and its language. Its slogan is "Introducing, the new You."

The fictional Auburn is what the real one refuses to be. The corporation prescribes the day; Auburn never does. The corporation sets the targets; Auburn never sets one. The corporation names what is wrong with you; Auburn never names a weakness. The corporation sells a new You; Auburn is built on reading the one you have. Every rule the user holds themselves to, the corporation claims as its own policy, and the user who notices sees whose discipline it was.

The fiction changes what Auburn says, never what Auburn does. Every behaviour follows this document; the corporation only narrates it.

---

## Terms

- **Muscle group** — a part of the body rest is kept for, from a standard list: chest, front delts, side delts, rear delts, biceps, triceps, forearms, lats, upper back, traps, lower back, abs, obliques, quads, hamstrings, glutes, calves, adductors, abductors, neck. Cardio rests the same way, reset by runs, treadmill sessions, and hikes from the watch.
- **Goal** — something to reach: the user's explanation of what it is and how it is achieved, its target, and the exercises that work toward it.
- **Target** — what reaching a goal looks like: a value on one exercise's sets or one kind of activity, under the user's own rules. Steps are targets on the way to the final one.
- **Exercise** — a movement, on specific equipment where it uses any. Works one or more muscle groups, may serve goals, may name alternates, and may be tied to the gyms it is done at. A mobility exercise works no muscle group and serves no goal.
- **Alternate** — an exercise named on another as its stand-in, used when that one's equipment is taken.
- **Workout** — one visit to train at a gym: the exercises committed to it, in order, and their sets. Titled by its date and gym. A workout is hypertrophy or mobility, never both.
- **Gym** — where a workout happens, home included. Gyms differ in equipment: an exercise tied to a gym is that gym's version of the lift, and one tied to none is the same everywhere.
- **Split** — an optional grouping of muscle groups, such as Upper or Leg Day.
- **Commit** — adding an exercise to the current workout. When the workout's roll is on, its modality is rolled at that moment.
- **Modality** — how an exercise is done in a workout: slow and controlled, counted, or by feel.
- **Set** — a load and a grade, plus reps when the modality counts them. Mobility exercises have no sets.
- **Grade** — how a set went, read by feel. A mobility exercise carries its own optional grade: controlled, improved, or poor.
  - *Ideal:* heavy, taken to failure with control, within a hypertrophy rep range.
  - *Acceptable:* close to ideal with clearly fewer reps, or form held at the edge of breaking.
  - *Light:* too easy to count toward progress, though it still works the muscle.
  - *Yielding:* form and control lost; the load is not tried again until enough ideal sets come first.
  - *Warmup:* preparation before the work; it works nothing.
- **Rest** — the days since a muscle group was last worked by an exercise that resets it, at any gym; for cardio, since the last activity from the watch.
- **AMAP** — "as much as possible": an exercise that resets no muscle group's rest. Usually low-fatigue isolation work; heavy compounds always reset.
- **Overdue** — a muscle group, or cardio, that has rested into its last band. Each carries its own limit.
