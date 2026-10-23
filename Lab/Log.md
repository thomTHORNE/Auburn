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

Probe · running

Question: can Flutter run a custom fragment shader over the whole rendered screen on the Fold 8 — curvature, chromatic aberration, scanlines, bloom, glass halo, and smudges — while taps still answer within one frame?
Pass: the shader runs over live widgets at the screen's full refresh rate, and a tap's visual response is no slower than without it.
Timebox: half a day.
Needs: a build run on the Fold.
Feeds: Research/Platforms, Spec/Visual Design.
Code: Lab/crt-shader/
Stakes: a fail limits the CRT look to static texture layers.
