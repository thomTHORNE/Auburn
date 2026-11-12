# Ideas

A running list of ideas worth revisiting. Nothing here is committed to the spec — these are possibilities, not decisions.

An idea that outgrows this file is promoted to `Research/`, where it is developed in parallel to the spec. Promoted ideas are removed from here — their frozen originals live beside the document they seeded, as `Origin.md`. See [CLAUDE.md](CLAUDE.md) for the research conventions.

The [v0 exclusions](Spec/Scope.md#excluded) are a different thing: those are exclusions that make v0 finishable, and most of them should stay excluded. An entry appears here only when there is a reason to think it might not.

Each entry states the idea, why it is parked rather than settled, and the condition that would bring it back.

---

## Weekly cap

A ceiling on how often a goal is trained in a week — no more than three runs, say. Rest and the overdue limit bound training from below; a cap would bound it from above.

Parked because per-goal rest bands already keep cardio spaced out, and a cap is a second kind of rule with its own interactions with rest.

Worth revisiting if rest bands alone let a goal be trained more often in a week than the body handles.

## Heart rate for gym workouts

The Suunto watch records strength sessions with heart rate, and intervals.icu serves them as FIT files the same way it serves runs. A 48-minute session carried 2,895 heart-rate samples. Auburn could attach that record to the workout logged in the app.

Parked because v0 reads only runs, treadmill sessions, and hikes, and what heart rate would add beside graded sets is not yet understood.

Worth revisiting if heart rate during a workout would change how rest or a grade is read, or if a treadmill session done during a workout should show inside it: both read the same watch data, matched to the workout by time.

## A run's route

The FIT file of a run or hike carries the watch's GPS track. Auburn could draw it on the activity, as a line in its own palette or over a map.

Parked because v0 keeps only basic data for each activity.

Worth revisiting once cardio has a screen of its own and what it lists is decided.

## Phases

A stretch of training lived under a circumstance of its own — a cut, a bulk, an injury, a running block, a busy quarter — stated so that progress across it reads with its reason. A strength drop in a cut is what the cut expected; the log shows the drop either way, and only the phase says why. Training facts alone cannot tell a cut from an illness, poor sleep, or overreaching: only the user's word, or body weight, can.

Parked because no phase has been committed to in practice, and a phase cannot yet be defined in simple terms.

Worth revisiting if a stretch of training is planned around a circumstance, or if progress across one is misread without its reason — above all a goal's method followed and failed, later traced to a circumstance. Calories and body weight would make a diet phase provable. The cheapest form is Auburn asking why when many exercises drop at once, as it does for an overdue muscle group, and keeping the answer.

## Calories and body weight

Auburn could hold calories eaten and body weight, entered by hand or read from intervals.icu, whose wellness record has a field for each. With them a phase stops being only the user's word: a cut states a deficit and a falling weight, and the facts show whether it happened. A goal's method followed and failed during a cut could then be read for what it was.

Parked because v0 reads neither, and phases are parked with it. Which apps fill intervals.icu's calories field is not yet known.

Worth revisiting together with Phases.

## The overdue log

When a muscle falls overdue, Auburn could ask why it was not trained and keep the answer in a log, so slack is seen rather than forgotten. A prompt that cannot be dismissed, and blocks the next workout until it is answered.

Parked because overdue now reads against a rhythm that is still on trust, and a blocking prompt would turn every misreading into an interruption. In Notion, overdue pulled training back without asking anything.

Worth revisiting if slack goes unseen once rest is in use.

## AMAP

An exercise could be marked "as much as possible": it works its muscles but resets none of their rest, so low-effort work never keeps a muscle reading fresh.

Parked because a muscle trained day after day shortens its own rhythm, which may already be what AMAP was for, and an exercise with no main mover resets nothing.

Worth revisiting if low-effort work keeps a muscle reading rested when it is not.

## Calendar

A calendar of hypertrophy training, in day, week and month views. Past days hold the workouts done on them. Future days hold the forecast: the day each muscle group reaches Should, and the day it reaches Overdue, if it is not trained before then. Rest is the fact; the calendar reads it across time, what was done beside what is coming.

The forecast is derived and never edited on the calendar. It changes only through its source, a muscle group's steps set by hand, so the only way to know what is coming is to trust the rhythm and keep to it. A forecast day that passes untrained is gone: nothing was prescribed, so nothing is missed.

Parked because what a future day carries is not settled. The facts sit on muscle groups, and twenty of them across a month crowd the screen. Routines are what a workout is started from and would read cleanly, but a routine keeps no rest of its own, and putting one on a day schedules it.

Worth revisiting when past workouts are designed, since a calendar is one form they could take, or if planning training around the week needs more than the rest list shows.

## Notifications

Auburn could tell the user, without the app open, when a muscle group's rest reaches Should or Overdue.

Parked because the calendar is only a view for now, and a notification is the nearest thing to asking. Overdue asks nothing; a notification at Overdue still pushes, and where that line falls is not settled.

Worth revisiting together with the Calendar, or if a muscle group falls overdue unnoticed because the app went unopened.

## Sessions per week

The user could state how many sessions a week they train, and the forecast would read across the week from it: which days, and what has rested by each. Rest alone keeps the forecast one session ahead; a count would let it plan the week.

Parked because it is the strongest step toward a plan that decides the day, and the calendar beneath it is not settled. It is the counterpart of the weekly cap: the cap bounds training from above, a count sets it.

Worth revisiting once the Calendar is, if one session ahead proves too short to plan a week around.
