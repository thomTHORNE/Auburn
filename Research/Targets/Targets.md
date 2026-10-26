Status: Promoted

Landed in Foundation and Spec/Features. This document is no longer the reference.

# Targets

Whether a goal states what reaching it looks like, and how Auburn shows the way there. Seeded by [Origin](Origin.md).

## Settled

- **A target is the user's.** Auburn shows how the facts move against it and never judges whether it is right.
- **Every goal has a target, and the facts prove it.** A goal is reached only by a fact that meets its target's ruleset; nothing is reached by being marked.
- **A target is a ruleset the user writes:** an exercise or activity kind, a parameter, a value, and the conditions a fact must meet to count — for a set, the grades that count. Auburn defines none of them. A set and an imported activity are facts alike.
- **A goal may have steps before its final target**, each a target of its own. The user chooses whether it has any.
- **A goal is a draft, then active, then reached or abandoned.** Everything in a goal can change while it is a draft. Once active it is locked, its exercises aside, and it ends only by being reached or abandoned. It cannot be paused.
- **An active goal's exercises can still change.** What serves a skill is learned along the way.
- **A reached goal is frozen** as a permanent record. Reaching it asks the user how to proceed. A new target for the same skill is a new goal, which may start as a copy of the old one.
- **Auburn marks a target reached** on the first fact that meets its ruleset. The mark can be undone, and the target then waits for the next fact that meets it.
- **A frozen goal shows its progress up to the day it ended**, reached or abandoned. An abandoned goal is frozen like a reached one.
- **A goal made from another keeps a link to it.**
- **Auburn says, when a goal is made active, that nothing in it but its exercises can change after.**
- **A goal's steps may sit on any of its exercises.**
- **The way there shows as the gap** between a goal's progress and its target. No direction is shown; the line already shows it.
- **A goal keeps its active date and its end date.** It is created as a draft and made active later. How long it took runs from the day it became active to the day it was reached or abandoned.
- **A step keeps the day it was reached.** Its time runs from the day the step before it was reached, or from the goal's active date for the first step.
- **Abandoning a goal asks why**, and the answer is kept on the goal.
- **One exercise proves a target; the others support it.** The target's ruleset names the exercise or activity kind whose facts can reach it. A goal's other exercises work toward it without proving it.
- **An active goal keeps the exercises its target and steps sit on.** Its supporting exercises can be added and removed.

## Open questions

None.

## Findings

- **A target is not committed to while it cannot be trusted.** The user has never set one, because nothing showed whether it was reachable.
- **A circumstance can bend a rate.** A cut flattens every line; a rate measured across one misleads unless its reason is known.
- **The Goals spec sets no target, deadline, or reached state.** Reopening it rests on the first finding, which was not known when that was decided.
- **A reps target needs the grade.** Progress's reps point is the most reps on any set, whatever its grade, so a target set on it alone would be crossed by a sloppy set.
- **The roll paces a reps target's evidence.** Reps exist only on counted sets, about one commit in three, and a roll cannot be re-rolled.
- **An imbalance is proven through an exercise of its own.** Levelling the left leg is a goal whose target sits on an exercise done with the left leg only. Nothing new is needed.
- **A target is proven by one exercise or one activity kind, never several.** A run and a treadmill session could both prove "4 km under 20 minutes", but letting several sources share a target needs too many rules about when they are equal. It is not supported.

## Dependencies

- **Requires:** none.
- **Required by:** none.
