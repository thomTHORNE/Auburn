# Sound language

Auburn's sounds are the machine behind the tube: one machine starting, running, and switching off. There are three, and nothing else in Auburn makes a sound. When each plays is [Sound](../../../Spec/Features/Sound.md)'s.

## The sounds

| Sound | File | Length | Is |
|---|---|---|---|
| Boot | `auburn-boot.wav` | 8.0 s | The machine starting |
| Ambience | `auburn-ambience.wav` | 63.0 s, looping | The machine running |
| Power-down | `auburn-power-down.wav` | 11.4 s | The machine switching off |

The files are 44.1 kHz, 16-bit stereo, in this folder.

### Boot

Its chime lands as the boot's wordmark settles, so a change to the boot's timing moves the chime with it. Its last 0.6 s is the ambience's last 0.6 s, so the ambience follows on without a seam.

### Ambience

Its end runs into its start, so it repeats without a seam.

### Power-down

It starts at the ambience's level.

## Sources

| Recording | Author | Licence | Used in |
|---|---|---|---|
| [Startup P6 227](https://freesound.org/people/Beetlemuse/sounds/692846/) | Beetlemuse | CC BY 4.0 | Boot: the chime |
| [Bootup](https://freesound.org/people/bittermelonheart/sounds/551470/) | bittermelonheart | CC0 | Boot, ambience, power-down |
| [286 startup](https://freesound.org/people/facuarmo/sounds/482270/) | facuarmo | CC0 | Boot, ambience, power-down |

Startup P6 227's licence requires credit. Settings shows it: "Startup P6 227" by Beetlemuse (freesound.org/people/Beetlemuse/sounds/692846), licensed under CC BY 4.0, trimmed and mixed.
