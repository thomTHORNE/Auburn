# CRT shader over Flutter — probe

Throwaway code. The question, pass condition, and verdict live in [`Lab/Log.md`](../Log.md).

A rough stand-in for the logging screen, a readout at the top, and one fragment shader ([`shaders/crt.frag`](shaders/crt.frag)) run over the screen in one of three modes:

| Mode | What runs |
|---|---|
| `OFF` | No shader. The baseline. |
| `FILTER` | Path A — `ImageFilter.shader` over the screen. Only available under Impeller; the readout says whether it is. |
| `SAMPLER` | Path B — `flutter_shaders`' `AnimatedSampler`: the screen is captured each frame and drawn through the shader. |

The readout keeps one row per mode:

- **FPS** — frames actually drawn per second.
- **TOTAL p50/p95** — milliseconds from vsync to finished frame; typical and worst 5%. Budget at 120 Hz is 8.3.
- **RASTER p95** — the GPU-side part of that.
- **TAP avg/max** — milliseconds from a finger landing on a grade key to the frame that shows the set added.

`MODE` cycles the modes, `STRENGTH` steps the effect between 0.3 and 1.0, and `RESET` clears every row.

## Running it

From this folder, with the Fold connected and the app on the **cover screen**:

```
flutter run --profile
```

Profile mode matters: debug builds are several times slower and make the numbers meaningless.

1. `RESET`, then tap grade keys and plate keys for about a minute in `OFF`.
2. `MODE` → `FILTER`, a minute of tapping. If the header says the filter path is unsupported, `MODE` skips to `SAMPLER`.
3. `MODE` → `SAMPLER`, a minute of tapping.
4. Screenshot the readout. A photo of the screen in each shaded mode helps judge the look.

## Known limits

- Tap latency assumes pointer timestamps and frame timestamps share Android's monotonic clock. If every tap reads 0, they do not on this device, and the eye test stands in.
- The stand-in is not the real design — fonts fall back to the system serif and monospace. Only the amount of UI matters here.
