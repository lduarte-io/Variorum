# TextKit 2 — Known Issues & Cross-Version Flags

A build-companion reference for the native writing app. Organized around *this* app's
architecture (per-block editor, viewport perf invariant, variant/diff highlighting),
not as a generic bug dump. The goal: hit each of these already knowing it's coming.

**Dev context (re-baselined 2026-07-06):** development and acceptance are one machine —
the author's M3 running Tahoe, building against the macOS 26 SDK (Xcode 26). The original
Sequoia-vs-Tahoe two-machine gap is gone; the gap that remains is **point releases** —
TK2 behavior shifts between Tahoe updates, so everything below about per-version
verification still stands, applied to macOS updates on this one machine.

---

## 0. The one mental model to internalize first

TextKit 2 is not a stable target you code against once. NSTextView **silently falls back
to TextKit 1** the instant it encounters something TextKit 2 can't do. When it does, you
lose TextKit 2 behaviors (e.g. view-based attachments) with no error. The set of triggers
is **undocumented and changes release to release** — this is the mechanism behind almost
every "worked last OS, broke this OS" report.

Two consequences:
- Regressions are normal. Things get fixed, then re-break. Example: an observer that was
  broken, then "fixed again in macOS 15.6." Assume nothing carries across versions untested.
- Your test matrix must be **per-OS-version**, not per-feature. Sequoia-correct ≠ Tahoe-correct.

Apple DTS is effectively unresponsive on TextKit 2. The real knowledge base is the
community: Marcin Krzyżanowski's STTextView repo (a TextKit 2 NSTextView reimplementation
with a maintained Apple-bug list), Christian Tietze, and Michael Tsai's blog roundups.

---

## 1. macOS 26 / Tahoe-specific deltas (the Sequoia → Tahoe diffs)

These are the changes that specifically differ on your *target* OS versus your *dev* OS.

- **`.layoutManager` access forces a TK2→TK1 downgrade on macOS 26 — and it's SDK-gated.**
  Accessing `.layoutManager` (a TextKit 1 API) triggers the downgrade on Tahoe, and this is
  *not* triggered for apps built with an older SDK. Because you build against the 26 SDK,
  you inherit the new behavior; you'll only observe it when running on Tahoe.
  - **Clean fix:** never call `.layoutManager` or any `NSLayoutManager` API. Route everything
    through `textLayoutManager` / `NSTextContentStorage` / the viewport controller.
  - **Reported (tentative) escape hatch:** private `NSTextViewAllowsDowngradeToLayoutManager = NO`.
    Private API — fine as a diagnostic or in a self-distributed notarized build; risky for
    App Store review. Don't rely on it as your primary strategy.

- **`includesTextListMarkers` added** to `NSTextList`, `NSTextContentStorage`, and
  `NSWritingToolsCoordinator`. TextKit 1 classes expect the list-marker string *inside* the
  attributed string; TextKit 2 classes do not. If you support lists and ever fall back to
  TK1, the marker string appearing/disappearing is a live inconsistency to guard against.

- **Writing Tools generates tables; TextKit 2 doesn't handle tables.** If you integrate
  Writing Tools (a natural fit for a writing app) and it rewrites a selection into a table,
  TK2 chokes — ironic, since Apple recommends TK2 for the rewrite animation. Decide early
  whether Writing Tools is in scope; if so, budget for the table gap.

- **Inline audio attachments** now play via AVPlayer in NSTextView on macOS 26. Not relevant
  to this app, noted only so it isn't mistaken for something you broke.

- **SwiftUI `TextEditor`** gained find-navigator controls (`findNavigator(isPresented:)`,
  `findDisabled`, `replaceDisabled`) on macOS 26. You're on NSTextView, not TextEditor, so
  this is context only — but relevant if you ever wrap a lightweight read-only view in
  SwiftUI's TextEditor for the "read-cheap" tier.

---

## 2. The viewport / height-estimation problem — CRITICAL for the perf invariant

Your §4 invariant ("cost ∝ viewport, never document/corpus size") rides entirely on TextKit
2's viewport-based layout. This is simultaneously the reason you chose TK2 **and** its least
reliable subsystem. Treat this as an architectural risk to de-risk early, not a late bug.

