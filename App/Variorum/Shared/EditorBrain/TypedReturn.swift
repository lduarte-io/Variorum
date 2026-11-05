//
//  TypedReturn.swift
//  Variorum
//
//  **U-1 (her ruling, 2026-09-06 use-report round, 18c batch 2): NEWLINES
//  MAKE BLOCKS, ANYWHERE IN WRITE.** Her words: *"newlines to make new
//  blocks is NOT working properly at all… I was writing in Write, but in
//  the middle of Write, so I had paragraphs above and below. I want it to
//  work on newlines even when you're in the middle of write."*
//
//  **ONE ARM SUPERSEDED — her ruling R-13u4-2 (the 13u4 sizing-and-rulings
//  sitting, 2026-09-20): EMPTY BLOCKS CHAIN.** U-1 ended "…nothing in an
//  empty block"; she reversed that arm herself: *"This is driving me insane -
//  on an empty block, you can't keep making new lines and spawning more empty
//  blocks. Direct violation of 'works how you'd expect a text editor to
//  work'… You should be able to go down the list typing whatever you want in
//  a series of empty blocks."* An empty block now answers the same verdict a
//  block's END answers, so the key chains indefinitely. Everything else U-1
//  and U-19 settled stands: the chip OFF is content, the abandoned empties
//  STAY, ⇧⏎ is the in-block newline, and #92(c)'s empty-tail close-and-mint
//  composes ahead of the chain (the tail is answered before the entries are
//  walked at all).
//
//  This file is the DECISION and nothing else — pure, `nonisolated`, no
//  AppKit, no store: given the caret, the tiling index, the note's
//  segmentation chip and a way to read one entry's live text, it says which
//  act the Return key is. The dispatch (the structural doors) is
//  `EditorViewModel.runTypedReturn` / `EditorSurfaceController`; the key
//  itself is `EditorTextView.insertNewline`.
//
//  Why a pure decision rather than an `if` at the key: the same answer is
//  needed TWICE — once synchronously at the keystroke ("is this key mine?",
//  which decides whether a newline is typed at all) and once at the act's
//  own turn on the main actor, where it is re-derived against the live
//  surface so two fast Returns compose instead of racing (the second one
//  sees the block the first one made). Two readings of one rule must be one
//  function or they drift.
//
//  What it deliberately does NOT decide: refusals. A sealed note, a locked
//  take and a gap slot all answer through the doors this routes to, in
//  their own words (P-2 — a rendered door performs the act or delivers the
//  operations layer's real refusal). A one-word block used to be the fourth
//  (#92(b)); since VX-806 a caret inside a word carries the word down, so
//  that block is pushed down whole instead of refused.
//
//  The tail (AppSpec §7's type-time crystallization) keeps its road: a note
//  with no blocks yet IS the tail, and a paragraph typed there crystallizes
//  exactly as it always did. The ONE narrowing is the trap §4.1 of the
//  round's plan traced — an EMPTY open tail left behind by the idle mint,
//  where the tail road plans nothing at all and her Return produced "several
//  new lines" (her image 4). There the key closes that empty render artifact
//  and makes the block, which is what pin (9) of §5.1 — her S1 scenario —
//  asks for.
//

import Foundation
import VariorumCore

