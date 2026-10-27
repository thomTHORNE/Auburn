# Hierarchy

What hierarchy is, which properties of a screen take part in it, and why getting one right is not enough. Home, in the middle of a workout, is the example throughout.

---

## The wrong thing first

You are mid-workout. You stepped away from the bench, the phone locked, and you open Auburn to carry on. Home shows, and what you want is RESUME WORKOUT, the first entry in the list.

Count what competes for that glance. Home holds fourteen pieces of text and three covers: the wordmark, the status line, three widget names, six lines of widget information, the list handle, three entries and POWER DOWN. Each one is drawn with a colour, a weight, a size and a place on the screen, and each of those properties tells the eye something about importance.

Now ask which one wins. By contrast against the ground, the ranking is:

| | Contrast |
|---|---|
| POWER DOWN, in cyan white | 12.4 : 1 |
| The widget names, ink on ember bands | 4.8 : 1 |
| AUBURN, ember | 4.4 : 1 |
| RESUME WORKOUT, ember at 90% | 3.8 : 1 |
| The status line, the widget lines | 2.4 : 1 before today |
| 3 MORE | 1.8 : 1 |

The thing you came for is fourth. The thing you must not touch mid-workout is first, three times louder than anything else. Size and position partly rescue it: entries are the largest interface text, and the list is where the thumb already is. But the eye does not add the properties up politely. The loudest one wins the first glance, and the rest of the ranking is read, not seen.

## A ranking with several voters

**The turn: hierarchy is a ranking, and every visual property casts a vote in it.**

| Property | What it says | Who it promotes on home |
|---|---|---|
| Lightness and contrast | How much it stands off the ground | POWER DOWN |
| Size | How much room it takes | The covers, the entries |
| Weight | How dense the letters are | The widget names, status (Bold) |
| Hue | What kind of thing it is | POWER DOWN, the only cyan |
| Space around it | What it belongs to | Whatever stands alone |
| Position | Where the eye and thumb start | Top: AUBURN. Bottom: the list, POWER DOWN |

When the votes agree, one glance finds the top of the ranking. When they disagree, the eye stalls, and the strongest single vote wins, which on home today is lightness, for the wrong element.

Auburn already has the ranking: three **levels**, primary, secondary and supporting. Every element sits on one. What it does not yet have is a rule for which properties carry the level, so the votes can disagree.

**In your own words:** "first I see this, then that, then the rest, and the order matches what I came for."

**A test you can run:** look at a screen for five seconds, then look away and name the first three things you noticed. Then turn it to greyscale and squint. If what you named first is not what the screen exists for, some property is outvoting the level.

**Where your decisions land:** each text colour and opacity you tune on the round board is one vote, its lightness. Each gap in the spacing table is another, its grouping. The type scale is a third, its size. A level is only as clear as the agreement of the properties carrying it.

## What it costs

**Every element needs a decision.** With three levels, each new piece of text must be placed on one, and a wrong placement shows at once, because the levels are few and far apart. That is the point, but it is work every screen pays.

**Few levels are coarse.** Three steps of loudness cannot express every shade of importance. Something always sits a little too high or too low.

**Some things must be loud for reasons other than importance.** POWER DOWN is not the most important thing on home, but it carries the tube's lore and the one act that cannot be taken back. Making it stand out is a choice about *what kind of thing* it is, not *how important* it is. When that choice uses the same property the levels use, lightness, it outvotes the levels. That is the clash behind "should there be a fourth level?"

## Two ways out, both priced

**Add a level.** A fourth level above primary, for set-apart elements: one more rung on the same ladder. It is simple to state. But it says POWER DOWN *matters more* than RESUME WORKOUT, which is not true, and every screen then has a level reserved for exceptions.

**Add a dimension.** Keep three levels for loudness, and add a separate choice of *kind*: accent, information, set apart. Set-apart elements get their own colour and are allowed to break the ranking on purpose, which is only safe because there are so few of them. The cost is a second axis on every element, and discipline: the moment a second thing is set apart, both lose their force.

Neither is decided. The colour explainer shows the same split from the palette's side; the spacing explainer shows how distance votes. Each can be judged on its own.

## Back to the spec

Design Principles, "Hierarchy says what matters": "What the user came for is the most prominent; what informs it steps back; what only holds the screen together steps back further. … In practice: on the main menu, the destinations are at full strength, the status lines a step back, and the numbers and the rules between rows further back still."

That principle names the levels and the order. What it leaves unsaid is that every property, not just colour, has to agree with that order, and that something like POWER DOWN, loud for a different reason, needs a rule of its own. That is the question the colour and spacing work keeps arriving at.
