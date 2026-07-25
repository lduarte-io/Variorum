//
//  BlockRangeIndex.swift
//  Variorum
//
//  Live block identity over the editor surface (Phase 7 Step 3 — AppSpec §15
//  risk 1, this phase's hard core). Pure value type, UTF-16 offsets (the
//  Phase 3 unit decision). Every edit reports its exact changed range; the
//  index shifts/grows the owning block and never lets an edit leak across a
//  block boundary. Identity is validated against the DB, never inferred from
//  the text — if this bookkeeping ever fails, the store stays safe (the
//  editor re-renders from the projection).
//
//  Document shape invariant (tiling): block entries in order, exactly one
//  1-char separator between consecutive entries, then — iff the tail region
//  is open — one separator (when entries exist) followed by the tail to the
//  document end. When there are no entries the tail IS the document and is
//  always open (fresh-post state). Separators are owned by no block
//  (EditorDocument doctrine).
//

import Foundation
import VariorumCore

nonisolated struct BlockRangeIndex: Equatable, Sendable {
    struct Entry: Equatable, Sendable {
        let blockID: String
        /// The variant this slot's edits autosave into (the rendered
        /// variant); nil = a gap slot (missing block/variant — read-only).
        let variantID: String?
        /// UTF-16 length of the block's text in the surface.
        var length: Int
        /// False for gap slots and locked variants: edits refuse.
        let editable: Bool
    }

    private(set) var entries: [Entry]
    /// UTF-16 length of the open tail; nil = no tail region.
    private(set) var tailLength: Int?

    // MARK: - Construction

    init(entries: [Entry], tailLength: Int?) {
        self.entries = entries
        // No entries ⇒ the tail is the document (always open).
        self.tailLength = entries.isEmpty ? (tailLength ?? 0) : tailLength
    }

    init(slots: [Queries.RenderedBlock], tail: String?) {
        self.init(
            entries: slots.map { slot in
                Entry(
                    blockID: slot.blockID,
                    variantID: slot.variantID,
                    length: (slot.text ?? "").utf16.count,
                    editable: !slot.isGap && !slot.variantLocked)
            },
            tailLength: tail.map { $0.utf16.count })
    }

    // MARK: - Geometry

    /// Total UTF-16 length of the document this index describes.
    var documentLength: Int {
        var length = entries.reduce(0) { $0 + $1.length }
        if entries.count > 1 { length += entries.count - 1 }
        if let tailLength {
            if !entries.isEmpty { length += 1 }
            length += tailLength
        }
        return length
    }

    /// The range of entry `i` in the document.
    func range(ofEntryAt i: Int) -> NSRange {
        var location = 0
        for (j, entry) in entries.enumerated() {
            if j == i { return NSRange(location: location, length: entry.length) }
            location += entry.length + 1
        }
        preconditionFailure("entry index out of range")
    }

    /// The open tail's range (nil when no tail region exists).
    var tailRange: NSRange? {
        guard let tailLength else { return nil }
        guard !entries.isEmpty else { return NSRange(location: 0, length: tailLength) }
        let lastEnd = range(ofEntryAt: entries.count - 1).upperBound
        return NSRange(location: lastEnd + 1, length: tailLength)
    }

    /// The separator character position before the tail (only meaningful
    /// when a tail region exists below non-empty entries).
    var tailSeparatorOffset: Int? {
        guard tailLength != nil, !entries.isEmpty else { return nil }
        return range(ofEntryAt: entries.count - 1).upperBound
    }

    // MARK: - Edit routing (the policy layer, consulted BEFORE any change)

    enum Verdict: Equatable, Sendable {
        /// The edit is fully owned by one block: apply, autosave its variant.
        case block(index: Int)
        /// The edit is fully inside the open tail (fresh, not-yet-block text).
        case tail
        /// Enter at the exact document end opens the tail (paragraph-
        /// crystallization posts; PROVISIONAL — see phase plan closeout).
        case openTail
        /// Deleting the separator of an EMPTY tail closes the tail region —
        /// no block text is touched, only the render artifact goes.
        case closeTail
        case refuse(Refusal)
    }

    enum Refusal: Equatable, Sendable {
        /// Cross-block destructive edits refuse in editor v1 (author-
        /// confirmed interpretation 3a; structural gestures arrive Phase 9).
        case crossesBlockBoundary
        /// Gap slot (missing block/variant): nothing to autosave into.
        case readOnlySlot
        /// The rendered variant is locked: branch or unlock to edit.
        case lockedVariant
        /// The proposed range lies outside the document this index
        /// describes — the index has desynced from the storage. Never a
        /// crash (review round 1, MINOR 7): the view model's recovery
        /// re-renders from the store, which is truth.
        case indexDesync
    }

    /// Routes a proposed replacement. `replacementIsSingleNewline` and
    /// `segmentation` decide the open-tail gesture; everything else is
    /// containment against the tiling invariant.
    func verdict(
        replacing range: NSRange,
        replacementIsSingleNewline: Bool,
        segmentation: Segmentation
    ) -> Verdict {
        // A range outside the tiling means the index no longer describes
        // the storage. The posture is recover-not-crash: refuse the edit
        // and let the caller re-render from the store (`desyncRecovery`).
        guard range.location >= 0, range.upperBound <= documentLength else {
            return .refuse(.indexDesync)
        }

        // The open-tail gesture: a typed newline at the exact document end
        // while no tail region exists. One-block posts never open a tail
        // (their Enter is content of the single block — crystallization
        // never applies to them).
        if tailLength == nil, !entries.isEmpty,
           range.length == 0, range.location == documentLength,
           replacementIsSingleNewline, segmentation != .oneBlock {
            return .openTail
        }

        // Closing an empty tail: deleting exactly its separator.
        if let separator = tailSeparatorOffset, tailLength == 0,
           range == NSRange(location: separator, length: 1) {
            return .closeTail
        }

        // Containment: the edit must sit fully inside one region.
        if let tail = tailRange,
           range.location >= tail.location, range.upperBound <= tail.upperBound {
            return .tail
        }
        var location = 0
        for (i, entry) in entries.enumerated() {
            let entryRange = NSRange(location: location, length: entry.length)
            if range.location >= entryRange.location, range.upperBound <= entryRange.upperBound {
                if !entry.editable {
                    return .refuse(entry.variantID == nil ? .readOnlySlot : .lockedVariant)
                }
                return .block(index: i)
            }
            location += entry.length + 1
        }
        return .refuse(.crossesBlockBoundary)
    }

    // MARK: - A7 (13c batch 1B): the empty-block carve

    /// Phase 13c, batch 1B — her A7, verbatim: *"I cant use backspace to
    /// delete empty blocks with no takes right now which is too annoying -
    /// especially when there's an empty block right at the start of the
    /// post."*
    ///
    /// A backspace at the start of a block, or a forward-delete at the end
    /// of one, proposes deleting exactly the ONE separator character
    /// between them — a range owned by NEITHER block, so `verdict` answers
    /// `.crossesBlockBoundary` and the keystroke refuses. That refusal is
    /// ratified and stays: a cross-block destructive edit must not
    /// half-apply. But where one side of that seam is an EMPTY block the
    /// refusal buys nothing — **there is no text to lose** — and the right
    /// answer is to delete that block.
    ///
    /// This is the whole carve, and it is deliberately narrow so it cannot
    /// widen: a **deletion** (never a replacement — typing over a seam is a
    /// different gesture) of **exactly one inter-entry separator** where a
    /// neighbouring entry has **zero length**. Everything else — a block
    /// with any text, a multi-character range, a range that starts or ends
    /// inside a block, the tail separator — falls through untouched to the
    /// existing merge-then-edit / visible-take / refusal paths. The
    /// no-fan and editability guards live with the caller, which is where
    /// the fan arity is known (`EditorSurfaceController`).
    ///
    /// Returns the entry index to delete, or nil. **When BOTH neighbours
    /// are empty the one BEFORE the separator wins** — backspace is the
    /// dominant gesture and its meaning is "remove what is behind me";
    /// preferring the block after would delete the very block the caret
    /// sits in and never converge under repeated presses.
    func emptyBlockDeletion(replacing range: NSRange, isDeletion: Bool) -> Int? {
        guard isDeletion, range.length == 1, entries.count >= 2 else { return nil }
        // Only the INTER-ENTRY separators — the tail's separator is the
        // `closeTail` verdict's business, not this one.
        var location = 0
        for k in 0..<(entries.count - 1) {
            location += entries[k].length
            if location == range.location {
                if entries[k].length == 0 { return k }
                if entries[k + 1].length == 0 { return k + 1 }
                return nil
            }
            location += 1  // the separator itself
        }
        return nil
    }

    // MARK: - Mutations (applied AFTER the change, per the verdict)

    mutating func applyBlockEdit(at index: Int, lengthDelta: Int) {
        precondition(entries[index].length + lengthDelta >= 0, "block length went negative")
        entries[index].length += lengthDelta
    }

    mutating func applyTailEdit(lengthDelta: Int) {
        precondition(tailLength != nil, "no open tail")
        precondition((tailLength ?? 0) + lengthDelta >= 0, "tail length went negative")
        tailLength = (tailLength ?? 0) + lengthDelta
    }

    /// The typed newline that opened the tail IS the separator before it.
    mutating func openTail() {
        precondition(tailLength == nil && !entries.isEmpty, "tail already open")
        tailLength = 0
    }

    mutating func closeTail() {
        precondition(tailLength == 0 && !entries.isEmpty, "only an empty tail closes")
        tailLength = nil
    }

    /// The leading-run attachment's bookkeeping (Phase 10, the 2026-07-12
    /// spacing ruling): the tail's first `units` characters become the
    /// last entry's trailing content — the entry grows, the tail shrinks,
    /// the document's bytes and total length are unchanged (the separator
    /// conceptually slides to the transferred run's end).
    mutating func transferTailPrefixToLastEntry(_ units: Int) {
        precondition(units > 0, "transfer needs at least one unit")
        precondition(!entries.isEmpty, "no entry to attach to")
        precondition((tailLength ?? -1) >= units, "the tail must contain the run")
        entries[entries.count - 1].length += units
        tailLength = (tailLength ?? 0) - units
    }

    /// Crystallization bookkeeping (the view edit is the caller's job): the
    /// tail's completed paragraphs became real blocks; the remainder stays
    /// open. `remainingTailLength` nil ⇒ the tail region closed entirely
    /// (bulk segmentation consumes it) — unless entries would then be empty,
    /// which the invariant forbids (guarded by the callers: a mint always
    /// leaves at least one entry).
    mutating func crystallize(
        minted: [(blockID: String, variantID: String, length: Int)],
        remainingTailLength: Int?
    ) {
        precondition(tailLength != nil, "no open tail to crystallize")
        precondition(!minted.isEmpty, "crystallize needs at least one mint")
        for mint in minted {
            entries.append(Entry(
                blockID: mint.blockID, variantID: mint.variantID,
                length: mint.length, editable: true))
        }
        tailLength = remainingTailLength
    }
}
