//
//  LongBlockLayout.swift
//  Variorum
//
//  Phase 13c, Batch 1E — the PHANTOM FIX (memo option E, PROVISIONAL).
//  `notes/plans/phase-13c-memo-block-extent.md` Part 2 / Q3.
//
//  ── What it is ────────────────────────────────────────────────────────
//  TextKit 2 lays out only what it must and GUESSES the height of every
//  paragraph it has not laid out (TEXTKIT2 §2; AppSpec §15 risk 2). A
//  Variorum block is always its own paragraph (R26/R33), so ONE very long
//  block is ONE very large guess — batch 1A measured a 3,000-word block
//  reporting 4,964 pt while estimated against 4,597 pt once laid out: 367
//  pt (~21 lines) of space that is not there, which vanishes when you
//  scroll onto it and returns when you scroll away. That is the author's
//  A3/A4/A41 report, and batch 1C proved (real mouse events, real windows)
//  that the space belongs to the editor and behaves correctly — there is
//  no click bug behind it. Removing the phantom is the only remedy.
//
//  So: when the viewport is looking at — or is about to reach — a block
//  whose layout TK2 has only estimated, ask for layout of THAT ONE
//  BLOCK'S OWN TEXT RANGE, once. Its over-guess collapses. Batch 1C
//  measured the cost and the persistence:
//
//      1,000 w → 1.27 ms (180 pt removed) · 3,000 w → 2.90 ms (537 pt)
//     12,000 w → 11.52 ms (2,169 pt)      · 25,000 w → 20.06 ms (4,549 pt)
//
//  Per-word cost is FLAT-TO-IMPROVING in block size, and TK2 does not
//  discard the layout — so this is once per block per surface, never a
//  treadmill.
//
//  ── What it is NOT, and why the discipline below is not optional ──────
//  It is not document-scale layout. P1 binds cost to "what's on screen and
//  what's being edited"; laying out the block the viewport is looking at
//  is exactly that, and full-document layout (105 ms @ 50k words, Phase 6
//  spike) is what P1 bans. **The cost is not the danger — the TRIGGER is.**
//  A once-per-block 3 ms is nothing; the same call firing repeatedly is a
//  real P1 problem. Four guards make the bound structural rather than
//  hoped-for:
//
//   1. A hard block-size CAP (`maxBlockUTF16Length`) — above it, skip and
//      record. Reasoning on the constant itself.
//   2. At most ONCE per block per surface (`handled`), pinned. TK2 keeps
//      the layout, so a second call is pure waste AND the symptom of a
//      trigger bug — the pin is the guard against exactly that.
//   3. A KILL SWITCH (`settingKey`), default on, so the author can turn it
//      off having FELT it. Q3 stays hers.
//   4. A size FLOOR (`minBlockUTF16Length`) — an ordinary post of ordinary
//      blocks performs ZERO layout calls, ever. The calm default costs
//      nothing (the `refreshDecorations` doctrine).
//
//  Plus: ONE block per pass (a pass can never exceed the cap's cost), the
//  work runs after scrolling SETTLES rather than during it, and the whole
//  thing is scoped to the DETAIL editor — the surface that owns a viewport
//  smaller than its document. The inline/book editor is sized to content
//  by its wrapper, so "the block the viewport is looking at" would mean
//  every block, which is the document-scale work P1 forbids; and the pane
//  surfaces measure honestly already (`PaneMeasurement` lays out first —
//  1C's finding).
//
//  PROVISIONAL in full: QUESTIONS #39. The memo's Q3 posture call is the
//  author's, and this exists so she rules having felt it rather than from
//  a table of numbers.
//

import AppKit
import Foundation

// MARK: - The pure planner

