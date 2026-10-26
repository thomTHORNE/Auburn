# Ideas

A running list of ideas worth revisiting. Nothing here is committed to the spec — these are possibilities, not decisions.

An idea that outgrows this file is promoted to `Research/`, where it is developed in parallel to the spec. Promoted ideas are removed from here — their frozen originals live beside the document they seeded, as `Origin.md`. See [CLAUDE.md](CLAUDE.md) for the research conventions.

The [v1 exclusions](Spec/Scope.md#excluded) are a different thing: those are exclusions that make v1 finishable, and most of them should stay excluded. An entry appears here only when there is a reason to think it might not.

Each entry states the idea, why it is parked rather than settled, and the condition that would bring it back.

---

## Weekly cap

A ceiling on how often a goal is trained in a week — no more than three runs, say. Rest and the overdue limit bound training from below; a cap would bound it from above.

Parked because per-goal rest bands already keep cardio spaced out, and a cap is a second kind of rule with its own interactions with rest.

Worth revisiting if rest bands alone let a goal be trained more often in a week than the body handles.

## Heart rate for gym workouts

The Suunto watch records strength sessions with heart rate, and intervals.icu serves them as FIT files the same way it serves runs. A 48-minute session carried 2,895 heart-rate samples. Auburn could attach that record to the workout logged in the app.

Parked because v1 reads only runs, treadmill sessions, and hikes, and what heart rate would add beside graded sets is not yet understood.

Worth revisiting if heart rate during a workout would change how rest or a grade is read.

## A run's route

The FIT file of a run or hike carries the watch's GPS track. Auburn could draw it on the activity, as a line in its own palette or over a map.

Parked because v1 keeps only basic data for each activity.

Worth revisiting once cardio has a screen of its own and what it lists is decided.

## Phases

A stretch of training lived under a circumstance of its own — a cut, a bulk, an injury, a running block, a busy quarter — stated so that progress across it reads with its reason. A strength drop in a cut is what the cut expected; the log shows the drop either way, and only the phase says why. Training facts alone cannot tell a cut from an illness, poor sleep, or overreaching: only the user's word, or body weight, can.

Parked because no phase has been committed to in practice, and a phase cannot yet be defined in simple terms.

Worth revisiting if a stretch of training is planned around a circumstance, or if progress across one is misread without its reason. The cheapest form is Auburn asking why when many exercises drop at once, as it does for an overdue muscle group, and keeping the answer.
