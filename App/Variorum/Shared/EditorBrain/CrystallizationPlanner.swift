//
//  CrystallizationPlanner.swift
//  Variorum
//
//  Pure planning + reconciliation for type-time crystallization and bulk
//  entry at the post tail (AppSpec §7 segmentation trigger; Phase 7 Step 3).
//  The rules themselves are VariorumCore's SegmentationRules — this planner
//  only decides what the *editor* does with a given open-tail text: which
//  block texts to mint, what the tail region should read afterwards, and
//  whether the tail stays open. Crystallization never touches existing
//  blocks (I4 holds by construction — only tail text is ever planned over).
//
//  Timing (P2): the plan is computed synchronously at the edit, but the mint
//  is a DB write that runs off-main through OperationsRunner. The view and
//  index apply the crystallization when the mint returns, and the reconciler
//  below re-plans against the *current* tail at that moment — an edit
//  landing in the in-flight window self-heals through ordinary operations
//  (autosave corrections / block deletions) instead of racing. One mint
//  batch is in flight at a time.
//

import Foundation
import VariorumCore

nonisolated enum CrystallizationPlanner {
    enum Kind: Equatable, Sendable {
        /// Typing past completed paragraphs (SegmentationRules
        /// .crystallizedBoundary — paragraph-based regardless of sentence
        /// mode; the sentence-mode question is the author's, KnownIssues).
        case typing
        /// Bulk entry (paste): the whole tail segments by the effective
        /// mode and the tail region closes.
        case bulk(Segmentation)
        /// The idle/teardown durability mint (author ruling 2026-07-12;
        /// review round 1, MAJOR 2): like bulk, but a trailing typed
        /// newline RUN survives — the pieces mint, and the run minus the
        /// separator the last piece gains stays as the still-open tail
        /// (byte-identical region, no visible collapse); the editor's
        /// leading-run attachment then folds it into the preceding block
        /// as the k−1 rule's content.
        case idle(Segmentation)
        /// One-block posts: the first fresh text mints THE block verbatim.
        case oneBlock
    }

    struct Plan: Equatable, Sendable {
        let kind: Kind
        /// Block texts to mint via Operations.newBlock, in order, at the
        /// post's end.
        let mints: [String]
        /// The open tail text remaining after mint j applies (aligned with
        /// `mints`). Only `.typing` plans support partial (prefix)
        /// application; bulk/one-block remainders are empty and a partial
        /// apply falls back to a full re-render.
        let remaindersAfter: [String]
        /// The open tail once the whole plan applies; nil = the tail region
        /// closes.
        let remainingTail: String?

        /// What the old tail region should read after mints `0..<count`
        /// apply: minted texts joined by the block separator, then the
        /// separator + remaining tail while the tail stays open. When this
        /// equals the raw tail text (the common typed case — nothing
        /// trimmed, no blanks excised) the view needs no programmatic edit.
        func normalizedRegionText(applyingFirst count: Int) -> String {
            let applied = mints.prefix(count)
            var text = applied.joined(separator: EditorDocument.separator)
            if let tail = tailAfter(applyingFirst: count) {
                if !applied.isEmpty { text += EditorDocument.separator }
                text += tail
            }
            return text
        }

        /// The open tail after a (possibly partial) application; nil =
        /// closed.
        func tailAfter(applyingFirst count: Int) -> String? {
            if count >= mints.count { return remainingTail }
            if case .typing = kind {
                guard count > 0, count <= remaindersAfter.count else { return remainingTail }
                return remaindersAfter[count - 1]
            }
            // Partial non-typing apply (review round 2): the un-applied
            // segments are the author's text — they survive as the open
            // tail (the chained crystallize pass mints them next) instead
            // of vanishing with the closed-tail remainder.
            var carried = mints[count...].joined(separator: EditorDocument.separator)
            if let open = remainingTail, !open.isEmpty {
                carried += EditorDocument.separator + open
            }
            return carried
        }
    }

    // MARK: - Which kind an occasion asks for (the ONE rule)

    /// The segmentation-mode → kind rule for an ORDINARY TAIL EDIT — the
    /// keystroke/paste road: a pending bulk entry segments by the effective
    /// mode, a one-block post mints THE block verbatim, everything else
    /// crystallizes paragraph-by-paragraph as you type past them (AppSpec §7's
    /// type-time crystallization).
    ///
    /// **Hoisted at 17f/P42** (the pre-13u round's Act 5). This mapping used
    /// to be written out five times — three in the Mac's `EditorViewModel`
    /// (teardown, idle tick, tail edit) and two in the phone's
    /// `MobileEditorViewModel` — byte-identical, with nothing pinning them
    /// together, so a rule change (a new segmentation mode; a ruling that the
    /// idle mint behaves differently under `one_block`) landing at one site
    /// would leave the others on the old rule and the two platforms would
    /// crystallize differently with nothing announcing it. The standing
    /// remedy for that class is the HOIST (KnownIssues' forked-brains row):
    /// one brain, both platforms calling it.
    ///
    /// Both factories switch EXHAUSTIVELY (no `default`), so a fourth
    /// segmentation mode is a build failure here — at the one place that
    /// decides — instead of five silent fall-throughs.
    static func kindForTailEdit(mode: Segmentation, bulkPending: Bool) -> Kind {
        if bulkPending { return .bulk(mode) }
        switch mode {
        case .oneBlock: return .oneBlock
        case .paragraph, .sentence: return .typing
        }
    }

    /// The same rule for the DURABILITY mints — the idle tick and the
    /// teardown/quit finalize. Deliberately different from a tail edit in one
    /// way and one way only (author ruling 2026-07-12; Phase 10 review round
    /// 1, MAJOR 2): outside `one_block` the mint is `.idle(.paragraph)` — the
    /// trailing typed newline run survives the mint instead of collapsing —
    /// and PARAGRAPH granularity regardless of the mode's sentence setting.
    static func kindForDurabilityMint(mode: Segmentation) -> Kind {
        switch mode {
        case .oneBlock: return .oneBlock
        case .paragraph, .sentence: return .idle(.paragraph)
        }
    }

    /// Plans the given kind over an open-tail text. Nil = nothing to mint.
    static func plan(_ kind: Kind, tail: String) -> Plan? {
        switch kind {
        case .typing:
            var mints: [String] = []
            var remainders: [String] = []
            var remaining = tail
            while let step = SegmentationRules.crystallizedBoundary(openTail: remaining) {
                mints.append(step.blockText)
                remainders.append(step.remainingTail)
                remaining = step.remainingTail
            }
            guard !mints.isEmpty else { return nil }
            return Plan(kind: kind, mints: mints, remaindersAfter: remainders, remainingTail: remaining)
        case .bulk(let mode):
            let segments = SegmentationRules.bulkSegments(tail, mode: mode)
            guard !segments.isEmpty else { return nil }
            return Plan(kind: kind, mints: segments,
                        remaindersAfter: Array(repeating: "", count: segments.count),
                        remainingTail: nil)
        case .idle(let mode):
            var segments = SegmentationRules.bulkSegments(tail, mode: mode)
            guard !segments.isEmpty else { return nil }
            // The pending gap: r trailing newlines keep r−1 as the open
            // tail (the last piece gains the separator), so the region
            // text stays byte-identical and the run survives the mint.
            var trailingRun = 0
            for character in tail.reversed() {
                if character == "\n" { trailingRun += 1 } else { break }
            }
            // **THE SPACE UNDER HER CARET (13u2 UNIT D, item 2 — her words:
            // "you typed a space but are sitting there thinking of a word
            // and the program eagerly eats your space").** The durability
            // mint is not bulk entry: every character in this tail is text
            // she typed seconds ago, and the caret is sitting at its end.
            // `bulkSegments` edge-trims each piece (the K8 trim law), so a
            // trailing space made `normalizedRegionText` differ from the
            // tail by exactly that character — and the editor's mint-apply
            // then ran a `programmaticReplace` over her live text (and
            // cleared the text view's undo stack with it, so ⌘Z could not
            // bring the character back).
            //
            // This kind ALREADY exists to prevent precisely that class: it
            // was split from `.bulk` at the author's 2026-07-12 ruling
            // (Phase 10 review round 1, MAJOR 2) so the durability mint
            // "never collapses a pending typed gap — the trailing newline
            // run survives ... byte-identical region, no visible collapse".
            // A typed trailing SPACE is the same class as a typed trailing
            // NEWLINE, so it survives the same way. **Scope, deliberately
            // narrow:** only the piece the caret is on — i.e. only when the
            // tail does not end in a newline run, so the last mint IS the
            // tail's end. Interior pieces are paragraphs she typed PAST and
            // keep the shipped trim, and bulk entry (paste, import, pool
            // drop) is untouched. (QUESTIONS #112(a) records the wider
            // reading for her.)
            //
            // The last line must be NON-BLANK to be the piece the last mint
            // came from: a tail of `"abc\n   "` ends in horizontal
            // whitespace whose line `bulkSegments` dropped entirely, and
            // appending it to `"abc"` would move whitespace across a line
            // the mint is collapsing anyway. That shape keeps its shipped
            // behaviour exactly.
            if trailingRun == 0,
               let lastLine = tail.split(separator: "\n", omittingEmptySubsequences: false).last,
               !lastLine.allSatisfy(\.isWhitespace) {
                let kept = lastLine.reversed().prefix {
                    $0.unicodeScalars.allSatisfy(CharacterSet.whitespaces.contains)
                }
                if !kept.isEmpty {
                    segments[segments.count - 1] += String(kept.reversed())
                }
            }
            return Plan(kind: kind, mints: segments,
                        remaindersAfter: Array(repeating: "", count: segments.count),
                        remainingTail: trailingRun > 0
                            ? String(repeating: "\n", count: trailingRun - 1)
                            : nil)
        case .oneBlock:
            guard !tail.allSatisfy(\.isWhitespace) else { return nil }
            return Plan(kind: kind, mints: [tail], remaindersAfter: [""], remainingTail: nil)
        }
    }
}

