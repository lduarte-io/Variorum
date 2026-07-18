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

## Author design-reference note (2026-07-16, at the 11b kickoff)

The Phase 11 kickoff mockups (`Spikes/Phase11Mockups/mockups.html` + `mockups-v2.html`,
committed at `924f591`) are a liked visual reference: the author's words at the 11b
kickoff — she "quite liked their appearance," and "they still look nicer than the app,"
acknowledging the UI stage hasn't arrived yet. When this phase's design sessions start,
open those pages beside the app as one input among several. Reference, not
contract — the just-in-time plan weighs them like everything else in this sketch.

**Her correction (2026-07-17):** liking the mockups better than the current app is NOT
the same as their being her design preference — do not treat them as a settled
direction, and do not read them as "the one existing artifact of her visual taste."
She expects a genuine EXPLORATORY opening to this phase: more questions asked of her,
more prototypes/directions to react to, and real effort spent on fine-tuning the small
details — she "wouldn't build just based off how the prototype looks." She knows 13 is
the phase that needs her most and is prepared to spend the time.

## Author additions (2026-07-17, pre-Phase-12 intake — direction-level; the canonical record is AppSpec §14's 2026-07-17 delta)

- **N-post side-by-side (user setting).** The posts-axis side-by-side (the 11a aligned view)
  is two posts today; on large screens she wants the option of MORE, with the column count
  user-controllable — the same control family as the takes view's shipped 1–4 columns, on
  the posts axis. Functional capability + layout work; slot it in the per-view passes.
- **Reference panel beside multi-post views.** She wants a reference openable while posts
  sit side by side (today the panel lives only in the single-post detail inspector). A
  window-composition question for this phase's layout work — the panel machinery itself
  (B3) needs no change.
- **Block comments — DECIDED 2026-07-17: this phase OWNS them** (her call, same day).
  Block-level working notes, never per-take. **Shape firmed in her follow-up round:
  their own TABLE** (multiple per block), tombstoned via `deleted_at`, and **deleted
  comments visible somewhere and resurrectable** — accidental deletion recoverable;
  "the feature shouldn't be excessively skimpy." Travel-through-structural-ops rules
  are the design round's, asked to her live (her instinct: duplicate where needed,
  easy to resolve — see the §14 delta). Schema = a SyncSpec §12 lockstep event with
  its own commit — the "no VariorumCore changes" rule below gains this deliberate,
  author-ratified exception, and her pending phone install folds into the lockstep's
  every-client step (one install covers this and the outstanding 11a constraint).
- **NOTEBOOKS (2026-07-17 follow-up — re-centered here from the Phase 15 orbit; §14
  item 10 is the canonical record).** The dream-journal ask clarified: not a per-day
  rule but the notebook as a first-class, LEGIBLE product surface — a place where you
  make posts and see them one after another; a **shelf view** of her notebooks (click
  in; **finish** them); starting a "new" journal as a separate notebook; and
  **bounded-length notebooks** (declare a length at start; extend or start a new one
  when it ends — she'd like *words* as a unit). The machinery substantially exists and
  is invisible: curated readings ARE ordered post lists, `reading.max_posts` is the
  extent constraint (fixed-length journals were its motivating example) with **no UI
  face at all**, `reading.locked` is "declared done," profiles include `'journal'`.
  Genuinely new: the shelf/finish faces, a words-based extent option, and —
  her direction, model-level — **first-class reorderable chapter groupings within a
  book** ("groupings of posts should actually be something," not tag-derived
  sections; e.g. a `reading_section` table — 2–3 options for the design round, NOT
  decided). The sittings design this; the plan scopes what lands in 13 vs later.
- **Chat/conversation reference kind (noted, LOW priority — her explicit "make a note".)**
  Paste-in two-sided transcripts rendered chat-style in the reference panel. Design-time
  question if taken: where pasted content lives (an app-written transcript file behind the
  existing file machinery vs a content column on `reference`). No urgency; hers to pull.
- **Her urgency (2026-07-17, re-affirming the 2026-07-16 note above):** the mockup pages
  "looked so much better and [are] easier to just understand… colors, spacing" — and
  later the same day this phase was **re-sequenced NEXT** (Phase 12 deferred until after
  13 + real use; master plan pointer has the record).
- **Legibility is first-class scope (2026-07-17):** "it's really unclear what you can
  even do in the app right now" — information architecture and discoverability of the
  capabilities that already exist (readings/notebooks, extents, the seal, export, the
  pool, lenses…) are as much this phase's job as visual polish.
- **Pulled forward from deferred Phase 12 (2026-07-17):** the kickoff sitting takes the
  three design-prerequisite measurements (decoration/rendering-attribute budget on the
  live TK2 editor, read-tier per-view cost at scale, keystroke headroom under
  decorations — the 12 plan's "answer 4"), seeds a DESIGN CORPUS in the dev store (so
  density/calm decisions are made against volume, not a handful of posts; A4-fenced,
  never the real store), and runs the ~30-min backup restore drill (protective before
  real use ramps).

## Process shape (leaning — differs from /run-phase deliberately)

The implement→cold-review→adjudicate loop fits poorly here: design is *iterative with the
author* (AppSpec §12: "UI design happens later, iteratively, with the author"). Leaning:
short author-driven design sessions (author + one agent), each ending in a committed,
runnable increment; the *gates* run per milestone rather than per session — a perf/regression
check (the binding list above) and a cold review pass over each milestone's accumulated diff.
Model policy: the "Opus by default" leaning here was superseded 2026-07-11 (CLAUDE.md), then
refined 2026-07-17 into a **two-stage shape**: the exploratory/design/plan-authoring
**sittings** are author-attended **Fable** sessions, and once the plan is fully made,
**execution runs as an ordinary `/run-phase` cast** (she invokes it; staffing decided at that
kickoff). Per her 2026-07-17 instruction, the sittings OPEN with the exploratory round
(questions + divergent prototypes) BEFORE any committed styling direction — increments begin
once she has chosen from real alternatives.

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
