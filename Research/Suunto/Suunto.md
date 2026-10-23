Status: Open

# Suunto

Bringing basic data for runs, treadmill sessions, and hikes recorded on a Suunto watch into Auburn. The watch and the Suunto app stay the recorders; Auburn reads from them.

## Settled

- Auburn does not record these activities itself. The watch does.
- **The path runs through intervals.icu.** The Suunto app syncs each workout to intervals.icu. Auburn fetches the workout's original FIT file with the owner's personal API key and reads it.
- **Cardio reaches v1 through intervals.icu.** The Suunto app does not write to Health Connect, and Suunto's own API is closed to personal use.

## Open questions

- **What "basic" means.** Which of those Auburn shows.
- **History.** How far back the first import reaches.
- **When data arrives.** On opening Auburn, in the background, or on request.
- **Notes.** How an imported activity sits beside the user's own notes on it.
- **The key.** How Auburn stores the API key on the phone.

## Findings

- **The Suunto app does not write to Health Connect.** It is absent from Health Connect's app permissions on the Fold. Lab: Suunto via Health Connect.
- **The Suunto Cloud API is partner-only.** Suunto's API portal: "We currently don't offer the API access for personal use."
- **intervals.icu syncs from Suunto and serves the original files.** It is free for personal use, connects to Suunto directly, and returns each activity's original file to the owner's personal API key.
- **The FIT file carries the whole workout.** Session totals (distance, timer time, average heart rate) plus a heart-rate sample per record, and a sport and sub-sport that separate runs, treadmill sessions, and hikes. Lab: Suunto via intervals.icu.
- **intervals.icu lists activities by date range.** The probe read 90 days in one request; no 30-day limit applies.
- **Dart's fit_tool 1.0.5 throws on values newer than its profile.** Lab: Suunto via intervals.icu.

## Dependencies

- **Requires:** Platforms — the stack must make authenticated HTTPS requests and parse FIT files.
- **Required by:** none.