nonisolated enum TypedReturn {
    /// Where an empty block lands relative to the caret's block.
    enum Edge: Equatable, Sendable {
        /// The caret sits at the end of the block's text: the new block
        /// follows it and takes the caret (the everyday "next paragraph").
        case below
        /// The caret sits before any of the block's text: the new block
        /// goes ABOVE and the caret STAYS in the text block (the everyday
        /// "push this paragraph down").
        case above
    }

    enum Act: Equatable, Sendable {
        /// Not this gesture — the keystroke stays exactly the key it was
        /// (⇧⏎, the chip off, a selection, a note that is still all tail).
        case content
        /// An empty block beside the caret's block. `closingEmptyTail`
        /// marks the one case where an EMPTY open tail sits below the last
        /// block: its separator is the render artifact the trap lives in,
        /// so the act closes it first (no store write — the tail was never
        /// a block) and mints below the last block.
        case emptyBlock(edge: Edge, entryIndex: Int, blockID: String,
                        closingEmptyTail: Bool)
        /// The caret sits inside the block's text, at a word's EDGE (never
        /// inside a word — that is the case below): divide at the caret,
        /// through the ONE snapping rule (S4-22) the planner already
        /// applies. Single-take: in place, A keeps identity. Fanned: the
        /// keep-on-top default 18c batch 1 built.
        case divideAtCaret(entryIndex: Int, blockID: String)
        /// **VX-806 — the caret sits INSIDE a word, and the whole word rides
        /// down.** Divide at `cut`, the start of the caret's word
        /// (`BoundarySnapping.wordStart(enclosing:in:)` — the floor of the
        /// one legal-cut set, so a member of it by construction), TAKEN
        /// EXACTLY by the planner's `plan(divideAtExactCut:world:)` rather
        /// than re-settled. Every other answer of the divide door stands —
        /// the locked take's refusal, the gap slot's, the fanned block's
        /// keep-on-top road (with this cut as the displayed take's). A word
        /// that starts at the block's very start never comes here: that is
        /// `.emptyBlock(edge: .above)`, the block pushed down whole.
        case divideAtWordStart(entryIndex: Int, blockID: String, cut: Int)
        // **`case nothing` RETIRED (R-13u4-2, 13u4 UNIT E1).** It was the
        // empty block's ruled no-op under U-1; her ruling change makes that
        // caret mint like every other end-of-block caret, so nothing returns
        // it any more — and a case that can never be returned is the drift
        // class (this app's own doctrine, the `noDailyBook` retirement,
        // AppSpec §9). U-19 (2) is untouched: nothing vanishes; the empties
        // she leaves behind stay exactly where she left them.
    }

    /// The one rule. `textAt` reads entry i's LIVE surface text (the buffer
    /// is authoritative while dirty) and is consulted for the caret's entry
    /// only — O(one block), never O(document) (P1).
    static func act(
        selection: NSRange,
        index: BlockRangeIndex,
        segmentation: Segmentation,
        textAt: (Int) -> String
    ) -> Act {
        // The chip OFF returns the whole note to Return-as-content — her
        // U-19 (3), verbatim: *"users can also turn off newlines make
        // blocks if they want, right?"*
        guard segmentation != .oneBlock else { return .content }
        // A selection is deliberately ordinary — the K5 precedent in
        // `MarkdownActs.listReturn`, for the same reason: the ruling is
        // about a caret, and replacing a span is a different gesture.
        guard selection.length == 0, selection.location != NSNotFound,
              selection.location >= 0, selection.location <= index.documentLength
        else { return .content }
        // A note with no blocks yet is ALL tail (the fresh-post state): its
        // paragraphs are born by crystallization, which is the same promise
        // by another road. Untouched.
        guard !index.entries.isEmpty else { return .content }

        let caret = selection.location
        if let tail = index.tailRange, caret >= tail.location {
            // A tail with text in it still crystallizes — the road that
            // makes the block. An EMPTY tail plans nothing at all: that is
            // the trap (§4.1), and the key closes it and makes the block.
            guard index.tailLength == 0 else { return .content }
            let last = index.entries.count - 1
            return .emptyBlock(
                edge: .below, entryIndex: last,
                blockID: index.entries[last].blockID, closingEmptyTail: true)
        }

        // The caret's entry, by the tiling — the same walk
        // `updateCaretContext` makes, so "the caret's block" means one
        // thing in this app: a caret at a block's END belongs to that
        // block, and the seam character belongs to neither.
        var location = 0
        for (i, entry) in index.entries.enumerated() {
            if caret >= location, caret <= location + entry.length {
                let intra = caret - location
                // **THE CHAIN (her ruling R-13u4-2, 2026-09-20 — it
                // SUPERSEDES U-1's "nothing in an empty block" arm).** Her
                // words: *"on an empty block, you can't keep making new lines
                // and spawning more empty blocks. Direct violation of 'works
                // how you'd expect a text editor to work'… You should be able
                // to go down the list typing whatever you want in a series of
                // empty blocks."* An empty block answers exactly what a
                // block's END answers — an empty block BELOW, the caret in
                // it — so ⏎⏎⏎ walks down a run of them. It chains for free
                // because the act RE-DERIVES on its own turn: the second
                // Return sees the block the first one made and mints below
                // THAT. Checked before `textAt`, so an empty block costs no
                // text read at all. U-19 (2) is untouched — the empties stay.
                if entry.length == 0 {
                    return .emptyBlock(
                        edge: .below, entryIndex: i, blockID: entry.blockID,
                        closingEmptyTail: false)
                }
                let text = textAt(i) as NSString
                let clamped = min(intra, text.length)
                // A block that is NOTHING but whitespace has no text to
                // stand before: past its first offset the key makes the
                // block BELOW, as it did before R1-5 (the sanity pass's
                // observation — the prefix rule below would otherwise push
                // it down from every caret; reachable in two keystrokes:
                // ⏎, two spaces, ⏎).
                if clamped > 0, (text as String).allSatisfy(\.isWhitespace) {
                    return .emptyBlock(
                        edge: .below, entryIndex: i, blockID: entry.blockID,
                        closingEmptyTail: false)
                }
                // "Before any text" (§5.1) — nothing but whitespace between
                // the block's start and the caret; the mirror of the
                // trailing rule below (18c ladder round 1, R1-5: a caret
                // INSIDE a leading run used to answer a divide the cut brain
                // then refused, while the block's first offset pushed the
                // paragraph down).
                if text.substring(to: clamped).allSatisfy(\.isWhitespace) {
                    return .emptyBlock(
                        edge: .above, entryIndex: i, blockID: entry.blockID,
                        closingEmptyTail: false)
                }
                // A caret on a LIST LINE, anywhere but its END, is the list
                // door's (18c ladder round 1, R1-4 — PROVISIONAL, QUESTIONS
                // #94): the door itself claims only the line's end
                // (continue / exit / outdent), so a mid-item ⏎ reached this
                // act and DIVIDED the list block — the second half losing
                // its bullet, the list no longer one block. §5.1's letter is
                // "inside a list, Return continues the list … keeps its
                // behavior", and the shipped K5 behaviour mid-item was a
                // content newline; this restores it (the block stays
                // whole). The line's END is deliberately excluded: the only
                // way this act is reached there is the exit road (an empty
                // item's lead retracted, R1-3), whose next word must be the
                // block below, never a newline. Whether a mid-item ⏎ should
                // instead split the ITEM into two bullets is hers (#94).
                let line = Self.lineRange(of: text, at: clamped)
                if clamped < line.upperBound,
                   MarkdownSyntax.isListLead(text.substring(with: line)) {
                    return .content
                }
                // "At the end" ignores trailing whitespace (§5.1): what
                // stands between the caret and the block's end is spacing,
                // not a paragraph to cut off.
                if text.substring(from: clamped).allSatisfy(\.isWhitespace) {
                    return .emptyBlock(
                        edge: .below, entryIndex: i, blockID: entry.blockID,
                        closingEmptyTail: false)
                }
                // **VX-806 — a caret INSIDE a word carries the whole word
                // down** (her report, 2026-11-04, the chip on: *"normally
                // when you try to make a newline in the middle of a word, it
                // just moves the whole word down, but with this it just
                // denies it. standardize it?"*). It SUPERSEDES #92(b)'s built
                // answer (the divide door's own `nothingToDo`, spoken): the
                // cut is the caret's word's start — the floor of the one
                // legal-cut set (S4-22), never `settle`'s nearest member,
                // which takes a late-in-word caret to the NEXT word and
                // leaves this one behind. Where the word starts the block
                // (nothing but whitespace before it — the first word, a
                // one-word block, her screenshot's caret just past an
                // opening quote), the cut would be the block's start, which
                // no divide may take: the block is pushed down whole, the
                // start arm above ("before any text"). The end arm cannot be
                // reached from here — the word itself stands after its own
                // start — so the block's end stays the trailing rule's above.
                // A caret on a list line never reaches this (the list door's
                // line rule, above), and a word's EDGE is not inside a word:
                // both keep the roads they had.
                if let wordStart = BoundarySnapping.wordStart(
                    enclosing: clamped, in: text as String) {
                    if text.substring(to: wordStart).allSatisfy(\.isWhitespace) {
                        return .emptyBlock(
                            edge: .above, entryIndex: i, blockID: entry.blockID,
                            closingEmptyTail: false)
                    }
                    return .divideAtWordStart(
                        entryIndex: i, blockID: entry.blockID, cut: wordStart)
                }
                return .divideAtCaret(entryIndex: i, blockID: entry.blockID)
            }
            location += entry.length + 1
        }
        return .content
    }

    /// The line `offset` sits on, terminator excluded — O(line), read from
    /// the one entry the act already holds (P1).
    static func lineRange(of text: NSString, at offset: Int) -> NSRange {
        let before = text.range(
            of: "\n", options: .backwards, range: NSRange(location: 0, length: offset))
        let start = before.location == NSNotFound ? 0 : before.location + 1
        let after = text.range(
            of: "\n", range: NSRange(location: offset, length: text.length - offset))
        let end = after.location == NSNotFound ? text.length : after.location
        return NSRange(location: start, length: end - start)
    }
}
