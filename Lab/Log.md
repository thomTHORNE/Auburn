# Lab log

Every Lab attempt and where it stands. Conventions are in CLAUDE.md.

Status is one of: parked, running, done, retired. Done means the verdict is in and the code is kept as reference. Retired means product code now covers the same ground and the attempt's code has been deleted; the entry stays.

---

## Suunto via Health Connect

Probe · running

Question: does a Flutter app on the phone read the runs, treadmill sessions, and hikes the Suunto app saved to Health Connect, with distance, duration, and heart rate?
Pass: all three activity types appear with those fields.
Timebox: half a day.
Needs: "Save to Health Connect" turned on in the Suunto app, and a build run on the phone.
Feeds: Research/Suunto, Research/Platforms.
Code: Lab/suunto-health-connect/
Stakes: a fail removes cardio from v1.

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

Sketch · parked

Question: does a halo and smudge layer that shifts with the phone's tilt read as real glass over the screen, without crossing the values and keys it must not obscure?
Pass: in use at the gym, the glass reads as physical, and no value or key is ever harder to read because of where the halo has moved.
Timebox: 1–2 days.
Needs: a passing CRT shader probe; a build on the Fold.
Feeds: Spec/Visual Design.
