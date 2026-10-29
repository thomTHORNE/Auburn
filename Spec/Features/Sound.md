# Sound

## What it is

When Auburn plays the three sounds of its [sound language](../../Lens/Language/Sound/Sound.md), how loud, and when it stays silent.

## Behavior

### Volume

Auburn has its own volume, set in Settings from 0 to 100%. It scales all three sounds within the phone's media volume, so 100% plays them as mixed.

### Boot

Plays once, with the boot screen.

### Ambience

Starts the moment the boot ends and loops while Auburn is on screen. When Auburn returns to the screen without a boot, it fades in over 0.5 s. When Auburn leaves the screen, it fades out over 0.5 s.

### Power-down

Plays once, when Auburn is powered down. The ambience fades out over 0.5 s as it begins. Auburn quits when it ends. The power-down lasts 11.4 s whether sound is on or off.

### Alongside other audio

With sound on, Auburn plays over any other audio on the phone. It neither pauses nor lowers another app's audio, and it is not paused or lowered by it.

### Silence

Auburn plays nothing when:

- sound is off in Settings;
- the phone is on silent or vibrate.

## States

| State | Kind | Meaning |
|---|---|---|
| Sound | Persisted: `Settings.sound` in the [Data Model](../Data%20Model.md) | Whether Auburn plays at all |
| Volume | Persisted: `Settings.soundVolume` | 0–100% |
| The ambience playing or faded out | Runtime | Whether Auburn is on screen with sound playing |

## Constraints

None.

## Edge cases

| Scenario | Behaviour |
|---|---|
| Another app plays audio while a sound plays | Both play |
| Sound turned off while the ambience plays | It fades out over 0.5 s |
| The phone set to silent while the ambience plays | It fades out over 0.5 s |
| The volume is changed while the ambience plays | The ambience follows at once |
| Powered down during a workout | The workout stays in progress. Auburn opens straight to it next time, without the boot |
| Powered down with sound off | The power-down runs its 11.4 s in silence, then Auburn quits |
