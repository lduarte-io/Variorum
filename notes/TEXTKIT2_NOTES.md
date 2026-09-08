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
- **`NSTextLayoutManager.usageBoundsForTextContainer` is a HIGH-WATER MARK for its container's life** — it grows and never shrinks. After a 30-line take lost 25 lines through the real edit path the property sat at 1189 pt for six main-queue turns while the last laid-out fragment's bottom read 198; typing ten lines back moved the fragments to 608 and the property not at all. Neither `ensureLayout(for: documentRange)` nor an explicit `invalidateLayout(for: documentRange)` ahead of it moved the number. Only a fresh text container (a remount — her "empty gap… until you switch modes") starts the mark over. **The rule:** anything sizing a surface from that property inherits the ratchet; the pane component's ONE measurement brain (`PaneMeasurement`) now reads the laid-out fragments' bottom, falling back to the property only for the empty document (the one shape where the two differ). Eight steady-state shapes measured identical between the two readings; 0.58 vs 0.41 ms at 400 lines. The full-document editor was NOT examined (13u2 item 1's pane-stability trace starts there).

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