// MARK: - Apply-time reconciliation

/// When a mint returns, the tail may have moved on (edits land during the
/// in-flight window — milliseconds, but real). The reconciler compares what
/// was minted against a fresh plan over the *current* tail and produces
/// ordinary operations that make the store true again. The store is always
/// safe: worst case is a full re-render from the projection (AppSpec §15
/// risk 1 — identity is validated against the DB, never inferred).
nonisolated enum CrystallizationReconciler {
    struct MintedBlock: Equatable, Sendable {
        let blockID: String
        let variantID: String
        let text: String
    }

    struct Outcome: Equatable, Sendable {
        /// Autosave corrections: the block exists but the author's current
        /// text differs from what was minted.
        var corrections: [(variantID: String, text: String)] = []
        /// Blocks minted for paragraphs that no longer exist (tray-recoverable).
        var deletions: [String] = []
        /// Entries to crystallize into the index/view, in order.
        var applied: [MintedBlock] = []
        /// The open tail after application; nil = closed.
        var newTail: String?
        /// True when the surface diverged beyond clean prefix application —
        /// re-render from the store once operations settle.
        var needsFullRerender = false

        static func == (lhs: Outcome, rhs: Outcome) -> Bool {
            lhs.corrections.map(\.variantID) == rhs.corrections.map(\.variantID)
                && lhs.corrections.map(\.text) == rhs.corrections.map(\.text)
                && lhs.deletions == rhs.deletions
                && lhs.applied == rhs.applied
                && lhs.newTail == rhs.newTail
                && lhs.needsFullRerender == rhs.needsFullRerender
        }
    }

    static func reconcile(
        minted: [MintedBlock],
        currentTail: String,
        kind: CrystallizationPlanner.Kind
    ) -> Outcome {
        var outcome = Outcome()
        guard let current = CrystallizationPlanner.plan(kind, tail: currentTail) else {
            // Nothing mintable remains (the author un-typed it in the
            // window): the minted blocks describe paragraphs that no longer
            // exist — remove them; the tail stays as the author left it.
            outcome.deletions = minted.map(\.blockID)
            outcome.newTail = currentTail
            return outcome
        }

        let appliedCount = min(minted.count, current.mints.count)
        // Corrections: same slot, drifted text.
        for j in 0..<appliedCount where current.mints[j] != minted[j].text {
            outcome.corrections.append((minted[j].variantID, current.mints[j]))
        }
        // Extras: minted for paragraphs that no longer complete.
        if minted.count > appliedCount {
            outcome.deletions = minted[appliedCount...].map(\.blockID)
        }
        outcome.applied = (0..<appliedCount).map { j in
            MintedBlock(
                blockID: minted[j].blockID,
                variantID: minted[j].variantID,
                text: current.mints[j])
        }
        outcome.newTail = current.tailAfter(applyingFirst: appliedCount)

        // Partial application is only well-defined for typing plans (their
        // per-step remainders are exact); a partial bulk/one-block apply
        // re-renders from the store instead of guessing.
        if appliedCount < current.mints.count, current.kind != .typing {
            outcome.needsFullRerender = true
        }
        return outcome
    }
}
