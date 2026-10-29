# Visual language

The visual language: what every screen is drawn from, and the rules that combine it. Every value is in [basics.css](../basics.css); each screen's look is its own `screen.html`, under [Screens](../../../Spec/Screens/Screens.md). [Principles](../../Principles.md) holds the reasoning.

---

## Basics

### Values

Every colour, face, level, and timing a screen uses is in [basics.css](../basics.css).

basics.css holds three tiers. Primitives have no context: the palette, the font families, the steps of each scale. Semantic values say what a value is for — roles, emphasis levels, faces by job, timings — and refer only to primitives. Component values belong to one part and refer only to semantic values. Screens and components use semantic and component values, never a primitive.

Every colour is a palette colour, named for what it is. A new colour joins the palette, with its name, before anything uses it; nothing takes a colour from outside the palette.

### Themes

Auburn has a dark and a light theme. It follows the device unless Settings sets dark or light. In v0 the theme changes the boot screen only; every other screen is the same in both.

### Emphasis

Every element sits on one of three levels — primary, secondary, supporting — for its text and for its lines: the accent at the level's opacity on the ground, or the set-apart colour where a screen sets an element apart.

### Lists

Every entry in a list is marked with the [entry glyph](entry-glyph.svg).

### Covers and icons

The widget covers are in [covers/](covers/); the icon set is in [icons/](icons/), each icon taken up by the screen that first uses it. A widget's cover carries no name band, since the widget names itself.

### The tube

Every screen runs under one shader: curvature, chromatic aberration kept off the centre, bloom, scanlines, a vignette, a slow rolling band, grain, and glass that moves with the phone's tilt. Its values are in basics.css; the boot runs its glass High, every other screen Low. With the system's reduce-motion setting on, the band, the grain, and the glass hold still.

The rest of the basics are not yet specified.

## Components

| Component | Used on | Status |
|---|---|---|
| [Header](components/header/header.md) | 01 | Agreed |
| [Widget](components/widget/widget.md) | 01 | Agreed |
| [List entry](components/entry/entry.md) | 01 | Agreed |
| [List sheet](components/list/list.md) | 01 | Agreed |
| [Hold key](components/hold/hold.md) | 01 | Agreed |
