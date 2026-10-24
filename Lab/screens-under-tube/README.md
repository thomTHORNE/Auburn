# Approved screens under the tube — sketch

Throwaway code. The question, pass condition, and a verdict line per screen live in [`Lab/Log.md`](../Log.md). A standing attempt: each screen brought for approval on the design canvas is rebuilt here as Flutter widgets from its canvas boards (or its `Spec/Visual Design/<nn-screen>/screen.html` once saved) and added to `_screens` in `lib/main.dart`.

- `lib/basics.dart` — the basics from `Spec/Visual Design.md` as Dart constants, and the tube's settings.
- `lib/tube.dart` — the CRT and glass shader from `Lab/glass-that-moves`, at strength 0.6, glass LOW, travel SMALL, driven by tilt.
- `lib/screens/` — one file per screen. `covers.dart` holds the widget covers as SVG, generated from the canvas; `assets/bust-ember.png` is the Rest cover's bust.

Screens so far: **00 · Boot**, dark and light; **01 · Navigation, round 2**, for approval.

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
   - **Glass** — the screen's own level from the basics first (LOW, or HIGH for the boot), then the others, then OFF; **Travel** — SMALL (approved), LARGE; **Center** — takes how the phone is held now as rest. For checking the glass only.
   - With the controls open, a readout at the bottom shows whether the shader is running, the tilt, and where the glass's light sits.
   - **No workout / In workout** (screen 01 only) — switches the first entry between START WORKOUT and RESUME WORKOUT.

### Screen 01 · Navigation, round 2

- **The list** — tap or drag its handle to raise and lower it. Three entries show while it is down.
- **Power down** — press and hold: the fill crosses in 1.5 s and drains in 0.3 s if let go. When full it shows a stand-in, since screen 16 is not designed; it does not quit. A long press here does not open the Lab's controls.
- **Widgets** — EDIT opens a widget's controls: ▲ ▼ move it one place in reading order, HALF / FULL sets its width, DONE closes them. Tapping a widget or an entry shows a stand-in for the screen it opens.
- **Replay** rebuilds the screen from its start: widgets back in their first order and widths.
3. For each screen and theme, judge: does the layout match its `screen.html`, does every text and mark read through the shader, does it look like its approved images?

### Sound in the hand

A second attempt sharing this app; its entry is in the log. `lib/sounds.dart` plays the approved WAVs from `Spec/Sound Design/`, copied to `assets/sounds/`, through `audioplayers` with no audio focus requested, so other apps' audio keeps playing.

- **Boot** plays with the boot screen, from the start on every replay.
- **Ambience** loops from the moment the boot ends, under every screen. Opening a screen without a boot fades it in over 0.5 s. It fades out over 0.5 s when the app leaves the screen, and back in on return.
- **Power-down** plays when the hold fills; the ambience fades out as it starts. Leaving its stand-in brings the ambience back, since the Lab does not quit.
- **SOUND ON / OFF** and **VOLUME** in the long-press menu stand in for Settings' sound toggle and Auburn's own volume, which scales every sound within the phone's media volume. The phone's silent and vibrate modes mute all three, read once a second from the ringer mode.

## Known limits

- Taps land on the undistorted layout; near the edges the shader's curvature moves the picture a few pixels.
- The boot plays once per replay and ends faded out, on the bare screen colour.
