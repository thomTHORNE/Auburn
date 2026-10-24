# Lab log

Every Lab attempt and where it stands. Conventions are in CLAUDE.md.

Status is one of: parked, running, done, retired. Done means the verdict is in and the code is kept as reference. Retired means product code now covers the same ground and the attempt's code has been deleted; the entry stays.

---

## Suunto via Health Connect

Probe · done

Question: does a Flutter app on the phone read the runs, treadmill sessions, and hikes the Suunto app saved to Health Connect, with distance, duration, and heart rate?
Pass: all three activity types appear with those fields.
Timebox: half a day.
Needs: "Save to Health Connect" turned on in the Suunto app, and a build run on the phone.
Feeds: Research/Suunto, Research/Platforms.
Code: Lab/suunto-health-connect/
Stakes: a fail removes cardio from v1.
Verdict (2026-10-23): fail, without running the probe. The Suunto app does not write to Health Connect: it is absent from the Fold's Health Connect app permissions. A paid relay (Health Sync) exists and is ruled out on cost.
Notes: the code was never run. Kept as reference for reading Health Connect.

---

## Approved screens under the tube

Sketch · running

Question: does each screen brought for approval on the canvas, rebuilt in Flutter, look, read and handle as intended on the Fold under the tube — CRT strength 0.6, glass LOW, travel SMALL — in each of its themes?
Pass: per screen, the layout matches its canvas boards, every text and mark reads through the shader, every control on the screen works in the hand, and the look agrees with the boards.
Timebox: half a day for the app and screen 00; an hour or two for each screen after.
Needs: a build on the Fold.
Feeds: Spec/Visual Design.
Code: Lab/screens-under-tube/
Stakes: a screen that fails goes back to the canvas before it is approved.
Screen 00, boot: pass. Rebuilt from its screen.html, it matches the approved board; the mark, wordmark, and line read through the tube, and the tilt-driven glass runs. At the approved glass LOW the glass is barely visible on the boot; HIGH (1.2) with travel SMALL fits it better.

---

## Sound in the hand

Sketch · running

Question: on the Fold, do the boot, the ambience, and the power-down play as Sound Design specifies — the boot with the boot screen, the ambience looping from the boot's end without a seam, the power-down when it is held full, and all three over other audio without pausing or lowering it — and do they sit right with the screens?
Pass: each sound starts and stops where Sound Design says; the ambience loops with no audible seam or gap; music playing in another app keeps playing at full volume alongside; silent mode and the sound setting mute them; and the sounds feel like part of the screens, not over them.
Timebox: half a day.
Needs: a build on the Fold, earphones and the speaker, and a music app.
Feeds: Spec/Sound Design.
Code: Lab/screens-under-tube/ — shares the screens app, so the sounds play against the real boot and home.
Stakes: a sound that fails goes back to the sound work; a fail on playing over other audio needs a different way of playing sound on Android, noted in Architecture.

---

## Muscle figure regions

Sketch · done

Question: on the Fold cover screen, can the 20 muscle groups, drawn as regions on a front and a back figure, be told apart and tapped one-handed — at full size, or with a predefined zoom on part of the body — both when an exercise lights its groups and when every group is tinted by its rest band?
Pass: every group can be tapped without hitting its neighbour, at full size or zoomed; lit groups are found at a glance; and the rest tint reads without the figure losing its engraved look under the CRT shader.
Timebox: 1–2 days.
Needs: a build on the Fold.
Feeds: Spec/Visual Design, the muscle figure.
Code: Lab/muscle-figure/
Stakes: if small groups (neck, the three delts, obliques, abductors) cannot be tapped even zoomed, they need merged regions for display.
Verdict (2026-10-23): pass, with zoom. Placeholder regions for the 20 muscle groups, front and back, under the CRT and glass shader. An exercise's groups lit in Cyan White are found at a glance. At full size the small groups — the three delts, neck, obliques, abductors — are missed one-handed; zoomed to a predefined section (shoulders, torso, hips, legs) they are hit. The rest tint reads in blue, green, and orange; red is the weakest on the ember plate.
Notes: the tap test scored 6 of 20 with 13 taps zoomed. Most misses came from the test asking for groups outside the zoomed section, since it turned the figure but never changed the zoom. The neighbour misses were rear delts and lats, forearms and triceps, and neck and traps; worth checking again on the traced art. Merged regions are not needed. Code kept as reference.