nonisolated enum LongBlockLayout {
    /// The kill switch's UserDefaults key (LOCAL to this Mac — the
    /// `writeHoverHandles` class, deliberately not the synced `setting`
    /// table: this is a rendering behaviour on one machine's editor, not
    /// document semantics). Absent ⇒ ON.
    static let settingKey = "longBlockLayout"

    /// **The hard cap, in UTF-16 units of one block's text.** Above it the
    /// block is skipped and recorded — never a hitch the author would feel.
    ///
    /// Derivation, from batch 1C's measured table converted onto the axis
    /// this code can actually check for free. The measurement corpus's
    /// words are `"longword\(i % 97)"` joined by single spaces = 10.897
    /// UTF-16 units per word, so:
    ///
    /// | words | UTF-16 units | measured | ms per 1k units |
    /// |-------|--------------|----------|-----------------|
    /// | 1,000 | 10,897 | 1.27 ms | 0.117 |
    /// | 3,000 | 32,691 | 2.90 ms | 0.089 |
    /// | 12,000 | 130,764 | 11.52 ms | 0.088 |
    /// | 25,000 | 272,425 | 20.06 ms | 0.074 |
    ///
    /// Worst observed rate: **0.117 ms per 1,000 units**. The budget is
    /// **half a 60 Hz frame (8.3 ms) in a DEBUG build** — half a frame so
    /// the same runloop turn has room for everything else, and Debug
    /// because the shipped Release build is faster, which is margin on top
    /// of margin. 8.3 ÷ 0.117 ≈ 71,000 units; rounded down to 64,000, whose
    /// predicted worst case is **7.5 ms** (≈5.7 ms at the measured
    /// mid-range rate). The architect's own note — "20 ms at 25,000 words
    /// is already past a frame budget" — is honoured with ~4× of room.
    ///
    /// In her prose (~5.5 UTF-16 units per word with spaces) the cap is
    /// roughly **11,600 words in a SINGLE block** — orders of magnitude
    /// past the long pasted message she reported, so the cap is generous
    /// exactly where it matters and hard where it would hurt.
    ///
    /// Why UTF-16 units and not words: the length is already in
    /// `BlockRangeIndex.Entry`, so the check costs nothing. Counting words
    /// would mean reading each candidate block's text on every scroll —
    /// the P1 mistake this feature exists to avoid.
    static let maxBlockUTF16Length = 64_000

    /// **The floor.** Below it a block's over-estimate is a few points and
    /// the errors of neighbouring short blocks mostly cancel (1A: "the
    /// size of the problem is set by your single longest block"), so
    /// laying it out buys nothing. ~2,000 units ≈ a long paragraph (~350
    /// words), whose layout is ~0.25 ms. The real work this constant does
    /// is on the TRIGGER: an ordinary post of ordinary blocks produces
    /// zero layout calls for its whole life.
    static let minBlockUTF16Length = 2_000

    /// How far past the visible rect a block still counts as "the viewport
    /// is looking at it", in viewport heights. Non-zero is what makes this
    /// do anything: a block strictly INSIDE the viewport has already been
    /// laid out by TK2's own viewport layout — the estimated ones are the
    /// ones just below, and they are what inflate the document. One
    /// screenful is the bounded, natural reach.
    static let lookAheadViewports: CGFloat = 1

    /// Hard bound on per-pass fragment lookups, so the scan can never walk
    /// a document (the `refreshDecorations` cost model: cheap array walk,
    /// bounded lookups).
    static let maxLookupsPerPass = 64

    /// One block the scan considered.
    struct Candidate: Equatable {
        let entryIndex: Int
        let blockID: String
        /// The block's own range in the surface (UTF-16).
        let range: NSRange
        /// True once TK2 has really laid this fragment out
        /// (`NSTextLayoutFragment.State.layoutAvailable`).
        let laidOut: Bool
    }

    /// What one pass decided. `layOut` is at most ONE block — a pass can
    /// never cost more than the cap.
    struct Plan: Equatable {
        var layOut: Candidate?
        var skippedOverCap: [Candidate] = []
        /// Another eligible block is waiting behind the one taken, so the
        /// driver re-arms for one more pass. False ⇒ the chain ends here
        /// and no trailing empty pass is scheduled.
        var moreRemain = false

        var isEmpty: Bool { layOut == nil && skippedOverCap.isEmpty }
    }

    /// The decision, pure: the NEAREST not-yet-laid-out, big-enough
    /// candidate that fits under the cap and has not already been handled
    /// AT THIS WIDTH. Candidates over the cap are passed over and recorded
    /// (the scan keeps looking — a nearer block that cannot be helped must
    /// not hide a further one that can).
    ///
    /// `handled` maps a block to the container width at which this surface
    /// last dealt with it; `width` is the current one. See
    /// `LongBlockLayoutState.handled` for why the key is a width.
    static func decide(
        candidates: [Candidate],
        handled: [String: CGFloat],
        width: CGFloat,
        cap: Int = maxBlockUTF16Length,
        floor: Int = minBlockUTF16Length
    ) -> Plan {
        var plan = Plan()
        for candidate in candidates {
            guard !candidate.laidOut,
                  handled[candidate.blockID] != width,
                  candidate.range.length >= floor
            else { continue }
            if candidate.range.length > cap {
                plan.skippedOverCap.append(candidate)
                continue
            }
            guard plan.layOut == nil else {
                // ONE per pass — this is the frame-budget bound. A second
                // eligible block only sets the re-arm flag.
                plan.moreRemain = true
                break
            }
            plan.layOut = candidate
        }
        return plan
    }

    /// The entry containing `offset`, by the tiling's own arithmetic (each
    /// entry followed by exactly one separator character).
    static func entryIndex(
        containingOffset offset: Int, entries: [BlockRangeIndex.Entry]
    ) -> Int? {
        guard offset >= 0 else { return nil }
        var location = 0
        for (i, entry) in entries.enumerated() {
            if offset <= location + entry.length { return i }
            location += entry.length + 1
        }
        return entries.isEmpty ? nil : entries.count - 1
    }
}

