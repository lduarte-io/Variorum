# Design memo — the pane layer × LONG content × TextKit 2 (P-5)

**Written by the A47c session (2026-07-27), mandated at the A47c record
in `notes/plans/phase-13c-book-forms-and-conversions.md` — the author
invoked the friction doctrine (P-5) after three bugs in one layer in one
day (the phantom estimate · the stale frame · the draw gap). This memo
is the layer's behavior WHOLE, its edges enumerated on paper, and a
plain-language tradeoff list. HER rulings decide; nothing beyond the
A47c stabilization (commit `3eb8fe3`) is built.**

**Owner when built: Phase 13d** (or wherever she slots it). The
stabilization is already in the 13c line; this memo governs whether the
layer gets a deeper shape.

---

## 1. The facts the trace established (the memo's foundation)

Everything below was measured in the REAL mounted `TakesBoardView`
(pixel truth by layer-contents composite; per-fragment surface censuses;
full experiment log in the A47c session record). These are facts, not
readings:

1. **How a pane draws.** A TK2 `NSTextView` renders text through
   per-fragment RENDERING SURFACES (`_NSTextContentView` /
   `_NSTextRenderingSurfacesGroupView` child layers, one per laid-out
   paragraph fragment), created **only for the current viewport region**
   by viewport layout. Content outside the viewport has layout *and no
   drawing* — that is TK2's design, and it is why the pane is cheap.
2. **The pane has no viewport of its own.** Our pane is CONTENT-SIZED
   (a 676×2,753 pt view for an ~800-word take) inside SwiftUI's scroll.
   TK2 derives its viewport from the visible rect — correctly, in every
   state we drove. The viewport notion was **never wrong** in the trace.
3. **The kill.** A **full-range storage attribute write** on a
   tail-scrolled long pane **destroys the rendering surfaces above the
   pane's tail** (14 → 6 surfaces; only the last ~274 pt kept) and TK2
   never rebuilds them unprompted: `viewportBounds` stays correct,
   `needsDisplay` is powerless (the surfaces are the unit of drawing,
   not the backing store), idle delivers nothing, clicking back in
   delivers nothing. Text that is laid out, measured EXACT, and
   selectable renders blank except its last lines — **permanently**.
   This is her worst-case screenshot ("the text stays visibly gone …
   except for two lines at the bottom"), and it is the same
   laid-out-but-undrawn state behind 1G's deletion deception (she
   selected and deleted real prose that photographed blank).
4. **The production trigger.** `applyStyle` ran `view.textColor = ink`
   on EVERY `updateNSView` — a full-range attribute write per SwiftUI
   update of every tokened pane, i.e. per click, per ring move, per
   projection delivery. Bisected at the tail: measurement, editability,
   first-responder moves, and selection are all innocent; the textColor
   write kills. (The standalone minimal composition would NOT reproduce
   the strand — it is real-board-composition-dependent, which is why 1F
   and 1C, driving standalone replicas, could not see it.)
5. **The heal.** `textViewportLayoutController.layoutViewport()`
   rebuilds the surfaces for the ACTUAL viewport completely — one call,
   6 → 14 surfaces, full ink. A real scroll does the same through TK2's
   own machinery (her observed "scrolling up made it disappear").
6. **The stabilization landed (commit `3eb8fe3`)**, both halves at the
   ONE component (P-3): styling is CHANGE-GATED (same ink ⇒ zero
   writes — the everyday trigger is dead), and the 1G convergence
   occasions (click · scroll-end · ring move) now also restore the
   render tier via one coalesced deferred `layoutViewport()` —
   occasion-gated, so no loop is possible by construction (occasions
   are discrete user events a viewport layout can never cause).
   Verified end-to-end: her exact gesture no longer strands at any
   step; quiescent at idle; both pins revert-red.
7. **Cost shape today.** Every occasion measures via a full-document
   `ensureLayout` — pane-scale by construction, warm ≈ free at 800
   words. The 2C measurement stands as the scaling warning: ordinary
   multi-paragraph prose paginates in ~3.5 ms at 26k words, while the
   SAME text as ONE giant block costs ~1.67 s (CoreText; TK2 has the
   same paragraph-granularity shape). A take is one block by
   definition, so a takes-view pane inherits the single-block cost
   curve — fine at hundreds of words, felt somewhere in the thousands.

**The boundary, stated with the evidence (from the A47c record):** in
every one of these defects the STORE was right. The block model is
untouched by everything in this memo — the overhaul question is about
ONE rendering layer.

## 2. The layer's intended behavior, whole

Every take card, read-tier post, TOC row, Compare cell, canvas card,
and Write-panel pane composes ONE surface (`PaneSurfaceView`). The
contract the layer must uphold, regardless of content length:

- **Text that exists is visible** wherever the composition scrolls it
  into view — drawing is never allowed to disagree with the store or
  with selection (the deception class is the layer's cardinal sin; it
  has now twice cost her real prose-confidence, once real prose).
- **Exactly one live pane** (P3); read panes are cheap; the ring
  migrates on click.
