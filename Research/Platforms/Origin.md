# Origin

Stem's platform research, carried across to seed this topic on 2026-10-23. Taken from Stem's `Research/Platforms/` on branch `claude/amazing-allen-by2bwl`: `Stack.md` and `Sync.md`, verbatim. Frozen.

Everything below was written for Stem — a thinking canvas — and is evidence for Auburn, not a decision about it.

---

Status: Open

# Stack

What Stem is built with, now that it runs on desktop and mobile with full parity.

## Settled

- Flutter is the working choice, held until the spike passes.
- v1 targets Android, macOS, and Windows.
- The reason is one renderer everywhere. Flutter draws every pixel itself rather than using each platform's web engine, so text and drawing behave identically across platforms — the property Electron was originally chosen for, which no web stack can keep once a phone is in scope.
- The GitHub integration uses GitHub's API. No git runs on the device.
- Pressure is simulated on every device. Stylus pressure and tilt are not used.

## The spike

Three tests, each on all three target platforms. Built to answer, then discarded.

1. **Ink.** Strokes drawn with `perfect_freehand` (official Dart port) feel immediate and smooth: finger on the Android phone, trackpad on macOS, mouse or trackpad on Windows.
2. **Text.** A rich text box with Stem's supported marks edits correctly, keeps its marks, and zooms with the canvas. Candidates: `appflowy_editor`, `super_editor`, `flutter_quill`.
3. **Clipboard.** A PNG image reaches the system clipboard and pastes into another app. Candidate: `super_clipboard`.

All three pass: Flutter is confirmed and Architecture is rewritten. Text fails: the fallback is a web app in Tauri 2, accepting a different web engine per platform.

## Open questions

- What replaces the reactivity rule: how scene state stays out of the framework's rebuild cycle.
- How the three-layer renderer maps onto Flutter's painting and repaint boundaries.
- SVG export without a browser document to serialise.
- Secure storage for the GitHub token on each platform.

## Findings

- **Web stacks cannot keep one engine on mobile.** Every mobile shell uses the system web engine — WebKit on iOS, the system webview on Android.
- **tldraw would remove the canvas engine risk**, but production use needs a paid licence or a visible watermark, and its default interaction model is the one Stem's principles reject.

## Dependencies

- **Requires:** none.
- **Required by:** Touch Input — the input events available. Sync — the local store.

---

Status: Open

# Sync

Keeping every board on every device, through a sync service Stem runs.

## Settled

- **Local first.** Every device keeps a full local copy and writes to it first. Sync runs in the background when a connection exists. Offline is not a mode; it is the base everything else rides on.
- **v1 is one user on a free tier.** The architecture assumes many users from the start, so moving to a service for many users is growth, not a rewrite.
- **No encryption on the device in v1.** The service can read synced boards. Informed consent is asked once, at setup.
- **Changes are commands.** The command layer already records every mutation; sync exchanges them per board.
- **Objects merge independently.** The latest write to each object wins, field by field. Deletes are recorded so they do not return.

## Proposed shape

A small API on Cloudflare Workers, board logs, snapshots, and images in R2, and an index in D1. Free-tier figures are from search results and are unverified; the D1 figures conflict.

## Built to grow

v1 serves one user; nothing in it assumes one.

- Every stored record is keyed by user from day one.
- Authentication sits behind one interface. v1 pairs your own devices with a token; accounts replace it later without touching sync.
- The API holds no state between requests, so it scales by adding capacity.
- The sync protocol carries a version number from its first message.
- Storage is laid out per user, then per board. Quotas are configuration, not code.

## Open questions

- Verifying the free-tier limits.
- Compacting a board's change log into a snapshot, and when.
- Uploading images once, and not again on every device.
- The first sync of boards that existed before sync was set up.
- A board edited on two devices, both offline, for days.
- Background sync limits on Android.
- What the consent step shows.

## Findings

- **The command layer is already the change stream.** Sync needs no separate change tracking.

## Dependencies

- **Requires:** Stack — the local store on each platform.
- **Required by:** none.