// MARK: - The per-surface state

/// Everything the phantom fix remembers for ONE editor surface. Scope is
/// deliberate: a fresh surface is a fresh TK2 layout world, so a fresh
/// surface genuinely must do the work again.
@MainActor
struct LongBlockLayoutState {
    /// Blocks this surface has DEALT WITH — laid out, or skipped over the
    /// cap — **each recorded against the CONTAINER WIDTH it was dealt with
    /// at.** A block is eligible again only at a width it has not been
    /// handled at.
    ///
    /// **Why a width and not a flag — the batch measured it, and the
    /// architect ruled on it (2026-07-26).** 1C found that TK2 keeps a
    /// block's layout across scroll travel, and the brief's "at most once
    /// per block per session" was written on that basis. A **WIDTH REFLOW
    /// is not the same**: measured this batch, a laid-out 3,000-word block
    /// goes straight back to ESTIMATED when the column narrows (7,300 pt →
    /// 11,492 pt guessed, a *worse* over-guess than it started with). Under
    /// the literal once-per-session rule the phantom therefore returned on
    /// her first sidebar toggle and was never corrected again — a fix that
    /// silently stops working. The architect's ruling, recorded because the
    /// reasoning matters more than the outcome: the rule's purpose was
    /// never the word "session", it was to stop the same work being redone
    /// **wastefully**, and re-laying out a block whose layout TK2 has
    /// genuinely thrown away is the same bounded work for a NEW STATE, not
    /// waste. New information, same principle.
    ///
    /// **What still bounds it, so this is not a widening of the trigger:**
    ///
    ///  · the `laidOut` check gates every candidate, so a width change that
    ///    did NOT discard the layout costs nothing at all — re-eligibility
    ///    only *permits* the work, TK2's own state decides whether any is
    ///    needed;
    ///  · one pass per **SETTLED** width, never per width sample. A divider
    ///    drag emits a continuous stream of widths; the debounce below
    ///    (already the scroll path's) coalesces every one of them into a
    ///    single pass after the drag stops. Pinned
    ///    (`aWidthDragProducesOnePassAtTheSettledWidth…`) — this is the
    ///    guard on the failure the ruling explicitly worried about;
    ///  · everything else is unchanged: the cap, the floor, one block per
    ///    pass, the reach bounds, detail-editor-only, the kill switch.
    ///
    /// Termination still holds: within one width, the map only grows, so
    /// each pass consumes one block from a shrinking set.
    ///
    /// A block EDITED after being laid out is deliberately not revisited:
    /// editing means the caret is in it, and typing lays it out anyway
    /// (measured — an insertion leaves it `layoutAvailable`).
    var handled: [String: CGFloat] = [:]
    /// Test-visible: how many `ensureLayout` calls this surface has made.
    /// The once-per-block-per-width pin reads this.
    var layoutsRun = 0
    /// Test-visible: how many passes have RUN. The drag pin reads this —
    /// "one pass per settled width, never one per sample" is a statement
    /// about passes, not just about layouts.
    var passesRun = 0
    /// Test-visible record of the blocks skipped for exceeding the cap
    /// ("skip and RECORD"). Deliberately not surfaced to the author: a
    /// "this block was not optimised" message is developer noise about a
    /// cosmetic nicety, and the kill switch is her real control.
    var skippedOverCap: [String] = []

    /// The debounce: the work runs after scrolling SETTLES, never during
    /// it. A 7 ms hop inside a live scroll is a dropped frame; the same
    /// hop when the viewport stops is invisible. (The `tailIdleSleep`
    /// seam's shape, for the same reason: deterministic tests.)
    var debounce: Duration = .milliseconds(150)
    var sleep: @Sendable (Duration) async throws -> Void = { try await Task.sleep(for: $0) }
    /// Injectable so tests never touch the real defaults domain.
    var defaults: UserDefaults = .standard

