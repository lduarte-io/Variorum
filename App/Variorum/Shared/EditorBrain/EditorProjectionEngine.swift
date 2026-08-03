//
//  EditorProjectionEngine.swift
//  Variorum
//
//  Phase 13b, Stage 1a (the T3 slice): the FULL-DOCUMENT editor's
//  buffer/projection/text-authority concerns, extracted from
//  `EditorViewModel` into two pure, unit-tested pieces. This is the
//  editor-side sibling of `PaneTextAuthority` — the full-document surface
//  is deliberately its OWN kind (the Stage 1a architect precision keeps
//  `BlockRangeIndex`/crystallization intact), but its text-authority
//  brain now has a named, tested home instead of living as fields and
//  private methods of a 3k-line class.
//
//  - `EditorSurfaceLedger`: what the surface is KNOWN to hold per variant
//    (the Phase 10 Step-1 echo-detection map — zero surface reads) plus
//    the incremental word-count cache (R11's P1-cost total).
//  - `EditorProjectionPolicy`: the ONE decision "what does an incoming
//    projection do to the surface" — defer / initial / echo-adopt /
//    differential / full — with the precedence order pinned as code
//    (previously an if-chain inside applyProjection).
//

import Foundation
import VariorumCore

// MARK: - The surface-text ledger (echo detection + word counts)

nonisolated struct EditorSurfaceLedger {
    /// The text the surface currently holds per variant — maintained at
    /// every adoption point (full render, differential, structural apply)
    /// and every edit record, so echo detection NEVER reads the surface
    /// (the KnownIssues O(post-length) echo-compare fix).
    private(set) var textByVariant: [String: String] = [:]
    /// Per-variant word counts, cached — only CHANGED texts re-enumerate
    /// (cost ∝ the edit, the P1 unit).
    private(set) var wordCountByVariant: [String: Int] = [:]

    /// Adopts a projection as the known surface text, re-counting words
    /// only where the text actually changed.
    mutating func adopt(_ slots: [Queries.RenderedBlock]) {
        var map: [String: String] = [:]
        map.reserveCapacity(slots.count)
        var counts: [String: Int] = [:]
        counts.reserveCapacity(slots.count)
        for slot in slots {
            guard let variantID = slot.variantID else { continue }
            let text = slot.text ?? ""
            map[variantID] = text
            if textByVariant[variantID] == text,
               let cached = wordCountByVariant[variantID] {
                counts[variantID] = cached
            } else {
                counts[variantID] = TextMetrics.wordCount(text)
            }
        }
        textByVariant = map
        wordCountByVariant = counts
    }

    /// The edited block's surface truth (O(the edited block), already paid
    /// for by the autosave itself).
    mutating func recordEdit(variantID: String, text: String) {
        textByVariant[variantID] = text
    }

    /// The caret block's LIVE count keeps the post total current between
    /// projections. Returns true when the cache moved (publish then).
    mutating func setLiveWordCount(variantID: String, count: Int) -> Bool {
        guard wordCountByVariant[variantID] != count else { return false }
        wordCountByVariant[variantID] = count
        return true
    }

    /// The post total over the CURRENT slots (stale variants fall out
    /// naturally; gaps count nothing). O(blocks) per call.
    func totalWords(over slots: [Queries.RenderedBlock]) -> Int {
        slots.compactMap(\.variantID).reduce(0) { $0 + (wordCountByVariant[$1] ?? 0) }
    }

    /// THE ECHO CHECK: true when the projection and the live surface agree
    /// on every slot — same blocks, same rendered variants, same texts,
    /// same editability. In-memory only; the surface is never read.
    func matches(
        _ new: [Queries.RenderedBlock], entries: [BlockRangeIndex.Entry]
    ) -> Bool {
        guard new.count == entries.count else { return false }
        for (i, slot) in new.enumerated() {
            let entry = entries[i]
            let editable = !slot.isGap && !slot.variantLocked
            guard slot.blockID == entry.blockID,
                  slot.variantID == entry.variantID,
                  editable == entry.editable
            else { return false }
            let text = slot.text ?? ""
            guard text.utf16.count == entry.length else { return false }
            guard let variantID = slot.variantID else {
                // A gap slot renders as an empty read-only range; the
                // length check above (0 == 0) is the whole comparison.
                continue
            }
            guard text == textByVariant[variantID] else { return false }
        }
        return true
    }
}

// MARK: - The projection policy (what an arriving projection does)

nonisolated enum EditorProjectionPolicy {
    enum Decision: Equatable {
        /// The buffer is authoritative (dirty / mint / structural flight):
        /// hold the projection for settle.
        case deferUntilClean
        /// First load: full render, no local tail exists to preserve.
        case initialRender
        /// A forced rebuild (desync heal, reconciler request).
        case forcedFullRender
        /// Our own echo (or metadata-only movement): adopt bookkeeping,
        /// touch nothing in the view.
        case adoptEcho
        /// Same block sequence, changed texts: replace only changed slots.
        case differential
        /// Structure changed: rebuild from the store, tail preserved.
        case fullRender
        /// **A DELIVERY may never rewrite the surface** (mobile S3 ladder,
        /// MAJOR 3 — the retired Phase 8 capture VM's clean-instant
        /// guarantee, RESTORED for both platforms): an observation value
        /// fetched BEFORE a flush can be CONSUMED after it settles — at
        /// that clean instant it reads as a real change (non-matching,
        /// same sequence) and the old `.differential` regressed surface
        /// AND ledger to pre-flush bytes; a keystroke in the window then
        /// flushed stale-based text over the newer store text. Deliveries
        /// are SIGNALS: the caller holds the marker and settles by its
        /// fresh-read path (`applyPendingIfClean`), whose value comes back
        /// as non-delivery and takes the render arms below.
        case refetchFresh
    }

    /// The precedence order IS the contract (pinned):
    /// not-loaded ▸ busy ▸ forced ▸ echo ▸ delivery-refetch ▸
    /// same-sequence ▸ full. `delivery` marks a value that arrived from
    /// an observation (a photograph of unknown age) rather than a fresh
    /// authoritative read — echo adoption stays legal for it (matching
    /// means byte-identical to the surface; nothing is rewritten), every
    /// REWRITE arm demands freshness, and a forced heal under a delivery
    /// keeps its flag armed for the fresh read.
    static func decide(
        loaded: Bool, busy: Bool, forceFull: Bool,
        delivery: Bool = false,
        matchesSurface: @autoclosure () -> Bool,
        sameSequence: @autoclosure () -> Bool
    ) -> Decision {
        if !loaded { return .initialRender }
        if busy { return .deferUntilClean }
        if forceFull { return delivery ? .refetchFresh : .forcedFullRender }
        if matchesSurface() { return .adoptEcho }
        if delivery { return .refetchFresh }
        if sameSequence() { return .differential }
        return .fullRender
    }
}
