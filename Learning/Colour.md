# Colour

How a palette holds together, why some colours fight on a dark screen, and the two open questions behind Auburn's text colours. Auburn's home screen, between sets, is the example throughout.

---

## A line you cannot find

You have just racked the bar. Ninety seconds of rest. You glance at home to check what is overdue, and the answer is on the Rest widget's second line: OVERDUE · QUADS, HAMSTRINGS.

Your eye goes somewhere else first. It lands on POWER DOWN at the bottom of the screen, the one thing you will never press mid-workout. Then on the widget names on their ember bands. The overdue line comes third or fourth, and you read it rather than glance at it.

That is not a feeling. It can be measured. A colour on a screen can be scored by its **contrast** with the ground behind it: how many times brighter the lighter of the two is, on a scale from 1 (identical) to 21 (white on black). Body text reads comfortably from about 4.5 : 1; large text from about 3 : 1. Here is home, measured against the tube's ground (#1A1D1A):

| On home | Colour | Contrast |
|---|---|---|
| POWER DOWN | Cyan white at 90% | **12.4 : 1** |
| START WORKOUT and the other entries | Ember at 90% | 3.8 : 1 |
| OVERDUE · QUADS, HAMSTRINGS (before today) | Ember at 62% | 2.4 : 1 |
| 3 MORE | Ember at 42% | **1.8 : 1** |

The line you came for sits at 2.4. The key you will never touch sits at 12.4, five times louder. And the trend gets worse the further down the levels you go: every step of importance you remove costs more contrast than the last, so "supporting" text ends up barely distinguishable from the ground. Under the tube's own effects, the vignette darkening the edges and the scanlines thinning every line, those numbers only fall.

## Three dials, not one

**The turn: stop thinking of a colour as one thing.**

Every colour is three separate settings, and a palette holds together when you change them on purpose, one at a time. OKLCH is a way of writing colours as exactly those three settings, spaced to match how the eye sees them:

- **L, lightness**, from 0 (black) to 1 (white): how bright it reads.
- **C, chroma**, from 0 (grey) upward: how colourful it is.
- **H, hue**, an angle: which colour it is. Ember sits at 34°, the pale green trial at 149°, cyan white at 190°.

The same table, in those terms:

```
            L (lightness)
  1.0 ┤
      │  ● cyan white 90%      L .89  C .03  H 190   POWER DOWN
  0.8 ┤
      │
  0.6 ┤  ● ember 90%           L .58  C .16  H  34   entries
      │  ● pale green 42%      L .57  C .03  H 149   your secondary trial
  0.4 ┤  ● ember 62%           L .48  C .11  H  34   status line, before today
      │  ● ember 42%           L .40  C .08  H  35   3 MORE
  0.2 ┤  ● tube (the ground)   L .23
      └──────────────────────────────────────────────
```

Read it top to bottom and the problem is visible: one colour near the top, a cluster in the middle, nothing between 0.6 and 0.9. Lightness is what the eye ranks first. A palette with a hole in its lightness has one colour that shouts and a crowd that murmurs.

Notice too where the pale green trial landed: at the same lightness as the entries, but with almost no chroma (0.03 against ember's 0.16). Same brightness, no colour. That is why it reads as calm.

## A ramp

A **ramp** is a set of shades of one colour that belong together. It keeps H fixed, steps L in even amounts, and lets C ease off at the very light and very dark ends, because the screen cannot show strong colour there. You compute it once rather than picking each shade by eye. Ember's ramp, at seven steps:

| L | .92 | .82 | .72 | **.62** | .52 | .42 | .32 |
|---|---|---|---|---|---|---|---|
| Hex | #FEDCD4 | #FCAD9A | #FB775A | **#D9563A** | #B63517 | #8A2208 | #5E1403 |
| C | .040 | .097 | .168 | .170 | .170 | .144 | .110 |
| Contrast | 13.3 | 9.4 | 6.4 | 4.3 | 2.8 | 1.9 | 1.3 |

Ember itself (#D9573B) lands on the .62 step almost exactly; the ramp is built around the colour you already chose. The palette board on the canvas's Explorations page shows this ramp, one for a quiet neutral at the pale green's hue, and one for cyan white, with every step's contrast.

**In your own words:** a ramp is "the same colour, brighter or dimmer, in even steps."

**A test you can run:** screenshot a board and turn it to greyscale. Whatever looks the same grey is the same level to the eye, whatever its hue. If the overdue line and 3 MORE are the same grey, they are the same importance, whatever you meant.

**What your tuning touches:** when you move a level's opacity on the round board, you move L and C together along a straight line toward the ground. When you pick a text colour, you choose H.

## What each path costs

Two questions are open, and the board exists so you can judge them in place: home coloured three ways (A, B and C).

**Opacity, or solid steps.** Today a level is a colour at an opacity: ember at 62% means ember mixed 62 : 38 with whatever is underneath. On one dark ground that *is* a ramp, a straight line toward the ground with the hue held, which is why the levels feel related. It is a phosphor dimming, and it suits the tube. Its costs, on the overdue line:

- **It changes with the ground.** The same 62% is 2.42 : 1 on the tube and 2.35 : 1 on the list sheet's graphite: two different colours under one name.
- **It always heads toward the ground**, so each level costs more contrast than the last. That is how 3 MORE reached 1.8.
- **It has no single value.** "Ember at 62% over whatever is below" cannot be checked once, or handed to Flutter as one colour.

Solid steps fix all three: each level is a ramp step with one hex and one contrast figure. The cost is that the dimming becomes a choice instead of a consequence: someone has to decide which step each level takes, and keep that true as levels are added. And a solid step drawn over something unexpected, like the hold key's fill, stays the same colour where opacity would have blended.

**One colour per level, or a role and a level.** Round 3's trial gives each level its own colour (scheme B). The other way separates two questions: *what kind of thing* is this text (its **role**: accent, information, or set apart), and *how loud* is it (its **level**). Each role gets its own ramp; the level picks the step (scheme C). Its cost is a second axis to keep in your head, and a decision for every element: which role, which level. Its gain is that cyan white stays rare. POWER DOWN is loud because it is the only thing in that colour, and every other use of cyan white, even dimmed, spends that.

Neither question is settled. Each path is shown here with its price, so the choice can be made on the canvas rather than in the abstract.

## Back to the spec

Visual Design's Emphasis rule reads: every element sits on one of three levels, "the accent at the level's opacity on the ground, or the set-apart colour where a screen sets an element apart."

That sentence now reads differently. "At the level's opacity on the ground" is the opacity path: dimming by mixing toward the tube. "The set-apart colour" is already a role. Cyan white was never a fourth level; it was always a different kind of thing. The open questions are whether the levels stay opacity or become steps, and whether the other text gets roles of its own.
