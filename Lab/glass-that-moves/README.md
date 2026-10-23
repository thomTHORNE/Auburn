# Glass that moves — sketch

Throwaway code. The question, pass condition, and verdict live in [`Lab/Log.md`](../Log.md).

The CRT probe's stand-in logging screen under [`shaders/glass.frag`](shaders/glass.frag): the same CRT shader, with the glass layer driven by the phone's tilt. The halo moves the way a reflection on real glass would as the phone turns. What is on the glass — an oily film, swipe streaks, and dust — stays fixed and shows up where the light catches it.

Buttons on the readout line:

| Button | What it does |
|---|---|
| `GLASS` | Cycles how much glass: `OFF`, `LOW`, `HIGH`. |
| `TRAVEL` | How far the halo moves for a given tilt: `SMALL` or `LARGE`. |
| `STRENGTH` | The CRT effect's strength: 0.6 or 1.0, the two preferred in the probe. |
| `CENTER` | Takes the way the phone is held now as the resting pose. The halo returns to its corner. |

`FRAME p95` is the worst 5% of the last 600 frames, in milliseconds. It should stay under 8.3.

With the system's reduce-motion setting on, the glass holds still.

## Running it

From this folder, with the Fold connected:

```
flutter run --release -d <device id>
```

A release build stays installed after the cable comes out, so it can go to the gym. Use it on the **cover screen**.

1. Hold the phone the way you would between sets and tap `CENTER`.
2. Tilt and turn it slowly, then the way it moves in the hand during a session. Log sets with the grade and plate keys as you go.
3. Try each `GLASS` and `TRAVEL` setting, at both strengths.
4. Judge two things: whether it reads as glass over a screen or as an effect drawn on it, and whether the halo or a smudge ever makes a value or key harder to read.
5. Note the settings that felt right, and any position where the halo got in the way.

## Known limits

- The halo follows the accelerometer only: tilt, not rotation flat on a table, and not where real light in the room is.
- The stand-in is not the real design — fonts fall back to the system serif and monospace.
