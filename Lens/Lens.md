# Lens

What Auburn is judged through: what the Lens holds, what it holds authority over, and the words used to talk about how Auburn is shaped. Read this first.

## Contents

```
Lens/
├── Lens.md            ← this file
├── Foundation.md      ← the case for Auburn. The root.
├── Principles.md      ← judgements that hold in every medium
└── Language/
    ├── basics.css     ← every value, in every language
    ├── Lexicon.md     ← words, in both voices
    ├── Touch.md       ← the touch language
    ├── Visual/        ← the visual language and its components
    └── Sound/         ← the sound language and its files
```

## Authority

The Lens holds authority over Spec. Inside the Lens, Foundation holds over the principles, and the principles over the languages; the four languages stand side by side. In Spec, behaviour answers to the principles, and screens answer to the languages and carry the behaviour. Where two disagree, the higher one holds, and the lower one is the defect, fixed in the same edit. Research, Learning, Lab and Ideas carry no authority.

Each line reads "answers to", from the lower end to the higher:

```
Lens    Foundation
            │
        Principles ───────────────────┐
            │                         │
        Languages                     │
        Lexicon · Visual ·            │
        Sound · Touch                 │
────────────┼─────────────────────────┼──────────
Spec        │                         │
        Screens ◄──── carry ──── Behaviour
                                 Data Model · Features

No authority: Research · Learning · Lab · Ideas
```

## Terms

Training concepts are Foundation's [Terms](Foundation.md#terms). Concepts explained in Learning are in [its glossary](../Learning/Glossary.md). An entry whose concept another document owns links to it, and that document holds where the two disagree. Every other entry is owned here.

| Term | Means | Not to be confused with |
|---|---|---|
| **Lens** | What Auburn is judged through: Foundation, the principles and the languages, in this folder. It decides and is never built directly. What it holds over is set out under [Authority](#authority). | Research, which carries no authority |
| **Spec** | What is built through the Lens: behaviour and screens. Anything with a file that is rendered, played or implemented belongs here. | — |
| **Foundation** | The case for Auburn: what it is, where it departs from the market and why, the two realms, the terms. The root. [Foundation](Foundation.md) | Principle, which is a judgement drawn from the case |
| **Principle** | A judgement that can reject a proposal by itself, in any medium. Each traces to Foundation. [Principles](Principles.md) | Grammar, which binds one medium |
| **Medium** | A channel Auburn expresses itself through: words, visual, sound, touch. | — |
| **Language** | For one medium, its elements and the grammar that combines them: enough to build a screen that does not exist yet. There are four: the Lexicon, Visual, Sound, Touch. Nothing in Spec introduces an element of a language. An element it needs is added to its language first. | A reference, which inspires a language and binds nothing |
| **Lexicon** | The words language: every word in both voices, the maxims, the slogan, and when each voice speaks. [Lexicon](Language/Lexicon.md) | — |
| **Visual** | The visual language, motion included: the palette, faces, scales, emphasis, timings, the tube, the entry glyph, icons, covers, components. [Visual](Language/Visual/Visual.md) | — |
| **Sound** | The sound language: the machine and its three sounds. [Sound](Language/Sound/Sound.md) | — |
| **Touch** | The touch language: how the hand acts on Auburn and how Auburn answers it. Tap, press and hold, the haptic pulse, the tap area. [Touch](Language/Touch.md) | — |
| **Element** | One named, reusable unit of a language: a palette colour, a face, an emphasis level, an icon, a component, a sound, a gesture, a word, a maxim. | — |
| **Value** | The setting an element takes (a colour's hex, a size, a duration), kept in [basics.css](Language/basics.css) for every language. | — |
| **Component** | A visual element built from others, with states of its own, placed on screens and never copied into them. | Screen |
| **Grammar** | A language's rules for combining its elements. | Principle |
| **Behaviour** | What Auburn does: records, rules, states. The Data Model and Features. | — |
| **Screen** | The languages put together for one purpose, carrying the behaviour behind it. | Component |
| **Realm** | Reality or fiction. The fiction changes what Auburn says, never what it does. [Foundation § Two realms](Foundation.md#two-realms) | — |
| **Voice** | The realm a word speaks in: plain (reality) or house (the corporation). | — |
| **Term** | A concept Auburn has, and what it means. [Foundation § Terms](Foundation.md#terms) | Word |
| **Word** | What a term or a piece of interface is called in one voice. Owned by the Lexicon. | Term |
| **Maxim** | A fixed line of house doctrine. An element of the Lexicon. | — |
