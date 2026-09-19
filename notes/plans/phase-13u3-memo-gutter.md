# 13u3 memo — COMMENTS & CALLOUTS IN THE GUTTER (item 3's design memo, per P-5)

**Written 2026-09-18 by the 13u3 architect, BEFORE unit A builds.** The friction doctrine fired:
the comments area has had the small-add-box complaint (2026-08-21), then 17p-b's lane build to
R-Q4, then her reversal (2026-09-14, the master plan's item 20) — three engagements, so the
feature gets its design on paper and her rulings on the edges before another line lands.

**Her rulings, verbatim, in force:**
- Item 20 / R-13u-9 (2026-09-14): *"I approved comments moving all of the text to the right but
  now that I see it, I think it's ugly and weirdly spaced. I think comments need to make use of
  the whitespace gutter and should never have an impact on moving the actual text around - same
  with callouts, it can exist outside the text area but it's ugly and weird to have it inside the
  text or moving it. the comments still also aren't spaced well."*
- Item 3 (2026-08-21): *"the comment add box is so small and it doesn't make sense given how big
  the overall comment box is that the whole thing isn't more of the text editor that you can
  write and click on."*
- Standing: R9 (sacred margins — the gutter is whitespace the page already owns, not new chrome);
  R7 (margin cards default, inline strips a setting); R5-3 (comments on the LEFT); the 13l 8c
  rider (no add-invitation in the margin); R17 (the callout wash keeps white-gap breathing room).

## §1 What is true today (the mechanism, traced)

Decorations are overlay subviews OF THE TEXT VIEW (`BlockDecorOverlayController`; the ~0.04 ms
budget; never rendering attributes). So a decoration only has room the text view's own bounds
give it. Three surface geometries exist:

1. **Write's full editor:** the text view spans the window; `EditorTypography.gutterInset`
   centers the prose column (floor `minGutter` = 28). Decorations draw in the real gutter INSIDE
   the view. Comments: margin cards when `textLeft ≥ 150`, else the 32×16 count badge.
2. **The contained surfaces** (the book Outline's inline editor + the read tier, which is also
   the workspace read-cheap pane, the note window's read face, and the spread/paged book): the
   text view IS the column (`maxColumnWidth + 16`), centered by SwiftUI; its own inset is 8. There
   is no room inside the view, so 17p-b's lane MOVED THE TEXT right by 64 (`reservesDecorLane` →
   `DecorLaneReservation`) whenever the note carries a comment or callout glyph — the thing she
   reversed. Without the lane, `textLeft = 8`: cards never fit, the badge clamps at x = 2 over
   the prose's edge (the pre-17p defect).
3. **The callout:** a tinted wash behind the block (extends `calloutLeadingPad` left of the text)
   + a leading glyph in a FIXED 18×17 box; a multi-glyph `promptEmoji` answer CLIPS (KnownIssues
   row 50's second residual). At Write's `minGutter` there is no badge room beside a glyphed
   callout (row 50's first residual).
4. **The comments panel** (`CommentsPanel`, 440×320 min): a `List` of rows + a ONE-LINE
   `TextField` (grows to 4 lines) at the bottom — the "add box so small" she named. Editing a
   comment swaps the row for another bordered `TextField`.

## §2 The design (behavior whole)

**The one law: the prose column's measure and LEFT EDGE are decided by the surface's width and
NOTHING ELSE.** No decoration — comment, badge, callout, glyph — may move them, on any surface,
ever. (The pin that replaces the lane cells: render the same note with and without a comment and
a glyphed callout on every surface kind — `textLeft`, `textRight`, and every fragment's origin
byte-identical.)

**A — one gutter geometry family (the mechanism decision, the architect's).** The contained
surfaces adopt WRITE'S OWN SHAPE: the text view's FRAME absorbs the host row's whitespace (the
centering leftover that SwiftUI keeps today), and the text container's origin is computed so the
prose column sits EXACTLY where the centered column puts it now — `containerWidth =
min(maxColumnWidth, viewWidth − 16)`, byte-identical to today's clamp-then-inset at every window
width, so **measures and therefore HEIGHTS are unchanged and `BookHeightManifest` needs to learn
nothing** (the 13u2b warning honored by construction). Decorations then draw in real room inside
the view on every surface, exactly as Write always has. `DecorLaneReservation` retires whole
(both reserve roads dead); `onProseColumnChanged` (W-1's second pass) retires with it — the
prose column no longer moves for decorations, which was its only occasion. The `BlockDecorLane
Tests` cells flip to pinning the one law above.
  - *Mechanism riders:* the pane surface's width-gated remeasure must gate on the CONTAINER
    width, not the view frame width (else every window resize re-measures at wide windows where
    the measure did not change); `SurfaceSizeMemory` entries keyed by the old widths simply read
    as absent once and re-measure (recorded, harmless); `updateGutters`' laned-surface
    precondition dissolves with the lane.

**B — comments in the gutter.** The presentation ladder, now uniform across surfaces because the
geometry is uniform: gutter ≥ 150 → the margin CARD (block-top aligned); below that → the count
BADGE; the panel is every face's door (unchanged). Consequence worth saying out loud: the read
tier and book Outline gain real margin cards at wide windows for the first time — that is what
"make use of the whitespace gutter" buys. **Spacing (her "still aren't spaced well"):** cards get
one vertical rhythm — top-aligned to the block's FIRST LINE (not the frame's top), a fixed inner
pad, a minimum air between stacked neighbours so two commented blocks' cards never abut; the
card stops short of the drag-handle lane as today. Built to captures; taste details PROVISIONAL.

**C — callouts in the gutter.** The tinted WASH behind the block stays (a background never moves
text; it is the callout's identity, R16/R17) — but it no longer extends left of the text into
the gutter: the wash hugs the prose column, and the GLYPH moves fully into the gutter beside the
block's first line (the frame's accent, not the text's). At narrow gutters the glyph yields
before the text does (§3, edge 1). Row 50's two residuals dissolve into edges 1–2 below.

**D — the panel becomes a text editor (her item-3 ask).** The comments panel re-forms as ONE
writing surface: each comment is an editable text area in place (click it, type — no bordered
field swap), separated by a hairline + a muted stamp line; below the last comment the ADD AREA
owns ALL remaining space — click anywhere in it and the caret lands, the draft grows as you
type, ⌘⏎ (and the Add button) files it, Esc clears. The panel keeps its doors (deleted fold,
restore) and speaks through the status seam's classed doors. Margin cards stay READ faces that
open the panel — comment editing has ONE home (no second live-text mechanism beside the page;
P-3's spirit).

## §3 The edges (each decided here or asked below)

1. **The narrow gutter — what yields, in what order?** When the gutter cannot hold a card
   (< 150): the badge. When it cannot hold the badge BESIDE a glyphed callout (Write at
   `minGutter` = 28 — row 50's first residual): **proposed — the badge and the glyph STACK
   vertically** (glyph at the first line, badge just below it), so nothing is suppressed and
   nothing touches text at any width. Below even that (a gutter under the badge's own 36):
   badge alone, clamped to the page edge, never over prose. → **HER CALL (Q1).**
2. **The multi-glyph callout answer** (row 50's second residual — "what does 'a leading glyph'
   mean" is hers): **proposed — one grapheme**: `promptEmoji` keeps the first grapheme and the
   field says so; the box stays fixed and the gutter arithmetic stays constant. The alternative
   (a measured box) makes the card change shape with the glyph. → **HER CALL (Q2).**
3. **The inline-comments SETTING (R7's tinted strips)** widens the inter-block gap — it moves
   text VERTICALLY by design. Reading of her law: it governs the DEFAULT presentation; the
   inline setting is a deliberate opt-in and survives unchanged. → **HER CALL (Q3).**
4. **In-place editing on the margin card itself:** NOT built — the card is a read face and a
   door; editing lives in the panel (§2 D). One live-text home. → **HER CALL (Q4).**
5. **Refusals/undo:** unchanged — comment CRUD is the existing ops (`addBlockComment` family,
   seal refusals intact); nothing structural, no undo story changes. The panel's editor look
   changes no semantics.
6. **What the pins become:** the one-law pin (§2's opening) across all surface kinds ×
   {plain, commented, glyphed-callout, both}; the stacked-badge geometry pin at `minGutter`; the
   card-rhythm pin (two adjacent commented blocks' cards never abut); red-on-old where a cell is
   defect-shaped (the #102 sweep pin cells re-verdicted by the new law).

## §4 Acceptance evidence (unit A's, restated from the plan)

The orchestrator's hands-on walk: a commented note, a glyphed-callout note, a
multi-comment block, across Write · book Outline · read tier · note window · spread book, both
voices, both appearances, at wide AND minGutter-narrow windows; the panel exercised as an editor
(click-anywhere, grow, file, edit in place); 13u2b's landing suites green under load (the book
columns' heights untouched); the full suites + tutorial spine green.
