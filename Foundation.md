# Foundation

This document is the reason Auburn is shaped the way it is. The design principles, the features, and the technical decisions all answer to it. Where another document disagrees with this one, this one holds and the other is the defect.

---

## Premise

Auburn is a personal fitness training app, built around how its user actually trains.

Most of what the fitness apps on the market do applies. Auburn does not reinvent the parts that already work. It departs from them only where the way its user trains and approaches training departs from what those apps assume, and each departure is stated here with the reason for it.

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

What is trained on a given day is chosen from two things: how long each goal has rested, and how the body feels. Auburn shows the first. The user brings the second, and decides.

Rest has a limit. When a goal rests past it, Auburn asks why it was not trained and keeps the answer in a log of its own, so slack is seen rather than forgotten.

Auburn never prescribes the day's training.

### A set is graded by feel

A set is recorded as its load and a grade of how it went — the control and form it was done with — not as a count. Learning to read the body this way has proven worth more than rep counts, and it lowers the risk of injury. Counting is still a tool, and it is used when the modality calls for it.

Auburn never requires a rep count to log a set.

### The goal is the unit

A goal says why. It holds the user's own explanation of what it is for and how it is meant to be achieved, and the exercises that serve it — primary and alternates. Its rest decides when it is trained again. An exercise is seen through the goal it serves.

Every goal is owed. A goal always holds at least one exercise that resets its rest. A goal of only AMAP exercises could never fall due, and Auburn does not allow that escape.

### Variety on purpose

A fixed routine goes stale and leaves gaps. A workout can switch on the modality roll: each exercise committed to it then gets a rolled modality — slow and controlled, reps counted to test strength, or by feel. Training stays fresh, experimenting is built in, and the counted sets give a measured check on progress. With the roll off, every exercise is done by feel.

A roll is never re-rolled.

### Each exercise keeps its own notes

Observations, settings, and form notes belong to the exercise. They are in front of the user each time it is done, and editable on the spot.

Auburn never hides an exercise's notes while it is being done.

### Weaknesses

Some of what training has to address is specific: a weakness found in your own body, such as weak motor recruitment through one leg and its hip. Auburn gives weaknesses a space of their own, where each is named and targeted.

Auburn never names or diagnoses a weakness. Weaknesses are found by the user.

---

## Terms

- **Goal** — a purpose in training: the user's explanation of what it is and how it is achieved, and the exercises that serve it.
- **Exercise** — a movement on specific equipment. Belongs to one or more goals, and optionally to the gyms it is done at.
- **Workout** — one visit to train at a gym: the exercises committed to it, in order, and their sets. Titled by its date and gym.
- **Gym** — where a workout happens, home included. Gyms differ in equipment: an exercise tied to a gym is that gym's version of the lift, and one tied to none is the same everywhere.
- **Split** — an optional grouping of goals, such as Upper, Leg Day, or Stim.
- **Commit** — adding an exercise to the current workout. When the workout's roll is on, its modality is rolled at that moment.
- **Modality** — how an exercise is done in a workout: slow and controlled, counted, or by feel.
- **Set** — a load and a grade, plus reps when the modality counts them.
- **Grade** — how a set went, read by feel.
  - *Ideal:* heavy, taken to failure with control, within a hypertrophy rep range.
  - *Acceptable:* close to ideal with clearly fewer reps, or form held at the edge of breaking.
  - *Light:* too easy to count as work.
  - *Yielding:* form and control lost; the load is not tried again until enough ideal sets come first.
  - *Warmup.*
- **Rest** — the days since a goal was last trained by an exercise that resets it.
- **AMAP** — "as much as possible": an exercise that never resets a goal's rest. Usually low-fatigue isolation work; heavy compounds always reset.
- **Overdue** — a goal that has rested past its own limit. Each goal carries its limit.
