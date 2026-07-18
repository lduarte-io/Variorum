# Phase 15 — iOS full surface — ORIENTATION SKETCH

> **Weaker status than the 10–12 briefs (author-requested, 2026-07-07):** a Fable pass over
> likely shape and tradeoffs. This phase's scope is explicitly "decided then" (master plan) —
> by the author, with a year-plus of her own mobile usage evidence in hand. Expected to
> partially stale; binding content is only what it cites.

## The one thing to protect BEFORE this phase (a standing discipline, active now)

The expensive part of a full iOS editor is block identity on the phone — and Phases 7/9
already built its brain as **pure, platform-neutral code**: `BlockRangeIndex`,
`StructuralGesturePlanner`, `CutPropagation`, `BoundarySnapping`, `SegmentationRules`, the
`EditorDocument` mapping. **Keep them AppKit-free through Phases 9–11** (no `NSPasteboard`,
`NSEvent`, or AppKit geometry types smuggled into the pure layer) and Phase 15 inherits the
entire identity core for free under a `UITextView` TK2 wrapper — the view layer is the only
new engineering. If a phase between now and then dirties that boundary, flag it in review at
full severity; this line is why mobile stays cheap.

## Likely scope ladder (for the author to cut where she wants)

1. **Reading views first.** The Phase 10 read tier is SwiftUI — it ports nearly free.
   Library, timeline, book view, and rendered posts on the phone; journaling capture stays
   as-is. This rung alone may be most of the daily value.
2. **Fan *viewing* before fan gestures.** Seeing a block's takes (and maybe `chooseVariant`)
   read-only is cheap and honors the data model; creating/editing variants on touch stays
   out unless she revisits (CoreDescription pillar 8's boundary, hers to move).
3. **The full editor on iPad before iPhone.** Hardware keyboard + pointer ≈ the Mac
   interaction model; TK2 `UITextView` + the pure identity core; the TEXTKIT2_NOTES
   discipline gains an iOS row in the §5 matrix (TK2-on-iOS has its own point-release
   quirks — assume nothing carries over untested).
4. **Structural gestures on touch — genuinely hard interaction design** (selection precision
   is the whole game). Default stance: desktop-only, forever fine; revisit only on explicit
   author demand with iPad evidence.

## Author additions (2026-07-17, pre-Phase-12 intake — direction-level; the canonical record is AppSpec §14's 2026-07-17 delta)

- **Journal-like notebooks (the dream journal) — RE-CENTERED 2026-07-17 (her follow-up):
  the notebook is a first-class MAC product surface, designed in the Phase 13 sittings**
  (AppSpec §14 item 10 + the 13 brief carry the direction: shelf view, finish, bounded
  lengths over the existing reading machinery, first-class chapter groupings; NOT about
  a per-day rule). What remains 15-relevant: the PHONE half — journaling into a chosen
  notebook from the capture surface (a notebook picker; how the per-day create-or-open
  rule scopes per notebook if the design round gives notebooks dated pages) — designed
  here against whatever notebook shape 13 lands.
- **Phone takes viewing — she is rethinking the never-on-phone stance** (pillar 8's
  boundary, hers to move; thinking-about level, no commitment). Her floated shape is
  strictly limited: takes visible for ONE block of ONE post at a time. Rung 2 of the scope
  ladder above (fan viewing before fan gestures, read-only + maybe `chooseVariant`) is the
  matching leaning — her refinement narrows it further, which the data model supports
  trivially (the FanPanel's queries are platform-neutral).

## Prerequisites from earlier phases (check before planning)

- **Pull-to-head windowing (Phase 12):** the phone syncing a mature corpus needs it; a full
  iOS surface multiplies phone-side store size and makes it mandatory, not optional.
- **Idle/background sync posture:** Phase 8 deliberately left background execution unsolved;
  a full mobile surface is where real usage evidence decides whether BGTaskScheduler work
  is warranted.
- Phone-side memory budgets: the Mac's "one live editor" P3 discipline matters *more* here,
  not less.

## Tradeoffs to frame with the author (not pre-answered)

- iPhone editor: is a full block editor on a 6" screen even the product? (Capture + reading
  + fan-viewing may be the honest phone shape; the iPad may be the true second editor.)
- Whether mobile gains the pool/references, or stays a writing-and-reading surface.
- Web (the someday row) reuses the same decision framework: WASM SQLite + the pure core —
  worth re-checking this sketch's assumptions if web ever activates first.
