# Architecture

This document records Auburn's technical stack decisions and the reasoning behind them. It is the authoritative reference for technology choices.

Mechanics that follow from those choices are split into their own documents in this folder as they are specified. A build order sequences the work once there is work to sequence.

---

## Tech stack

**Flutter, written in Dart.** One codebase builds the Android app for v1 and keeps iOS within reach later.

- **Rendering.** Flutter draws every pixel itself through its Impeller engine, so one full-screen shader runs over the whole interface: the CRT tube and the glass on it. Impeller is required. Without it, Flutter cannot run a shader over the rendered screen. On the Fold 8 cover screen the full effect holds 120 Hz with about a millisecond to spare.
- **Theme values.** Every colour, opacity, weight, size and timing the interface uses comes from `Spec/Visual Design/basics.css`. A script in `Tools/` generates Dart from it at build time and keeps its three tiers: primitives become constants, and each semantic and component value refers to the value it refers to in the CSS. A change to a primitive therefore reaches everything built on it, and the app uses the same names as the screens. The app declares no value of its own, never uses a primitive directly, and never reads CSS. A hex colour becomes a `Color`, an emphasis level its colour at the level's opacity, `px` logical pixels, and `s` a `Duration`. The light theme is a second set of semantic values, chosen by the theme setting.
- **Cardio import.** Authenticated HTTPS requests and FIT parsing, both proven in Dart.
- **Version.** The probes ran on Flutter 3.47.7 with Dart 3.13.5.

**Rejected.**
- **Native Android (Kotlin).** It would draw the same effect, but it locks Auburn to Android, which v1's scope rules out.
- **Web stacks.** Each mobile shell renders with the phone's own web engine, so the look would depend on the device, and nothing was found that runs one shader over the whole interface.
- **React Native.** It renders through native widgets, with no single surface to shade. It was not probed, because nothing in it improves on Flutter's single-surface rendering.

---

## Persistence

Local and offline. Every record lives on the phone, and Auburn works without a connection; only the cardio import reaches the network. v1 has no sync and no account. Records carry phone-generated IDs and created and updated times, so sync can be added later without migrating them.

The storage engine is not yet specified.

---

## Deferred, conditional on measurement

These are not open questions. Each is a decision already made *not* to build something until a specific condition is observed.

None yet.