    var task: Task<Void, Never>?
    /// Re-entrancy guard: the layout call provokes a display pass, which
    /// reaches the overlay family — nothing there can call back into a
    /// pass, and this makes that structural instead of assumed.
    var running = false
}

// MARK: - The driver

extension EditorViewModel {
    /// The kill switch (default ON — she must be able to feel it before
    /// ruling on Q3).
    var longBlockLayoutEnabled: Bool {
        longBlockLayout.defaults.object(forKey: LongBlockLayout.settingKey) as? Bool ?? true
    }

    /// The container width this surface currently lays out against — the
    /// quantity a re-layout is keyed on, because it is what TK2's layout
    /// actually depends on. Derived from the view rather than read off the
    /// container so it tracks the dynamic gutter (`updateGutters`) exactly;
    /// rounded, so sub-pixel jitter is not a new width.
    var longBlockLayoutWidth: CGFloat {
        guard let textView else { return 0 }
        return (textView.bounds.width - 2 * textView.textContainerInset.width).rounded()
    }

    /// The TRIGGER, debounced. Called from the geometry events that mean
    /// "the viewport is looking somewhere new, or at something newly
    /// re-estimated": a scroll (`ScrollAnchorController.boundsChanged`) and
    /// the post-layout settle that follows attach, a storage change, **or a
    /// width reflow** (`overlayLayoutDidSettle` — the N14 delivery law's
    /// own hop, already wired to all three axes, so an opened post is
    /// honest without requiring a scroll and a resize is noticed without a
    /// second mechanism).
    ///
    /// **The debounce is what makes the width axis safe.** A divider drag
    /// emits a continuous stream of widths, each re-arming this and
    /// cancelling the last, so exactly ONE pass runs — after the drag
    /// stops — never one per sample. That is the architect's hard
    /// requirement on the 2026-07-26 ruling, and it is the existing scroll
    /// machinery reused rather than a second timer.
    func considerLongBlockLayout() {
        longBlockLayout.task?.cancel()
        guard longBlockLayoutEnabled, scrollView != nil else { return }
        longBlockLayout.task = Task { [weak self, sleep = longBlockLayout.sleep,
                                       debounce = longBlockLayout.debounce] in
            guard (try? await sleep(debounce)) != nil else { return }
            guard !Task.isCancelled else { return }
            self?.runLongBlockLayoutPass()
        }
    }

    /// ONE pass: scan the viewport (plus one screenful of look-ahead) for a
    /// block TK2 has only estimated, and lay out that one block's own text
    /// range. Internal so tests drive it deterministically.
    @discardableResult
    func runLongBlockLayoutPass() -> LongBlockLayout.Plan {
        guard longBlockLayoutEnabled, !longBlockLayout.running,
              // Detail editor only (the header's scoping note): the inline
              // editor has no viewport smaller than its document.
              let textView, let scrollView,
              let layoutManager = textView.textLayoutManager,
              let contentManager = layoutManager.textContentManager,
              !index.entries.isEmpty
        else { return LongBlockLayout.Plan() }

        longBlockLayout.running = true
        longBlockLayout.passesRun += 1
        defer { longBlockLayout.running = false }

        let width = longBlockLayoutWidth
        let plan = LongBlockLayout.decide(
            candidates: longBlockCandidates(
                textView: textView, scrollView: scrollView,
                layoutManager: layoutManager, contentManager: contentManager),
            handled: longBlockLayout.handled,
            width: width)

        for skipped in plan.skippedOverCap {
            longBlockLayout.handled[skipped.blockID] = width
            // Recorded once per block, not once per width — the record is
            // "this block is past the ceiling", which no resize changes.
            if !longBlockLayout.skippedOverCap.contains(skipped.blockID) {
                longBlockLayout.skippedOverCap.append(skipped.blockID)
            }
        }

        guard let target = plan.layOut else { return plan }
        // Marked handled BEFORE the call, so even a throwing/odd AppKit
        // path can never leave a block eligible for a second attempt at
        // this width.
        longBlockLayout.handled[target.blockID] = width

        let docStart = contentManager.documentRange.location
        guard let start = contentManager.location(docStart, offsetBy: target.range.location),
              let end = contentManager.location(start, offsetBy: target.range.length),
              let range = NSTextRange(location: start, end: end)
        else { return plan }

        layoutManager.ensureLayout(for: range)
        longBlockLayout.layoutsRun += 1

        // THE REFRESH NUDGE — 1C's measured caveat: the scroll extent does
        // NOT shrink synchronously with the layout call. Measured this
        // batch, on the real thing rather than assumed:
        //
        //   · a DISPLAY pass does nothing (9,063 pt before, 9,063 after
        //     `window.display()` + runloop turns) — `needsDisplay` is the
        //     wrong lever, and on this layer-backed view it does not even
        //     read back;
        //   · `needsLayout` DOES: an NSTextView with
        //     `isVerticallyResizable` re-frames itself from
        //     `usageBoundsForTextContainer` in its LAYOUT pass
        //     (9,063 → 8,533 pt = the 530 pt of phantom the block just
        //     gave back, matching the memo's 537 pt for a 3,000-word
        //     block).
        //
        // So: ask (`needsLayout`), and settle it in this same turn
        // (`layoutSubtreeIfNeeded` — measured 0.21 ms cold / 0.05 ms warm,
        // inside the cap's budget) so the space closes with the layout
        // instead of a beat later.
        //
        // **It cannot loop.** Only the HEIGHT changes, and `setFrameSize`
        // signals `onWidthReflow` on WIDTH changes alone — so the nudge
        // cannot manufacture the one event that grants re-eligibility. The
        // resulting clip-bounds change may re-enter this trigger, but the
        // block is in `handled` at this width by now, so a second layout
        // for it is impossible; each pass consumes one block from a set
        // that only shrinks at a given width, so the chain terminates by
        // construction.
        textView.needsLayout = true
        textView.layoutSubtreeIfNeeded()

        // Re-arm ONLY when another eligible block is actually waiting —
        // one block per debounce interval, never a batch, and no trailing
        // empty pass when the chain is done (which is also what lets the
        // drag pin assert an exact pass count).
        if plan.moreRemain { considerLongBlockLayout() }
        return plan
    }

