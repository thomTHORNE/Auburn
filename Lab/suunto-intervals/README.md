# Suunto via intervals.icu — probe

Throwaway code. The question, pass condition, and verdict live in [`Lab/Log.md`](../Log.md).

One screen that lists your intervals.icu activities, downloads each one's original file, and reads it as FIT:

- **Verdict** — `PASS` when a run, a treadmill session, and a hike each arrive with distance, duration, and heart rate. The kind comes from the FIT file's own sport, not from intervals.icu.
- **Log** — the list request's status, how many activities came back, and their intervals.icu types. A failed request shows the start of its response.
- **Activities** — the newest 30: date, intervals.icu type, kind, then the FIT sport, distance, duration, heart-rate sample count, average heart rate, and file size. Ember means complete.

The athlete id is tried as entered, then without its `i` prefix.

## Running it

From this folder, with the Fold connected:

```
flutter run --dart-define=ICU_ATHLETE=<athlete id> --dart-define=ICU_KEY=<api key>
```

The two values fill the fields, so nothing has to be typed on the phone and the key stays out of the repo. Debug mode is fine; nothing here is timed.

1. `READ LAST 90 DAYS` — `±` switches between 90, 365, and 30 days.
2. Screenshot the verdict and log, then scroll so each kind shows at least once.

## Known limits

- Only the newest 30 activities are fetched. If the last run, treadmill session, or hike is older than that, narrow the window with `±`.
- Treadmill is recognised from the FIT sub-sport: treadmill, indoor running, or virtual activity. If the watch records it otherwise, it shows as a run with its sub-sport printed.
