Status: Open

# Platforms

What Auburn is built with, which devices it runs on, and how its records stay on every one of them.

Seeded by Stem's platform research — see [Origin](Origin.md). Stem's conclusions were reached for a canvas app and are carried as findings to test, not as settled answers.

## Settled

- Mobile only. v1 targets Android phones.
- Android-only is v1's scope, not something the stack may lock in. Reaching other platforms later stays cheap.
- Cardio is recorded on a Suunto watch, not on the phone. Auburn does not track activity live.

## Open questions

- **The stack.** Flutter leads: one codebase that reaches iOS later. The CRT shader probe passed; the Suunto probe is the other half.
- **Offline.** Gyms are often where signal is worst. Whether a session must log fully offline, and what happens when it ends without a connection.
- **Sync.** Whether records sync across devices from v1, and through what.
- **Health platforms.** Whether Auburn reads from or writes to Apple HealthKit or Android Health Connect, and what for.

## Findings

- **Flutter runs a full-screen CRT shader at 120 Hz on the Fold 8.** Through ImageFilter.shader under Impeller, the full effect costs about a millisecond per frame and taps stay instant. Lab: CRT shader over Flutter.
- **From Stem: web stacks cannot keep one engine on mobile.** Every mobile shell uses the system web engine. Relevant only if Auburn needs identical rendering across platforms.
- **From Stem: local-first sync with per-object, per-field last-write-wins** was the proposed shape for a single-user app that grows to many. A training log is a simpler shape than a canvas — mostly appended, rarely edited on two devices at once — which may make the same approach cheaper here.
- **From Stem: a Cloudflare Workers, R2, and D1 stack** was proposed for sync. Its free-tier figures were unverified there and remain unverified here.

## Dependencies

- **Requires:** no other topic. The first open question waits on Foundation: where and how training happens decides the devices.
- **Required by:** Suunto — Health Connect access. Persistence and sync once specified.