    /// The scan: entries whose fragment sits within the viewport plus one
    /// screenful below. Mirrors `refreshDecorations`' cost model exactly —
    /// a cheap array walk over the index, ONE fragment lookup per entry in
    /// the window, hard-bounded, and no `ensureLayout` anywhere (options
    /// `[]` reads the estimate without forcing it — 1C's pinned idiom).
    private func longBlockCandidates(
        textView: EditorTextView,
        scrollView: NSScrollView,
        layoutManager: NSTextLayoutManager,
        contentManager: NSTextContentManager
    ) -> [LongBlockLayout.Candidate] {
        let visible = scrollView.contentView.bounds
        // TK2 fragment geometry is CONTAINER-relative; the viewport is
        // VIEW-relative (`BlockTint.viewRect`'s mapping, inverted — the 1A
        // traced class).
        let origin = textView.textContainerOrigin
        let top = visible.minY - origin.y
        let bottom = visible.maxY - origin.y
            + visible.height * LongBlockLayout.lookAheadViewports
        let docStart = contentManager.documentRange.location

        // Where the walk starts: ONE fragment lookup at the viewport top
        // (the `topVisibleOffset` idiom), never a walk from the document
        // start.
        var startEntry = 0
        if let fragment = layoutManager.textLayoutFragment(
            for: CGPoint(x: 4, y: max(0, top))) {
            let offset = contentManager.offset(
                from: docStart, to: fragment.rangeInElement.location)
            startEntry = LongBlockLayout.entryIndex(
                containingOffset: offset, entries: index.entries) ?? 0
        }

        var candidates: [LongBlockLayout.Candidate] = []
        var lookups = 0
        var location = 0
        for (i, entry) in index.entries.enumerated() {
            defer { location += entry.length + 1 }
            guard i >= startEntry else { continue }
            guard lookups < LongBlockLayout.maxLookupsPerPass else { break }
            guard let start = contentManager.location(docStart, offsetBy: location)
            else { continue }
            lookups += 1
            var minY: CGFloat?
            var laidOut = false
            layoutManager.enumerateTextLayoutFragments(from: start, options: []) { fragment in
                minY = fragment.layoutFragmentFrame.minY
                laidOut = fragment.state == .layoutAvailable
                return false
            }
            guard let minY else { continue }
            if minY > bottom { break }  // past the look-ahead — stop the walk
            candidates.append(LongBlockLayout.Candidate(
                entryIndex: i, blockID: entry.blockID,
                range: NSRange(location: location, length: entry.length),
                laidOut: laidOut))
        }
        return candidates
    }
}