---

## Suunto via intervals.icu

Probe · done

Question: with a personal intervals.icu API key, does a Flutter app fetch the original FIT files of a run, a treadmill session, and a hike recorded on the Suunto watch, and read distance, duration, and heart rate from each?
Pass: all three activity types arrive as original FIT files and parse with those fields.
Timebox: half a day.
Needs: intervals.icu connected to Suunto; an API key and athlete ID entered on the phone; a build run on the phone.
Feeds: Research/Suunto, Research/Platforms.
Code: Lab/suunto-intervals/
Stakes: if the fetch fails, the fallback is a manual FIT export from the Suunto app. If the files cannot be parsed, cardio leaves v1.
Verdict (2026-10-23): pass. A Flutter app with a personal intervals.icu API key lists the athlete's activities and downloads each one's original FIT file. A run, a treadmill session, and a hike each parsed with distance, duration, and heart rate, from 1,261 to 9,264 heart-rate samples per activity. The FIT file's own sub-sport marks treadmill sessions; intervals.icu calls them VirtualRun.
Notes: fit_tool 1.0.5 throws on sport values newer than its profile. One activity carried value 64, which stopped the run after seven files. Product code needs a parser that tolerates unknown values. The athlete id worked with its "i" prefix. Code kept as reference.

---

## CRT shader over Flutter

Probe · done

Question: can Flutter run a custom fragment shader over the whole rendered screen on the Fold 8 — curvature, chromatic aberration, scanlines, bloom, glass halo, and smudges — while taps still answer within one frame?
Pass: the shader runs over live widgets at the screen's full refresh rate, and a tap's visual response is no slower than without it.
Timebox: half a day.
Needs: a build run on the Fold.
Feeds: Research/Platforms, Spec/Visual Design.
Code: Lab/crt-shader/
Stakes: a fail limits the CRT look to static texture layers.
Verdict (2026-10-23): pass. The full CRT shader runs over the whole screen on the Fold 8 cover screen at 120 Hz: 117–119 fps, frames at 6.8 ms typical and 7.9 ms worst 5%, inside the 8.3 ms budget and about a millisecond above no shader at all. Taps felt instant in every mode. The look was most appealing at strength 0.6 and 1.0.
Notes: the fallback path (AnimatedSampler) was not needed and runs at half speed. With nothing animated, the first frame after an idle pause can take up to 19 ms — below what was felt. The probe's own tap timer did not work; feel stood in for it. Code kept as reference.

---

## Glass that moves

Sketch · done

Question: does a halo and smudge layer that shifts with the phone's tilt read as real glass over the screen, without crossing the values and keys it must not obscure?
Pass: in use at the gym, the glass reads as physical, and no value or key is ever harder to read because of where the halo has moved.
Timebox: 1–2 days.
Needs: a passing CRT shader probe; a build on the Fold.
Feeds: Spec/Visual Design.
Code: Lab/glass-that-moves/
Verdict (2026-10-23): pass. A glass layer driven by the phone's tilt reads as real glass over the screen, and its motion feels fluid and instant. The light moves on the glass; the oily film, swipe streaks, and dust stay fixed and show where the light catches them. The best look was glass LOW, travel SMALL, CRT strength 0.6, with frames at 5.2 ms worst 5%, inside the 8.3 ms budget. At those settings no value or key was harder to read.
Notes: the first texture was blocky — a noise grid showing through — and was replaced with gradient noise. Thumbprints over the keys were tried and rejected before the run. Code kept as reference.
