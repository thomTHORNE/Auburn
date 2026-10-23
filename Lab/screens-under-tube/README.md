# Approved screens under the tube — sketch

Throwaway code. The question, pass condition, and a verdict line per screen live in [`Lab/Log.md`](../Log.md). A standing attempt: each screen approved on the design canvas is rebuilt here as Flutter widgets from its `Spec/Visual Design/<nn-screen>/screen.html` and added to `_screens` in `lib/main.dart`.

- `lib/basics.dart` — the basics from `Spec/Visual Design.md` as Dart constants, and the tube's settings.
- `lib/tube.dart` — the CRT and glass shader from `Lab/glass-that-moves`, at strength 0.6, glass LOW, travel SMALL, driven by tilt.
- `lib/screens/` — one file per approved screen.

Screens so far: **00 · Boot**, dark and light.

## Running it

From this folder, with the Fold connected:

```
flutter run --release -d <device id>
```

Use the cover screen. Fonts (Gelasio, Saira) load from Google Fonts the first time, so the phone needs a connection.

1. Tap a screen in the list.
2. Long-press anywhere for its controls — they sit outside the shader:
   - **Theme** — system, dark, light (screens with a light theme only). System follows the phone.
   - **Tube** — on or off, to compare with the plain screen.
   - **Replay** — plays an animated screen again.
   - **Back** — to the list.
   - **Glass** — LOW (approved), HIGH, OFF; **Travel** — SMALL (approved), LARGE; **Center** — takes how the phone is held now as rest. For checking the glass only.
   - With the controls open, a readout at the bottom shows whether the shader is running, the tilt, and where the glass's light sits.
3. For each screen and theme, judge: does the layout match its `screen.html`, does every text and mark read through the shader, does it look like its approved images?

## Known limits

- Taps land on the undistorted layout; near the edges the shader's curvature moves the picture a few pixels.
- The boot plays once per replay and ends faded out, on the bare screen colour.
