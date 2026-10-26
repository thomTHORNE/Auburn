Status: Open

# Suunto

Bringing basic data for runs, treadmill sessions, and hikes recorded on a Suunto watch into Auburn. The watch and the Suunto app stay the recorders; Auburn reads from them.

## Settled

- Auburn does not record these activities itself. The watch does.
- **The path runs through intervals.icu.** The Suunto app syncs each workout to intervals.icu. Auburn fetches the workout's original FIT file with the owner's personal API key and reads it.
- **Cardio reaches v1 through intervals.icu.** The Suunto app does not write to Health Connect, and Suunto's own API is closed to personal use.
- **An activity keeps its kind, start, duration, distance, average heart rate, and intervals.icu id.** Promoted to the Data Model.

## Open questions

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
- **intervals.icu also holds Suunto's wellness data.** Sleep, HRV, and resting heart rate sync from Suunto once wellness import is turned on in intervals.icu, and the same API key reads them by date range. Forum reports, not yet probed: sleep totals have arrived short, and the automatic sync has stalled for some accounts.
- **intervals.icu calculates more than the FIT file carries.** Each activity also has heart-rate zone times, training load, a heart-rate curve, intervals, and its streams as JSON. These are intervals.icu's calculations, not the watch's.
- **The watch's post-workout feeling reaches the FIT file**, on a 1–5 scale, and intervals.icu imports it as Feel. Forum report, not yet probed.
- **intervals.icu can send planned workouts to the watch** as SuuntoPlus Guides. Outside v1.

## Dependencies

- **Requires:** Platforms — the stack must make authenticated HTTPS requests and parse FIT files.
- **Required by:** none.
