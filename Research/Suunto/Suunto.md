Status: Open

# Suunto

Bringing basic data for runs, treadmill sessions, and hikes recorded on a Suunto watch into Auburn. The watch and the Suunto app stay the recorders; Auburn reads from them.

## Settled

- Auburn does not record these activities itself. The watch does.
- **The path is a double jump.** The Suunto app writes to Health Connect; Auburn reads from Health Connect only what the Suunto app wrote.

## Open questions

- **What the Suunto app writes.** Which Health Connect records arrive — exercise session, distance, heart rate, elevation — and with what detail.
- **What "basic" means.** Which of those Auburn shows.
- **History.** How far back the first import reaches, and whether Auburn asks for the history permission to go past 30 days.
- **When data arrives.** On opening Auburn, in the background, or on request.
- **Notes.** How an imported activity sits beside the user's own notes on it.

## Findings

- **Health Connect knows which app wrote each record.** A read can be filtered by the writing app's package name, so Suunto's records can be read apart from anything else on the phone. Verified: Android's Health Connect read-data guide.
- **Reads reach back 30 days by default.** An app can read data from up to 30 days before it was first granted permission. A separate history permission lifts the limit; uninstalling the app revokes it. Verified: same guide.
- **Exercise sessions, distance, and heart rate are separate record types** in Health Connect. Whether the Suunto app writes each is unverified.
- **The Suunto app reportedly has a "Save to Health Connect" setting.** From a third-party integration guide; not confirmed on Suunto's site.
- **The Suunto Cloud API is reportedly partner-only**, not for personal use. Unverified; it no longer decides the path.

## Dependencies

- **Requires:** Platforms — the stack must read Health Connect, filtered by source.
- **Required by:** none.
