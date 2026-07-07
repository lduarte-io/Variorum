# Phase 13 — UI design passes — ORIENTATION SKETCH

> **Weaker status than the 10–12 briefs (author-requested, 2026-07-07):** this is a Fable
> pass over likely shape and tradeoffs, written far ahead so the phase doesn't start from a
> blank page. It is **expected to partially stale** — two phases of the author's daily use
> and her accumulated feel-feedback outrank anything here. Binding content is only what it
> *cites* from the spec; everything else is a leaning for the just-in-time plan (written at
> Phase 12's closeout, with the author) to accept, adapt, or discard.

## What is binding no matter what the design becomes

- **P1–P3 re-verified after every styling milestone** — a beautiful editor that regressed
  keystroke cost failed the phase (AppSpec §12: "perf invariant re-verified after styling").
- **Decorations stay off the live editor** (TEXTKIT2_NOTES §3: per-range rendering attributes
  are the flakiest TK2 subsystem): style the read tier and the SwiftUI chrome freely; the
  live `NSTextView` keeps minimal custom drawing. The Phase 7 pattern (badges as overlay
  views, never rendering attributes) is the template for every editor decoration.
- **Calm default, one block blooms** is architecture, not styling — the design expresses it;
  it can't trade it away. Boundaries invisible at rest; badge only on fans (§12).
- TK1 ban, canary, spike re-run per point release — all unchanged. No new third-party
  dependencies without the author (design-system/UI packages included).

## Process shape (leaning — differs from /run-phase deliberately)

The implement→cold-review→adjudicate loop fits poorly here: design is *iterative with the
author* (AppSpec §12: "UI design happens later, iteratively, with the author"). Leaning:
short author-driven design sessions (author + one agent), each ending in a committed,
runnable increment; the *gates* run per milestone rather than per session — a perf/regression
check (the binding list above) and a cold review pass over each milestone's accumulated diff.
Model policy: these sessions are interactive and taste-driven — Opus by default; the author
redirects if a session turns into engineering.

## Likely workstreams (leanings)

1. **A theme/token layer as its own module** — colors, type scale, spacing, materials —
   so styling never smears into feature code (one feature = one module survives the design).
2. **Typography first.** A prose app's design *is* type: reading measure, rhythm, block
   spacing (the single-`"\n"` separator + paragraph styles decision from Phase 7 becomes
   visible design surface). Dark mode from the first pass, not retrofitted.
3. **The signature interaction: seams, badges, the fan.** Block seam reveal on hover/focus,
   the corner badge, fan panel bloom — this is the product's identity moment; budget real
   iteration here. Animation budget is a P3 question as much as a taste question.
4. **Library/timeline information design** — density vs calm; the author's daily surfaces.
5. **Per-view passes** in the order she actually uses them (book view reading experience
   likely first — it's the "is this pleasant to read in" test).
6. **Typographic PDF export** (owned here per KnownIssues) — the basic Phase 11 PDF grows
   real typography once the type system exists.
7. **Liquid Glass where it earns its place** (the author's standing line) — chrome, not text.

## Tradeoffs to frame with the author (not pre-answered)

- System-native feel vs distinctive identity (and what that means for stock controls).
- Density vs calm on the library surfaces.
- Animation richness vs the P3 budget (the fan bloom especially).
- Whether the reference panel and pool get design now or stay functional until used more.

## What NOT to do

- No gesture/interaction redesign that contradicts what Phases 8–11 daily use validated,
  without an explicit author revisit (her feel notes from those phases are the evidence).
- No design-system dependency without her license vetting (author-only call).
- No styling work that requires touching `Sources/VariorumCore` — if design wants a model
  change, that's a finding to surface, not a tweak to make.
