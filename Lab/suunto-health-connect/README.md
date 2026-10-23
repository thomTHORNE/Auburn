# Suunto via Health Connect — probe

Throwaway code. The question, pass condition, and verdict live in [`Lab/Log.md`](../Log.md).

One screen that asks Health Connect for access, reads workouts and heart rate, and shows:

- **Verdict** — for runs, treadmill sessions, and hikes: `PASS` when at least one arrives with distance, duration, and heart rate.
- **Sources** — every app that wrote the data, by package name, with counts per type. This is where Suunto's package name shows up.
- **Workouts** — each one with its type, start, duration, distance, calories, heart-rate samples, and source.

## Before running

- In the Suunto app, turn on saving to Health Connect (reported as Settings → "Save to Health Connect"; the name may differ by version).
- Make sure a recent run, treadmill session, and hike have synced from the watch.

## Running it

From this folder, with the Fold connected:

```
flutter run
```

Debug mode is fine; nothing here is timed.

1. `1 · GRANT ACCESS` — allow every item in the Health Connect sheet.
2. `2 · ALLOW HISTORY` — lets the read reach past 30 days.
3. `3 · READ LAST 90 DAYS` — `±` switches between 90, 365, and 30 days.
4. Screenshot the verdict and sources, then one workout of each kind.

## Known limits

- A workout's distance, calories, and steps are summed by the `health` plugin from every app's records inside the workout's time window, not only Suunto's. If the phone also counted the walk, distance can read high. Heart rate is filtered to the workout's own source here.
