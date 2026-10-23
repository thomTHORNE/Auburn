# CRT shader over Flutter — probe

Throwaway code. The question, pass condition, and verdict live in [`Lab/Log.md`](../Log.md).

A rough stand-in for the logging screen, a readout at the top, and a fragment shader ([`shaders/crt.frag`](shaders/crt.frag), or the cheaper [`shaders/crt_lite.frag`](shaders/crt_lite.frag)) run over the screen in one of five modes:

| Mode | What runs |
|---|---|
| `OFF` | No shader. The baseline. |
| `FILTER` | Path A — `ImageFilter.shader` over the screen, full shader, animated. Only available under Impeller; the readout says whether it is. |
| `LITE` | Path A with the cheaper shader: half the bloom taps, a one-octave smudge. Animated. |
| `STILL` | Path A, full shader, nothing animated. The clock stops, so frames are drawn only when something changes — as on a real logging screen. |
| `SAMPLER` | Path B — `flutter_shaders`' `AnimatedSampler`: the screen is captured each frame and drawn through the shader. Ruled out by the first pass; kept for reference. |

The readout keeps one row per mode:

- **FPS** — frames drawn per second during the mode's current run. `STILL` shows none: it draws only on taps.
- **TOTAL p50/p95** — milliseconds from vsync to finished frame; typical and worst 5%. Budget at 120 Hz is 8.3.
- **RASTER p95** — the GPU-side part of that.
- **TAP avg/max** — milliseconds from the grade key's handler to the frame that shows the set added: the app's own clock up to the end of the build, the frame's own timings after. Touch hardware latency before the handler is not included; it is the same in every mode.

The last line counts taps sent and taps measured. `MODE` cycles the modes, `STRENGTH` steps between 0.3, 0.6, and 1.0, and `RESET` clears everything.

## Running it

From this folder, with the Fold connected and the app on the **cover screen**:

```
flutter run --profile -d <device id>
```

Profile mode matters: debug builds are several times slower and make the numbers meaningless.

1. `RESET`. Strength stays at 1.0 for the whole run.
2. In each of `OFF`, `FILTER`, `LITE`, and `STILL`: tap grade keys — any order, as often as you like — and the odd plate key for about a minute, then `MODE`. Skip `SAMPLER`. The set table scrolls, so every grade tap shows up.
3. Screenshot the readout.
4. Note how taps *felt* in `FILTER` and `STILL` — instant, or a beat behind.

## Known limits

- Tap latency starts at the grade key's handler, not at the glass: the touch controller's own delay is outside it, and the same in every mode.
- The stand-in is not the real design — fonts fall back to the system serif and monospace. Only the amount of UI matters here.
