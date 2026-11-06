Status: Open

# Routines

A template for a workout, planned in advance, that a workout is started from, so the gym is for execution. Seeded by [Origin](Origin.md).

## Why

- **Planning at downtime, focus at the gym.** A routine is where the user works out how to train around their life; at the gym they pick it and execute, without deliberating.
- **Exercises and goals grouped for one workout.** Without routines, every workout starts from the full list of exercises and goals, searched and scrolled each time.
- **A place for the urge to organise.** Grouping training as Push, Pull, Legs or Upper, Lower is legitimate, and it needs a home that is not a goal.

## Settled

- **A routine is a fixed plan the user makes in advance**, a template a workout starts from. The workout it starts is recorded like any other.
- **A routine holds exercises and goals.** A goal brings its exercises, and a goal can sit in any number of routines.
- **A workout started from a routine still takes exercises that are not in it.**
- **There is no limit to how many routines exist.**
- **A routine stands alone or belongs to one named group,** such as Push, Pull and Legs. Grouped routines are shown together, apart from standalone ones.
- **Routines are picked when a workout starts and edited on a screen of their own,** never in the start flow.
- **A routine is tied to gyms or to none, as an exercise is.** A tied routine is offered only at its gyms; an untied one is offered everywhere. A tied routine holds only exercises available at one of its gyms.
- **A goal whose target sits on an exercise joins a tied routine only if that exercise is available at one of the routine's gyms.** A goal whose target's exercise belongs to another gym cannot be proven there.
- **A goal whose target sits on an activity kind can sit in any routine.** It brings only its supporting exercises; the activity that proves it arrives from the watch. Its supporting exercises follow the gym like any others.
- **A routine holds a goal, never a copy of its exercises.** The goal's exercises are read when the workout starts, so an active goal's supporting exercises can change without the routine being edited.
- **A workout started from a routine offers the routine's exercises available at its gym.** An exercise tied to another gym is replaced by its alternate available here, or left out.
  This holds for the exercises a goal brings: a supporting exercise tied to another gym gives way to its alternate, or is left out, and the goal stays.
- **A goal whose target's exercise is no longer available at a tied routine's gyms** is shown on the routine's edit screen as not provable there, and its target's exercise is left out when a workout starts.
- **A routine holds its exercises and goals in order, and nothing more about them.** No sets, reps, load, or way of doing an exercise: sets wait on programming, how an exercise is done waits on tests, and reps and load would prescribe the set.
- **A goal in a routine stays a goal.** It is shown in the routine as itself, never dissolved into or replaced by its exercises: the meaning it gives them is the reason it is there. Its exercises come with it, at its place in the order, in whatever order the goal holds them; a goal has no order of its own, and the routine applies what the goal brings.
- **Starting a workout from a routine offers its exercises; it commits none of them.** Whether to commit any of them is the user's choice. They are committed as they are done, so commit order records what happened, and an exercise skipped leaves nothing behind. The offered list shows which have been committed. A workout's other exercises can still be committed at any time.
- **Auburn never suggests which routine is next, and never schedules one.** Foundation's refusal to prescribe the day's training holds: the user picks, from rest and feel.

## Use cases

1. **Training organised around a life** — push, pull, legs; upper and lower; full body. Legitimate and allowed: a short list of routines is the cheapest way to reach what the user came to train.
2. **Routines that belong together, set apart** — Push, Pull and Legs as one group, Full body on its own. Legitimate and allowed: grouping keeps a long list readable.
3. **Organising with a goal instead** — an "Isolations" goal holding every arm exercise. Tolerated and superseded: a goal needs a target its one exercise proves, so a grouping of unrelated exercises makes a poor goal. Routines are where this belongs.
4. **A running goal's strength work, inside a gym routine** — "4 km under 20 minutes", supported by calf raises and step-ups, sits in Leg day. Legitimate and allowed: the routine shows which of its exercises serve the run.

## Open questions

- **Kind.** Whether a routine is hypertrophy or mobility, as a workout is.
- **How a goal's exercises are reached in a routine.** In the routine's own list beneath the goal, or one step away through it. Decided with the screen.
- **The group's name.** "Split" already names a grouping of muscle groups for rest at a glance, which is to be researched again.
- **Foundation.** "The problem" argues against planning in advance and records fixed splits as abandoned; "Variety on purpose" says a fixed routine goes stale. Both are reworded before routines promote.

## Findings

- **Splits failed in Notion because goals and exercises could not be shown together.** A split there was a list searched each time. Auburn can show both, which removes the friction, not the plan.
- **Supporting and alternate exercises in a goal act the same.** Only the intent differs, and intent belongs in the goal's explanation.
- **A routine holds no activity, and a workout never records one.** A treadmill session done during a gym visit arrives from the watch as an activity of its own; a treadmill goal in the routine is the only link between them.

## Dependencies

- **Requires:** none. The group's name waits on rest at a glance being researched again.
- **Required by:** none.
