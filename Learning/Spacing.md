# Spacing

Why the space between things carries meaning, how a spacing scale turns that meaning into numbers, and what the numbers cost. The Goals widget on home is the example throughout.

---

## Four things, one distance

Between sets you glance at the Goals widget to see your latest progress. It holds four things: its cover, its name, and two lines: 5 GOALS and LATEST · PISTOL SQUAT.

In the agreed widget, at half width, every one of those sits 7 px from the next, inside 8 px of padding:

```
┌──────────────────┐
│ 8                │
│  [cover 72]      │
│ 7                │
│  GOALS           │   name
│ 7                │
│  5 GOALS         │   line one
│ 7                │
│  LATEST · PISTOL │   line two
│ 8                │
└──────────────────┘   162 px tall
```

Nothing is wrong with any single gap. The problem is that they are all the same. Equal distances say "these four things are equally related", and they are not. The two lines are one fact split in two. The name heads both lines. The cover is the name's picture. With every gap at 7, the eye has to read all four to rebuild those relationships, and on the gym floor that is a read, not a glance.

It costs space too. Four stacked items at equal spacing make the half-width widget 162 px tall. Two of them side by side, plus Rest at a glance, push the list of destinations down the screen. Every pixel the widgets take is a pixel the list cannot.

And it compounds. Every screen built this way invents its own distances: 7 here, 10 there, 6 between keys. No two screens agree, so moving between them feels slightly off even when nothing is broken.

## Space is a statement

**The turn: the space between two things says how closely they belong together.**

The closer the relationship, the smaller the gap. That one rule turns every gap into a decision about meaning rather than a number to eyeball. The widget, in round 3:

```
┌──────────────────────┐
│ 12                   │
│ [cover 48] 8 GOALS   │   cover names the widget:    8  (a thing and what names it)
│ 12                   │   name heads the lines:     12  (a heading and what it heads)
│ 5 GOALS              │
│ 2                    │   one fact on two lines:     2  (parts of one thing)
│ LATEST · PISTOL SQUAT│
│ 10                   │   12, less half the leading (see below)
└──────────────────────┘   about 120 px tall
```

The numbers are not chosen per widget. They come from one table, used on every screen:

| Relationship | Step |
|---|---|
| Parts of one thing | 2 px (`--space-1`) |
| A thing and what names it | 8 px (`--space-3`) |
| Like things in a series | 8 px, or none where a line divides them |
| A heading and what it heads | 12 px (`--space-4`) |
| Separate sections of a screen | 24 px (`--space-6`) |
| The screen's edge | 16 px (`--space-5`) |

The steps come from a **spacing scale**: a short list of sizes, each clearly bigger than the last, so two different relationships never end up a pixel apart and blur together.

The bottom gap is 10, not 12, because of **leading**: the space a line of text carries above and below its letters. A line of 11 px text sits in a 15 px line box, so 2 px of nothing hang under the letters. Measured to the letters, the eye sees 12. That adjustment is an **optical correction**: spacing measured to what is seen, not to the boxes the layout uses.

**In your own words:** "these two are close because they are one fact; these are further apart because they are different things."

**A test you can run:** squint at a screen until the text blurs. What clumps into one blob is what the spacing says belongs together. If the name, both lines and the cover blur into one even column, the spacing says nothing.

**What your decisions touch:** when you wireframe a screen and say which pieces form one thing, which names which and which heads which, you have already chosen every gap. The round only checks that they look right.

## What it costs

**The scale is coarse on purpose.** Between 8 and 12 there is no 10. When a gap looks slightly wrong, you cannot nudge it; you change the relationship or the table. On the Goals widget that is fine. Rest at a glance at half width breaks: its name needs 173 px next to a 48 px cover and gets 94, so it wraps to three lines. A per-widget gap could have hidden that; the scale shows it.

**Bigger gaps take room.** Separating the header from the widgets as different sections moved them from 16 px apart to 24. That is 8 px of every home screen given to a gap, and the widgets moved down to pay for it.

**Measuring to the letters is fragile.** The bottom gap's correction assumes the line box holds the text exactly where the browser on this machine puts it. On your Windows machine the same text sat a pixel or two differently. That is why the list's entries now trim their labels to their capital letters before centring them: the letters, not the line box, are what get placed.

## What was set aside

**Eyeballing each screen.** It is faster for one screen, and it looks right on that screen. But the distances drift from screen to screen, nobody can say why a gap is 7, and a later change has nothing to check against. The video's argument was exactly this: preset steps "prevent us from making bad decisions" while leaving room for judgement.

**A fixed padding per component**, every card 8 px inside, every list 16. It is consistent, but it encodes the container, not the relationship. The two lines of one fact would still sit as far apart as a name from its lines.

## Back to the spec

Principles: "Hierarchy says what matters. … When everything is equally loud, the eye reads the whole screen to find the one thing it needs. On the gym floor that turns a glance into a read."

The agreed widget's equal 7 px gaps were the spacing version of "everything equally loud." The spacing table is that principle applied to distance. It lands in the visual language when round 3 is approved, and the wireframe step now sets every gap from it before the first round.
