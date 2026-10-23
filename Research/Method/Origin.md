# Origin

The user's training method as it ran in Notion before Auburn, recorded 2026-10-23. Frozen.

Source: the Training '26 page — https://app.notion.com/p/quantum-singularity/Training-26-2bbe106556988029a4f7ff630ff2c611 — read through the Notion connector, together with screenshots the user shared and the user's own explanations.

Part one is the read-back of the page, with the rest colours corrected against the formula the user provided. Part two is the user's explanations, verbatim.

---

## Part one — Read-back of Training '26

### Structure

```
Goals ──< Exercises >── Sets >── Workouts
  │           │                    │
  rest gauge  notes: Observations, │ template tabs: Upper · Leg Day · Stim
  & colour    Settings, Form       │   (goal boards grouped by meantime)
              Commit → today's     │ + Mobility routine + Sets of this workout
              workout              │
```

**Principles** — "Consistent · Simple · Stimulating". A set ends at the last rep with acceptable form: Ideal is controlled form within the hypertrophy rep range; Acceptable is controlled form with fewer reps. Sets per muscle group follow recovery time and the systemic fatigue an exercise costs. Needing a full rest week every 6 weeks signals that sets per workout are too high.

**Goals (11).** A goal answers "why do this exercise?" and should carry its own mental model and instructions for its linked exercises, reducing decisions on the spot. Each goal links exercises, carries a modality (Upper, Leg Day, Stim) and a split (Upper, Lower, Full Body, Gym Gap: Cardio, Home Gap: Full Body), and shows its latest workout and a rest gauge.

**The rest gauge.** Rest is the number of days since the latest set of any exercise in the goal. The gauge fills one block per day up to seven, followed by the most recently trained exercise, coloured by rest:

| Days | Colour | State |
|---|---|---|
| ≤ 2 | red | Repair |
| 3 | blue | Maybe train |
| 4 | green | Train |
| ≥ 5 | orange | Train |

The board columns in a workout (`4 to 5`, `6 to 7`, `Out of range`) are Notion's number ranges on `meantime`, separate from the colours.

**Decision making.** Train: a combination of must-train and AMAP goals, and feeling optimal. Maybe train: the major groups' rest is blue, and feeling suboptimal. Repair: all rest is red.

**Workouts (104, from December 2025).** Created from a template, started with a Start button; duration runs from the start. Each links its exercises and sets. The template's tabs show the goals by modality, and a Mobility tab holding a fixed routine — stretching, lunge stretch, a single-leg balance chain, Cossack squat, squat — under the method "fluid and stable motion, different to pushing reps to failure." Mobility days are logged as workouts without sets.

**Exercises (35).** Named "Movement : equipment" — `Shrug : db`, `Bicep Curl : preacher~db`. Each page holds Observations, Settings ("Bench height: 75"), and Form notes, a Commit button that ties the exercise to today's workout, an Add Set button, and its past sets grouped by workout. Running, Skiing, and Cycling are exercises too.

**Sets (850).** `Kg-Km` holds load in kilograms, or distance in kilometres for cardio. `Rps-Min` holds reps, or minutes for cardio. `Grade` is one of Warmup, Light, Ideal, Acceptable, Yielding. A chart plots the average "1RM" per exercise per day over Ideal sets; with reps blank, the plotted values match the working loads.

### What the data showed

- Reps were recorded on 30 of 850 sets, the last on 6 August 2026.
- The split, previous, and next fields on workouts were empty on every workout since May 2026.
- `Match` was never filled in.
- `!` in `Kg-Km` appeared 7 times, the last in January 2026.

---

## Part two — The user's explanations

### Opening the example

> Before I start explaining in detail, let's try a working practical example.
> I track my workouts in notion where I have a training page with an established relationships between multiple tables and also have functions that display useful information. Some part of the complete flow how i use this page can't be expressed just by looking at the established page so that's where I can fill in the gaps.

### The rest gauge, grades, and the rest of the system