- Only the visible region is laid out; **total document height is estimated**, and the
  estimate shifts as you scroll and lay out more. `usageBoundsForTextContainer` updates as
  the estimate changes — expect it to move under you.
- Real-world symptoms reported (including in Apple's own TextEdit): unstable scrolling,
  wrong height estimates, scroll position "jumping."
- Accurate frames require `ensureLayout(for:)` over a range covering the whole document,
  which is **resource-intensive (seconds on large docs)** — directly defeating the invariant
  if you reach for it as a fix.
- **Scroll-to-arbitrary-location performantly is essentially unsolved** in TK2.
  `relocateViewport(to:)` is undocumented for this use and unreliable in practice.
- `enumerateTextLayoutFragments` has returned wrong heights on some long documents, breaking
  the ability to scroll to the end (window resize forces a relayout that temporarily corrects
  it). Reproduced on 15.6 / Xcode 16.4.
- FB19698121: undocumented/unexpected behavior in `textViewportLayoutControllerDidLayout`.

**Action:** before committing book-scrub / infinite-scroll to this architecture, build a
throwaway 50k-word single-post scroll-and-jump prototype and run it **on Tahoe/M3**. If
scroll-to-location and stable height can't be made to work there, your book-scrub "page = post"
model needs a different height source (e.g. store an estimated line/char count per block and
drive the scrubber off that, not off live TK2 geometry).

---

## 3. Category bugs to expect (paraphrased from the community bug lists)

Grouped by which of your features they threaten. These are recurring, version-sensitive, and
mostly documented in the STTextView Apple-bug list — reword/re-verify per OS version.

**Selection & navigation** (threatens: split/merge boundary UI, side-by-side)
- Selection resolves incorrectly at certain locations.
- Word-deletion range logic only behaves at end-of-word.
- Assertions have fired on selection when set up with TK2.

**Rendering attributes / live highlighting** (threatens: diff view, variant highlighting,
"badge on fanned blocks," any type-as-you-highlight feature)
- Per-range rendering attributes draw **unreliably** — often don't appear, or appear once
  then stop updating when the range changes. Especially fragile inside SwiftUI via
  `NSViewRepresentable`.
- A crash has been reported in the rendering-attributes draw path (NSRangeException in the
  line-fragment attribute lookup).
- **Implication:** if diff/side-by-side highlighting must be rock-solid, don't drive it purely
  through rendering attributes. Consider highlighting via the attributed string on the
  read-only render tier (where you're not fighting the live editor), and keep the live editor's
  decorations minimal.

**Lists** (threatens: outline view, any bulleted/numbered structure)
- `NSTextList` has been broken since macOS 14 (a regression). Combined with the Tahoe
  `includesTextListMarkers` change, treat lists as a known-rough area.

**Layout & wrapping** (threatens: the core editor feel)
- Long lines don't always lay out/display correctly, and the view "jumps" when text attributes
  update (nasty for anything that restyles on the fly — e.g. applying a highlight as you type).
- Text has been observed **cropped instead of soft-wrapped** on window resize until a relayout
  kicks in.
- An unexpected extra line fragment appears for the last line.

**Insertion point** (threatens: any custom caret)
- Custom `drawInsertionPoint(in:color:turnedOn:)` is **not supported / not called** under TK2 —
  and overriding TK1-era drawing can itself force the fallback to TK1. If you want a custom
  caret, that's a fallback trigger; design around it or accept the system caret.

**Content storage edge cases**
- `NSTextContentStorage.textElements(for:)` has returned no elements while `enumerateTextElements`
  returns them — don't assume the two agree.
- Only `NSTextParagraph`-derived elements work reliably; custom `NSTextElement` subclasses hit
  runtime assertions. Your block model must map cleanly onto paragraph elements.

**iOS 26 measured findings (mobile parity round Stage B, 2026-08-09 — the iPhone editor at a 100k-word fixture; both PINNED in `VariorumMobileTests`)**
- **Exclusion-path PRESENCE alone makes post-edit relayout document-scale.** With even one `exclusionPaths` rect installed — position-independent, content-untouched — each keystroke's relayout measured ~155–300 ms at 100k words vs ~0.5 ms with zero rects, and the height estimate inflated 1.4×. Gutter/margin reservations on iOS therefore ride first-paragraph paragraph styles (`tailIndent` / `firstLineHeadIndent`), and container exclusions are retired-and-pinned on the phone's Write surface. (The Mac editor never used `exclusionPaths`; treat any future use as a perf decision, not a layout convenience.)
- **NSTextStorage attribute FIXING re-propagates the paragraph's governing style across the whole paragraph, terminator included** (`fixParagraphStyleAttribute`'s documented behavior, and `processEditing` fixes automatically — probe-verified). A "write the clamped sub-range only" strategy for paragraph styles is impossible; heal the landing after the edit instead.

**macOS 26 measured finding (Phase 13l Act 3, 2026-08-24 — caught by the hoisted identity-projection audit's FIRST run; pinned in `IdentityProjectionAuditTests`)**
- **`NSTextStorage` attribute fixing on macOS 26 WIDENS the reported edited range to the whole paragraph including its terminator** — a one-character insertion at offset 2 reports `{2, 5}`. This is the macOS twin of the iOS fixing finding above, and it **falsifies, for macOS 26, mobile round 2's recorded "AppKit does not widen"** (that measurement was of the DELEGATE's report road; the fixing road widens on both platforms). Consequence class: any code stamping range-scoped attributes (block identity!) from the POST-FIXING report writes them past the edit — the Mac stamped block IDs onto the following separator on every keystroke for six weeks, latent only because nothing production-reads `blockID(at:)`. **The rule: clamp attribute stamps to the VERDICT's range, never the report's.**

**macOS 26.5.x measured finding (Phase 13e kickoff sweep, 2026-08-18 — pinned in `TakePaneMeasureTests`)**
- **The A47c render-surface cull became LOAD/TIMING-DEPENDENT on this point release.** The 13c-traced class (a full-range storage attribute write destroying a tail-scrolled pane's per-fragment rendering surfaces) no longer reproduces in STANDALONE test runs (all bands stay drawn after the kill; 8+ runs, both lock states) while FULL-SUITE runs still strand — fully in the 13g/13k era, partially (1-of-6 bands) by 13e. This load-dependence was the entire "environment-gated tripwire" mystery: the covariate was suite context, never lock state. The A47c guard machinery (the change-gate + occasion-gated render restore) stays byte-unchanged as regression insurance; the pin now asserts the outcome contract (restore runs + the page ends drawn) rather than any particular kill shape. Treat any future change in this behavior as a point-release delta to re-measure, per §5's matrix.

**macOS 26 measured finding (17o batch c, the use-report round, 2026-09-08 — pinned in `TakePaneMeasureTests.aPaneThatLosesMostOfItsTextShrinksWithinOneTurn`)**
- **`NSTextLayoutManager.usageBoundsForTextContainer` is a HIGH-WATER MARK for as long as the document HOLDS text** — it grows and never shrinks while any text remains; it resets to the empty-line height (22 pt measured) only when the document becomes EMPTY (the c/d/e ladder's deciding pin, `TakePaneMeasureTests.aPaneEmptiedCompletelyDoesNotJumpBackToItsTallestHeight` — green on both sides, so the empty-document fallback is honest). After a 30-line take lost 25 lines through the real edit path the property sat at 1189 pt for six main-queue turns while the last laid-out fragment's bottom read 198; typing ten lines back moved the fragments to 608 and the property not at all. Neither `ensureLayout(for: documentRange)` nor an explicit `invalidateLayout(for: documentRange)` ahead of it moved the number. Only a fresh text container (a remount — her "empty gap… until you switch modes") starts the mark over. **The rule:** anything sizing a surface from that property inherits the ratchet; the pane component's ONE measurement brain (`PaneMeasurement`) now reads the laid-out fragments' bottom, falling back to the property only for the empty document (the one shape where the two differ). Eight steady-state shapes measured identical between the two readings; the per-edit cost against the SHIPPED old body is 0.186 vs 0.191 ms at 200 blocks and 0.574 vs 0.591 at 800 (the batch record's first "0.58 vs 0.41" compared two new-road candidates, corrected at the ladder). Four call sites consume the brain — two panes and two whole-post surfaces (`ReadPostViewModel.remeasure`, `InlineEditorSurface.remeasure`, the latter per keystroke). The full-document editor was NOT examined (13u2 item 1's pane-stability trace starts there).

**macOS 27.0 measured findings (18k, the runtime-hygiene run, 2026-09-25 — pinned in `JumpViewportLayoutTests`, `RefontGapTopTests`, `InlineHeightReportTests`)**
- **`textViewportLayoutController.layoutViewport()` MOVES THE CLIP on 27** by the height change its own layout pass causes (+29 pt / −23.23 pt measured), while the target line stays put — so a jump that scrolls and then lays out lands one line off, and a correction loop that judges convergence against the offset it REQUESTED (not where the clip now sits) reports success anyway. A plain flipped view and a bare `setFrameSize` do not move the clip; only the viewport layout does. **The rule:** after any scroll that is followed by `layoutViewport()`, re-read the clip; `JumpPrimitive.scroll(to:)` re-asserts once (a clamp at a shrunken maximum is not a displacement). `PaneSurface`'s render restore — the other `layoutViewport()` caller — was EXAMINED at 18l-b U3 (2026-09-27): **PROVABLY SAFE on 27.0**. A pane is never vertically resizable nor a scroll view's document, so its pass cannot resize it and moves no clip even over unmeasured growth (adversarial arm: fragments 2055 → 2080 under a fixed frame and a fixed clip); and every production road re-measures before the restore. Pinned as a point-release tripwire: `PaneRenderRestoreClipTests` (the restore reads every enclosing clip on both sides of its call).
- **A layout fragment's frame INCLUDES its paragraph's trailing spacing** (the last paragraph's has none), and `glyphOrigin.y` is the BASELINE measured from the line's top (14 of 17 pt Terminal, 17 of 22 pt Study). Consequence: "the line whose box holds the viewport's top edge" names the PREVIOUS paragraph's last line whenever the edge sits in a paragraph gap. **The rule:** the line being read is the first line whose baseline is on screen, in a paragraph with text (`FragmentLines.readingLineIndex`).
- **After a whole-document re-font, TK2 re-estimates the document height LOW**, and a settle that runs before the next display pass reads the stale frame — so any scroll RANGE computed once from the frame clamps short while the document grows under it (2,368 pt measured). **The rule:** read the maximum scroll live at every use, never once per jump.
- **The first full measure after a view enters its window, after a width change, or after an edit can differ from the settled layout** (11,182 → 10,929; 18,713 vs 19,344; one 20-pt line) — layout-history dependent. Surfaces without a convergence re-report (the inline editor) can keep the unsettled number (KnownIssues: the ~85-pt restore residual, owner 12). **Measured further at 18l U0 (2026-09-26): on 27.0 the inline editor's first full `.ensuresLayout` measure after a reflow can be 1–5 % off the layout the next display pass settles to** (bare rig 631 / 229 / 126 pt at 420 / 700 / 520 pt wide; the app 198 pt on a 23k-pt story), in BOTH directions — **the inline editor now re-reports on the display pass (the settle net: the last fragment's bottom read in O(1), edge-triggered, budget 8 per occasion; `InlineHeightReportTests`), and the ~85-pt residual row is CLOSED by it. Re-measure at 27.1** (the settle net's trigger assumptions are this point release's). Its mechanism, measured at VX-246: out-of-order partial layout (the VX-246 finding below).
- **On 27.0 a layout-forcing read that lays out a NEW paragraph right after an edit — outside any viewport pass — can make TextKit re-estimate the estimated stretch ABOVE a viewport island that floats on estimates** (a full storage replacement, then one island laid out, then ⌘↓) **and re-base the laid-out island in document space (+80…+662 pt measured, 18l-b U-B5) without moving the clip**; the viewport pass compensates the same kind of shift by moving the clip (18k C6), an edit has no such pass. **The rule: a road that writes storage with no restore step keeps the reading line itself** (Write's differential structural rewrite: `keepUntouchedReadingLine`, 18l-b U-B5; pins `WriteFloatingViewportTests` + `UntouchedLineKeeperTests`).
- **TK2 lays out a TRAILING run of blank lines SHORT: the LAST trailing blank line of a paragraph run measures ~10–20 pt less than a full line** (18l-c U5's #154 rider, 2026-09-28 — bare TK2 rig: `"A\n\n"` lays out 50 pt where three full lines stand 66; measured −10 pt Terminal / −20 pt Study in the app). Consequence: a live editor whose block stores ≥2 trailing blank lines (or a newline-only block) stands SHORTER than a resting tier that draws every blank line full — the block below moves UP on going live. Deliberately NOT mirrored into the resting tier (mirroring a wrong height breaks the day TK2 fixes it); pinned LOUD as 4 named known-issue cases (`IndexTierMetricsTests`) that fail if TK2 stops drawing it short. Adjacent measured fact from the same rider: a SINGLE trailing blank line lays out full-height, and TK2's paragraph spacing applies ABOVE the following paragraph too — the pane's style pays `paragraphSpacing = gap − lineSpacing` to draw the read tier's 8-pt gap (`IndexProseColumnTests` measures it in both voices). Re-measure both at 27.1.
- **SwiftUI may DETACH and RE-ATTACH an `NSViewRepresentable`'s view within one layout pass (a lazy column's reveal), and AppKit drops a detached FIRST RESPONDER to the WINDOW** (18l-c U7, 2026-09-28 — traced live: `willMove(toWindow: nil)` while first responder, then re-attach in the same reveal pass). A surface that claims the keyboard once, at attach, loses it silently — the take sits live, selected, on screen, with no keyboard. `PaneTextView` re-takes what it held on re-attach, and only when the window itself holds the keyboard (never steals; read panes never reclaim) — pinned four ways (`PaneFindFaceTests`), found red-first by the ⌘G integration pin.
- **HARNESS fact (the walk/test families): a mounted SwiftUI `ScrollView` whose position is BOUND (`.scrollPosition`) re-applies its last `scrollTo` target on relayout, undoing a programmatic `NSClipView.scroll(to:)`; and a synthesized `CGEvent` scroll wheel sent to its `NSScrollView` does not move it in a test host** (18l-c U8, 2026-09-28). A pin that stages "her scroll" there must END the landing first (`clearArticleLanding()`) and cannot de-realize a row by scrolling — the scroll-away state is staged through its owning door instead (the U8 R-2 restage is the worked example).
- **AppKit's paragraph-style FIXING is decided by OBJECT identity, and content-equal attribute dictionaries are uniqued PROCESS-WIDE** (18k C8). A storage whose paragraph-style object is already the one the fixing would apply reports a 1-char insertion as `{2,1}`, not the widened `{2,5}` this file's macOS-26 finding records — so the 13l widening pin measures object identity, and any surviving text stack in the same process can change its answer. **Test consequence:** a dropped mounted editor can outlive its test, held by the runner's long-lived main-thread autorelease pool under async test bodies; tear down (detach delegates, empty the storage) explicitly.

**macOS 27.0 measured findings (VX-246 U4/U4b/U4c, 2026-10-14 — VX-230's badges; probes 5–13 on bare TK2 rigs; pinned in `FanBadgePlacementTests`' two characterizations, `textKitReportsAnUnlaidFragmentAsZeroAndAZeroRectIntersects` and `textKitPlacesAFragmentLaidOutAheadOfItsPredecessorsOffItsSettledPlace`; the record `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, U4b's and U4c's traces)**
- **An unlaid fragment is no position.** A layout fragment TK2 has not laid out reports `layoutFragmentFrame == .zero` in the `.none` state (an ESTIMATED one reports a guessed frame). A WIDTH change returns every fragment to `.none`, after which a display pass lays out only the viewport and estimates the rest (a guess about 350 pt off on 50 paragraphs). A `.zero` rect offset by the container origin `intersects` any rect holding that point (CGRect's degenerate-rect rule), so unlaid blocks' badges piled at the first block (VX-230's dark disc). **The rule:** a frame read with `options: []` is a position only in `.layoutAvailable`.
- **A layout that runs AHEAD of unlaid predecessors poisons the next whole walk.** A mid-document `.ensuresLayout` enumeration, or a viewport pass over a mid-document window, places those fragments at estimated offsets, and a following whole `.ensuresLayout` walk does NOT re-position them (996 pt off cold, 1,662 pt after a 700 → 420 width change, 1,600 pt after a scrolled-deep pass, on 120 paragraphs). The next viewport pass re-positions every fragment to the settled layout, and a whole walk with nothing laid out ahead of it is exact. This is the mechanism of the 18l first-measure finding above. **The rules:** never force layout from a mid-document location on a whole-post surface; read geometry after the whole walk, and again after the settle net's heal (the inline editor re-runs its badge pass at the end of every remeasure, the heal's included). Re-measure at 27.1.
- **HARNESS fact (the walk/test families): a run loop nested in a main-actor test runs no main-queue hop.** Swift Testing runs a `@MainActor` test's body as a main-actor job, inside a main dispatch queue callback, and a run loop nested there (`RunLoop.main.run(until:)`) services display passes and timers but runs NO `DispatchQueue.main.async` block; an `await` (one `Task.yield()`) does. A pin that pumps the run loop and expects a queued hop (a remeasure, an overlay settle, the settle net's heal) to have run is reading the transient before it (probe 11; the sweep of such pins is VX-333).

**Spell check / completion**
- Continuous spell checking + the word-completion popover has crashed NSTextView (reproducible
  with the debugger attached). Have a toggle to disable continuous spell checking while
  diagnosing crashes in the editor.

---

## 4. Defensive practices & flags — set these from the first editor commit

1. **Opt into TK2 explicitly at init**: use the `NSTextView(..., usingTextLayoutManager: true)`
   constructor. Don't rely on the default.
2. **Never touch TK1 APIs**: no `.layoutManager`, no `NSLayoutManager`, no TK1-era overrides.
   Each is a potential silent-downgrade trigger, and one of them (`.layoutManager`) is a
   *guaranteed* trigger on macOS 26.
3. **Install the fallback canary**: subscribe to `willSwitchToNSLayoutManager` /
   `didSwitchToNSLayoutManager` and log + assert. A fallback should never happen silently in
   your build; if it does, you want to know exactly which edit/attachment/API triggered it.
4. **Map blocks to paragraph elements**: keep block boundaries snapping to paragraph/sentence
   marks (already your plan) so you never need a custom `NSTextElement`.
5. **Keep decorations off the live editor** where you can: highlight/diff on the read-only
   render tier; the live `NSTextView` should carry as little custom rendering as possible.
6. **Deployment target is macOS 26** (author decision 2026-07-06, no older-OS support):
   build SDK, deployment target, and the machine you run on all match, so SDK-gated
   behaviors (like the `.layoutManager` downgrade) are always live in what you test —
   nothing hides until a customer's OS reveals it.

---

## 5. Per-version test matrix

Because behavior is version-gated, validate the editor core against, at minimum:

| OS | Where | What it proves |
|----|-------|----------------|
| Tahoe, current install (M3 — dev = acceptance) | build + iterate + run the real app | everything: logic, fallback behavior, viewport perf, Liquid Glass |
| Tahoe, after each point-release update | same M3, re-run the milestone checks | catches TK2 regressions introduced mid-cycle — never trust a pre-update result |

For each editor milestone (and after each macOS update), re-run: (a) does it ever silently drop to
TK1 (canary), (b) does scroll-to-location + height stay stable on a 50k-word post, (c) do
live highlights draw and update, (d) do split/merge selections resolve correctly at boundaries.

---

## 6. Strategic escape hatch

Several serious text-editor developers have concluded TK2 is not the right tool for a heavy
editor and either dropped to CoreText + a custom layout manager, adopted **STTextView** (which
has already worked around most of the bugs above), or left the native stack entirely. You have
good architectural reasons to stay on TK2 — viewport lazy layout is exactly what your perf
invariant needs — so this isn't a reason to switch. But keep STTextView bookmarked as both a
reference implementation and a drop-in fallback: if the viewport/scroll work in §2 proves
intractable on your timeline, adopting its layer is far cheaper than building a CoreText engine
from scratch.

---

*Sources: Marcin Krzyżanowski (STTextView repo + "TextKit 2 — the promised land"),
Michael Tsai's blog roundup, Christian Tietze, Apple's WWDC22 "What's new in TextKit and text
views," and Apple Developer Forums threads. Re-verify any specific FB item against the current
OS build before designing around it — status flips between releases.*
