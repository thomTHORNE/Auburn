Status: Open

# Platforms

What Auburn is built with, which devices it runs on, and how its records stay on every one of them.

Seeded by Stem's platform research — see [Origin](Origin.md). Stem's conclusions were reached for a canvas app and are carried as findings to test, not as settled answers.

## Settled

Nothing yet.

## Open questions

- **Where training happens and what is in hand.** A phone in the gym is the obvious case. Whether a watch, a tablet, or a desktop also needs Auburn — and for what — decides the target list.
- **The stack.** Stem's working choice is Flutter. Whether the reason it was chosen — one renderer for rich text and freehand ink on every platform — matters for a training app, or whether a different reason decides Auburn's stack.
- **Offline.** Gyms are often where signal is worst. Whether a session must log fully offline, and what happens when it ends without a connection.
- **Sync.** Whether records sync across devices from v1, and through what.
- **Health platforms.** Whether Auburn reads from or writes to Apple HealthKit or Android Health Connect, and what for.
- **Wearables.** Whether heart rate or other device data enters a session, and from which devices.

## Findings

- **From Stem: web stacks cannot keep one engine on mobile.** Every mobile shell uses the system web engine. Relevant only if Auburn needs identical rendering across platforms.
- **From Stem: local-first sync with per-object, per-field last-write-wins** was the proposed shape for a single-user app that grows to many. A training log is a simpler shape than a canvas — mostly appended, rarely edited on two devices at once — which may make the same approach cheaper here.
- **From Stem: a Cloudflare Workers, R2, and D1 stack** was proposed for sync. Its free-tier figures were unverified there and remain unverified here.

## Dependencies

- **Requires:** no other topic. The first open question waits on Foundation: where and how training happens decides the devices.
- **Required by:** none yet. Persistence, sync, and any health-platform integration will depend on it once specified.