> * The `meantime_display` that appears on a goal card in a workout on a given day:
>
> ```
> let(
>   /* 1. Sort the exercises by their timestamp from oldest to newest */
>   SORTED_LIST, 
>   prop("db.Training’26.Exercises ")
>     .filter(!empty(current.prop("latest_set_date")))
>     .sort(current.prop("latest_set_date").timestamp()),
>
>   /* 2. Grab the very last item in that sorted list */
>   LATEST_ENTRY, SORTED_LIST.last(),
>
>   /* 1. Calculate the latest date */
>   LATEST_DATE, prop("db.Training’26.Exercises ").map(current.prop("latest_set_date").timestamp()).filter(!empty(current)).max().fromTimestamp(),
>   
>   /* 2. Calculate the difference in days */
>   DAYS, dateBetween(now(), LATEST_DATE, "days"),
>   
>   /* 3. Color map */
>   BAR_COLOR, ifs(
>     DAYS <= 2, "red",
>     DAYS == 3, "blue",
>     DAYS == 4, "green",
>     DAYS >= 5, "orange"
>   ),
>
>   /* 4. Create the visual bar (Max 7 segments) */
>   /* Replaces filled squares with empty ones based on day count */
>   BAR, repeat("🀫 ", min(DAYS, 7)).style(BAR_COLOR, "b", "i") + repeat("🀆 ", max(7 - DAYS, 0)).style("red", "i"),
>
>   /* 5. Final Output Display */
> 		if(
> 		[""].includes(prop("Name")),
> 		"[ AMAP ] ".style("b", "i", "grey"),
> 		""
> 	) +
> 	BAR + 
> 	" " + 
> 	LATEST_ENTRY.style(BAR_COLOR, "b", "I")
> )
> ```
>
> * "Must train" and AMAP (as much as possible) act as a guide for when it's ok to train the same goal (usually targets a muscle group, compound or isolation). The 3 levels by color (orange, green, blue, red) are a visual aid instead of text that tells me when I can act on something again. A Grade in sets acts much in the same way, where it goes by the "feel" instead of a pseudo-science metric. Getting to know my body, how to interpret a feeling of how much control I can express in an exercise or otherwise is information that has proven to be more valuable to me than rep counts, and also a way to reduce injuries. In the end though, grades are just a tool just like counting reps is. 
> * Adding to the previous point, I intend to implement a feature that would randomize the method/technique of executing an exercise when committing to it. Just as a visual example, when committing to a   chest incline bar, I'd role  the dice on the technique: hypertrophy to failure ending the set when knowing i couldn't perform another rep or would be losing control and form, or deliberate very slow very controlled reps with maybe a lower weight, or a classic hypertrophy approach that would test strength  to failure but with counting reps so that i have an empirical data if I'm actually progressing. All these are meant to keep training feel fresh and to promote experimentation and to fill in the gaps that a hard unchanging routine could create.
> * Grades: 
>    * yielding: loss of form and control, a set that is too heavy and should not try again next time until an unspecified occurrences of  ideal sets are performed
>    * light: a set that was too easy and felt like not working out
>    * ideal: a real heavy set that i was able to perform to failure with control and within a hypertrophy rep count spectrum
>    * acceptable: a set that has been done mostly in line with ideal but with significantly less rep count,  also my personal intuition and interpretation of body feeling feeds into this grade that might tell me that my form  was about to break but i did pull through still
>    * I abandoned odd values, the "!" was my way of writing a drop in weights potentially multiple  times in a single set
>    * Match was supposed to be used to write what rep count I intended to reach while rps-min is the actual count i achieved
>    * ignore_tracking is abandoned
>    * Modality is a wip term. I think it's interchangeable with a split grouping,  just a basic grouping. The true informational unit is each goal where it groups primary and alternate exercises that all work to achieve a related goal. Ideally each exercise when looked through the lens of a goal would have a different approach or method, but I never got around to implementing that in notion.
>    * Iva Gyma is my tag to differentiate the gym in my hometown with different equipment than the one I have where I'm currently living that is a different gym with different equipment.
>    * The activity count lost importance, it was a visual aid to see which exercise i actually executed not just ones that I think i executed.

### The departures and the rest rule

> -13- 
>
> 1. yes, but i would add that after a deadline (more than the defined allowed days for rest) a required log is presented to me in which is must explain why i didn't train that day. That log should be triggered whenever there is an overdue  exercise and doesn't need to be related to any specific entity, it can only be a standalone log tracker that i can look at to understand how much i've been slacking.
> 2. yes, set is graded by feel not counted is the foundational way i approach hypertrophy training and heavy weights. However, i mention this again, i want to have modalities in my technique, so a randomizer on spot that will state if i will for a given exercise in a workout do it slow and controlled, count the reps to test my strength or do it simply by feel.
> 3. yes and it should also hold an explainer on what that goal is and how i intend to achieve it
> 4. yes
> 5. yes
>
> -15- i'd pick a third option that would apply the AMAP rule, where if an exercise marked as AMAP is in a goal then that exercise does not reset the goal. These would most often be less CNS fatigue exercises like isolations, while heavy compounds will most certainly do affect a goal and reset it
