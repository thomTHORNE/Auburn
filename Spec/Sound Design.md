# Sound Design

Auburn's sounds are the machine behind the tube: one machine starting, running, and switching off. There are three, and nothing else in Auburn makes a sound. A sound never carries anything the screen or a haptic does not.

## The sounds

| Sound | File | Length | Plays |
|---|---|---|---|
| Boot | `auburn-boot.wav` | 8.0 s | Once, with the boot screen |
| Ambience | `auburn-ambience.wav` | 63.0 s, looping | From the boot's end, while Auburn is on screen |
| Power-down | `auburn-power-down.wav` | 11.4 s | Once, when Auburn is powered down |

The files are 44.1 kHz, 16-bit stereo, in [Sound Design/](Sound%20Design/). Auburn has its own volume, set in Settings from 0 to 100%, 100% by default. It scales all three sounds within the phone's media volume, so 100% plays them as mixed.

### Boot

A power-on click, a drive spinning up, a chime as the wordmark settles at 2.9 s, and a second, heavier machine rising in from 5 s. Its last 0.6 s is the ambience's last 0.6 s, so the ambience follows on without a seam. It peaks at −1 dBFS and averages −17.5 dBFS.

### Ambience

Both machines running, at an average of −24 dBFS. Its end runs into its start, so it repeats without a seam. It starts the moment the boot ends. When Auburn returns to the screen without a boot, it fades in over 0.5 s. When Auburn leaves the screen, it fades out over 0.5 s.

### Power-down

Relay clicks, the drive cranking down from 1.1 s, the fans winding down, and an off-thunk at 10.4 s. It starts at the ambience's level, and the ambience fades out over 0.5 s as it begins. Auburn quits when it ends. The power-down lasts 11.4 s whether sound is on or off.

## When Auburn plays

With sound on, Auburn plays over any other audio on the phone. It neither pauses nor lowers another app's audio, and it is not paused or lowered by it.

Auburn plays nothing when:

- sound is off in Settings;
- the phone is on silent or vibrate.

## Sources

| Recording | Author | Licence | Used in |
|---|---|---|---|
| [Startup P6 227](https://freesound.org/people/Beetlemuse/sounds/692846/) | Beetlemuse | CC BY 4.0 | Boot: the chime |
| [Bootup](https://freesound.org/people/bittermelonheart/sounds/551470/) | bittermelonheart | CC0 | Boot, ambience, power-down |
| [286 startup](https://freesound.org/people/facuarmo/sounds/482270/) | facuarmo | CC0 | Boot, ambience, power-down |

Startup P6 227's licence requires credit. Settings shows it: "Startup P6 227" by Beetlemuse (freesound.org/people/Beetlemuse/sounds/692846), licensed under CC BY 4.0, trimmed and mixed.

## Edge cases

| Scenario | Behaviour |
|---|---|
| Another app plays audio while a sound plays | Both play |
| Sound turned off while the ambience plays | It fades out over 0.5 s |
| The phone set to silent while the ambience plays | It fades out over 0.5 s |
| The volume is changed while the ambience plays | The ambience follows at once |
| Powered down during a workout | The workout stays in progress. Auburn opens straight to it next time, without the boot |
| Powered down with sound off | The power-down runs its 11.4 s in silence, then Auburn quits |