- **Geometry hugs the measurement from both sides** (1F's law), with
  production triggers (1G) and a remedy that cannot no-op (1G).
- **The render tier is re-assertable** on the same occasions (A47c).
- **Cost ∝ what is on screen** (P1): measurement is pane-scale; drawing
  is viewport-scale; idle is free.
- **She is never forced to restructure to dodge the renderer** (her
  A45 note, carried in the A47c record): the model's upper levels
  (this take should be blocks; this block should be a post) are the
  *pressure valve* for content that outgrew its level — A21 is the
  repair tool — but the layer must handle a long take gracefully
  regardless. Gracefully may mean a bounded PRESENTATION (a capped
  card), never a refusal and never data loss.

## 3. The edges, enumerated

Compositions of the one surface today, and how long content meets each:

| Surface | Composition | Long-content exposure |
|---|---|---|
| Takes stack article cell (her card) | free-height pane in the board's scroll | THE exposed case — traced above |
| Stack fan cards (`CollapsibleTakeCard`) | free-height | same class as the article cell |
| Rail/strip mini cards | **capped** (S4-31b: fixed height, in-card ScrollView) | bounded by design; the divergence check never fires (the cap wraps AROUND the pane); natural heal events constant |
| Carousel / margin grid / slot split cells | free-height | same class; margin grid also has the reserved-rail slab history (AD-7) |
| Compare cells (lenses across posts) | free-height, up to 4 columns | same class, multiplied by columns |
| Read tier (post views) | free-height per post, virtualized list | same class; posts can be far longer than takes |
| Block TOC expanded rows | free-height | same class; 1G's ladder focus asked whether these idle differently — unresolved, carried below |
| Write takes panel | free-height in a side panel | same class, narrower |
| Canvas cards | bounded realization (4E) + editable cards | card sizes bound the viewport naturally |
| Tutorial samples | short by construction | negligible |

Behavioral edges any deeper design must answer on paper:

1. **Caret reachability in a capped card.** A live pane inside a cap
   must keep the caret visible while typing at the end (the in-card
   scroll must follow the caret — the S4-31b cards are read-mostly
   today).
2. **Selection across a cap.** Select-to-copy beyond the visible
   region of a capped card (drag-scroll inside the card) — works in a
   ScrollView-wrapped NSTextView, but must be verified against the
   ratified read contract (Phase 10: select + copy per post).
3. **The full-range invalidation class** (the kill's family): voice
   switches (font re-attribution over the whole storage), read-pane
   string adoption (projection catch-up), ink changes. All legitimate;
   all can strand a tail-scrolled free pane between occasions. The
   landed heal covers the next user event; a voice switch while idle
   on a scrolled card can still show a transient blank until she
   clicks or scrolls. (Residual, recorded; a render restore after the
   font-swap branch is one line if her use ever surfaces it.)
4. **Measurement cost at extreme take sizes.** Occasions measure via
   full ensureLayout; at a many-thousand-word single take this becomes
   click-latency (the 2C single-block curve). Any threshold below
   should also gate HOW OFTEN the layer measures.
5. **The follow-the-scroll takes option (R25)** re-renders takes at
   scroll cadence — more updates, more chances for the invalidation
   class; the change-gate matters here.
6. **Expand-all-fans** multiplies realized free panes; P1 rides the
   virtualization bounds (4E's realization discipline).
7. **TEXTKIT2 §5 drift.** The strand is a TK2-internal behavior. Pin
   A's strand assertion FAILS if a macOS update fixes the cull — by
   design: re-run the A47c experiments after every point release and
   retire mechanisms deliberately, never silently.

## 4. The options, costed honestly

### (a) Capped card height with in-card scrolling for long takes

The S4-31b fixed-strip precedent generalized: a take card taller than a
threshold renders at the threshold with its content scrolling inside
(the cap is a ScrollView AROUND the pane — the exact composition the
rail already ships and 1F/1G proved immune to the divergence class).

- **She gains:** a bounded, predictable card (no 2,700-pt cards
  dominating the stack); a much smaller drawn region (the strand's
  blast radius shrinks to the cap); constant natural heal events
  (in-card scrolling IS viewport layout); the click-latency ceiling on
  huge takes stops growing with take length **for drawing** (measuring
  still walks the take).
- **She loses:** the whole-take-on-the-page reading (her stack is a
  reading surface as much as an editing one); scroll-in-scroll
  friction on the trackpad (real, macOS-mediated, the rail already
  lives with it).
- **Costs:** small build — the composition exists (S4-31b); the new
  work is the threshold, caret-follow for live capped panes (edge 1),
  and selection verification (edge 2).
- **Rulings touched:** R24/S4-31b (extends the fixed-strip rule to a
  new surface class — a product call, hers); R8/R23 honored (still an
  editable NSTextView); P3 untouched.
- **The threshold question (hers):** cap at N screen-heights of the
  board (adaptive) vs a fixed point size vs a word count. A screen
  fraction (e.g. 1.5× the visible board height) reads most honestly —
  "a card never exceeds what you can see plus a bit" — and lives in
  the composition, not the component. Whether the ARTICLE cell (the
  chosen take) caps like fan cards, or only fan cards cap, is also a
  product call: her article cell is the primary reading surface.

### (b) An honest TK2 viewport wired to the outer scroll

Drive the pane's viewport layout continuously from the enclosing
scroll's live position (bounds-change notifications, not just
scroll-END), so drawing always tracks the outer scroll.

- **She gains:** free panes of any length draw correctly under
  continuous scroll, no cap, no presentation change.
- **She loses:** nothing visible.
- **Costs:** the highest-risk option. There is no public API to SET a
  TK2 viewport; "wiring" means calling `layoutViewport()` at live
  scroll cadence for every realized pane — N panes × scroll-frame
  rate — against the subsystem TEXTKIT2 §2 documents as the least
  reliable in the stack (estimation drift, per-point-release
  regressions). And the trace shows the marginal value is small: TK2's
  OWN viewport tracking already handles ordinary scrolling correctly;
  what failed was re-layout after full-range invalidation, which the
  landed occasion-restore already covers at user-event cadence.
- **Rulings touched:** none directly; P1 pressured (per-frame work
  during scroll).

### (c) A CoreText-drawn read tier for long takes; live TK2 only on focus

The 2C paginator precedent: read panes above a threshold render via
CoreText (typeset per paragraph, drawn directly — no TK2 fragment
machinery to strand); the live TK2 editor exists only on the ONE
focused pane (P3's read-cheap made literal).

- **She gains:** read panes become bulletproof against the entire TK2
  strand class AND cheap at any length (2C measured 26k words in
  3.5 ms); the fragility surface shrinks to one live pane.
- **She loses:** free text SELECTION on read panes unless it is
  reimplemented (CoreText has no selection machinery — the Phase 10
  read contract ratified select+copy, so this is a real regression or
  a real build); pixel-parity risk between the CoreText read rendering
  and the TK2 live rendering (a focus click must not visibly reflow).
- **Costs:** the largest build; and a P-3 tension to manage honestly —
  a second rendering brain must live INSIDE `PaneSurface` as a mode
  (never a sibling component) or the one-surface floor 13b built is
  breached.
- **Rulings touched:** R8/R23 survivable (click still upgrades to the
  live editor) but the "everything visible is an editing surface"
  spirit thins; P3 strengthened; Phase 10's select+copy ratification
  challenged.

### (d) The stabilized status quo (what the trace argues, landed)

Content-sized panes + the change-gated styling + occasion-driven
geometry AND render re-assertion — commit `3eb8fe3`, pinned both ways.

- **She gains:** zero further build; the mechanism is understood,
  guarded at trigger and heal, and pinned so regressions and OS drift
  announce themselves (pin A doubles as a TK2 tripwire).
- **She loses:** the class is contained, not eliminated — a
  full-range invalidation between user events can still flash blank
  until the next click/scroll (edge 3); huge takes keep the
  single-block measurement curve (edge 4); very long cards remain
  visually dominant in the stack (the presentation question (a)
  answers).
- **Costs:** none now.
- **Rulings touched:** none.

## 5. Recommendation

**(d) now — it is landed and her falsifier is stated — with (a) as the
designed next step, built in 13d only if her real use still hits draw
weirdness on long cards or when she rules the presentation question on
its own merits.** Reasoning: the trace found ONE mechanism, not a fog —
and it is now closed at both its trigger and its heal, with pins that
make both regressions and OS drift loud. (a) is the only option that
also answers the *presentation* problem (2,700-pt cards dominating the
stack) and it rides a composition the app already ships and has proven
immune to this defect family; its open questions are product taste —
exactly what a sitting settles. (b) is priced out by TEXTKIT2 §2 for
marginal value. (c) is the deep escape hatch — keep it bookmarked
beside STTextView, spend it only if the strand class widens in ways
occasions cannot cover.

**And the A45 note, carried as instructed:** the model's upper levels
are the long-take pressure valve — an 800-word take is often a block
(or a post) trying to get out, and A21 is the migration tool — but that
is HER move to make per piece, never the layer's excuse. The layer
handles what she writes, at any length; the cap (if she rules it) is a
presentation bound, not a nudge.

## 6. Her rulings (the decision list)

1. **Adopt (a) for 13d, defer it, or decline it?** (The
   recommendation: hold (d), pre-approve (a) so 13d can build without
   another sitting if her use asks for it.)
2. If (a): **the threshold** — screen-fraction (recommended: ~1.5×
   the visible board height) vs fixed points vs word count; and its
   home (a setting vs a constant).
3. If (a): **does the ARTICLE cell cap too, or only fan cards?**
4. If (a): **capped-live behavior** — may the live (ring-wearing) pane
   be capped, or does focus un-cap the card while the ring is on it?
5. **The idle-voice-switch residual** (edge 3): live with the
   transient until a user event, or add the one-line render restore to
   the font-swap branch now?
6. **(c)'s bookmark**: agree it stays unbuilt unless the strand class
   widens?
