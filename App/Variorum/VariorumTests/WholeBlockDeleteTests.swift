//
//  WholeBlockDeleteTests.swift
//  VariorumTests
//
//  Phase 13j, batch 1 — J9: a selection covering WHOLE blocks + delete.
//
//  THE TRACE lives at the top of this file as an executable characterization
//  of the pre-fix behaviour (her screenshot report, 13e POST-CLOSE section:
//  *"what kind of writing app won't let you delete a paragraph? there's not
//  even a take on it right now"*). The pins below it are the fix's
//  red-on-old evidence.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@Suite("Whole-block delete (13j J9)")
@MainActor
struct WholeBlockDeleteTests {

    // MARK: - THE TRACE (characterization — what declines, exactly)

    /// **The one precise trace the batch owed.** A note of three blocks with
    /// an OPEN TAIL; the selection is block 2 whole PLUS the newline the eye
    /// sees at its end (what triple-click and a drag-to-the-next-paragraph
    /// both produce). Recorded facts:
    ///
    /// - the index's verdict is `.crossesBlockBoundary` — the separator is
    ///   owned by NO entry, so containment fails in both directions;
    /// - `planCrossBlockEdit` declines on the SAME two guards it has
    ///   always declined on: at least two entries in the run (the selection
    ///   reaches exactly ONE entry's characters) and the contiguity guard
    ///   `range.upperBound <= last-entry.upperBound` (the trailing
    ///   separator sits one past it). *(13u1 UNIT 2: the second planner —
    ///   #11a's visible-take edit — retired into that one compound, so this
    ///   trace now names one road where it named two; the guards are the
    ///   same guards.)*
    /// - so before J9 built the road above it, `shouldChangeText` fell to the
    ///   final `else` and spoke.
    ///
    /// The open tail is NOT the decliner — the same decline happens without
    /// one (the sibling test below). It was a plausible suspect in the
    /// post-close reading and the trace rules it out.
    ///
    /// **WHAT 13u2 UNIT C CHANGED HERE, and it is the half this trace used
    /// to record as a dead end (#109's boundary-clamp law, her ruling of
    /// 2026-09-15).** The two guards above are unchanged and still decline —
    /// the geometry did not move — but the span no longer falls through to a
    /// refusal. A DELETE of it is J9's gesture (the paragraph goes to the
    /// tray, pinned below), and a TYPE-OVER, which J9 declines, now CLAMPS to
    /// the block's own text and replaces it in place: *separators are
    /// structure, never deletable content.* The last assertion here is that
    /// flip, and it is **RED ON OLD** — the type-over refused, the store
    /// never moved.
    @Test func tracePreFixWholeParagraphSelectionDeclinesOnTouchedCountAndContiguity() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { harness in
            // Open a tail exactly as typing past the last paragraph does.
            harness.type("\n", at: harness.model.index.documentLength)
            harness.type("tail")
            #expect(harness.model.index.tailLength == 4, "the note carries an open tail")

            // Surface: "Alpha one.\nBeta two.\nGamma three.\ntail"
            //           0        10 11      20 21         33
            let beta = harness.model.index.range(ofEntryAt: 1)
            #expect(beta == NSRange(location: 11, length: 9))
            let selection = NSRange(location: beta.location, length: beta.length + 1)

            let verdict = harness.model.index.verdict(
                replacing: selection, replacementIsSingleNewline: false, segmentation: .paragraph)
            #expect(verdict == .refuse(.crossesBlockBoundary),
                    "TRACE 1: the whole-paragraph-plus-newline span is cross-block")

            // TRACE 2: the two guards, computed exactly as the planners do.
            var touched: [Int] = []
            for i in harness.model.index.entries.indices {
                let entryRange = harness.model.index.range(ofEntryAt: i)
                if NSIntersectionRange(selection, entryRange).length > 0 { touched.append(i) }
            }
            #expect(touched == [1],
                    "TRACE 2a: the selection intersects exactly ONE entry — `touched.count >= 2` declines")
            let last = harness.model.index.range(ofEntryAt: touched[touched.count - 1])
            #expect(selection.upperBound == last.upperBound + 1,
                    "TRACE 2b: the span ends one past the last touched entry — the contiguity guard declines")

            // TRACE 3: the cross-block plan still returns nil — the run holds
            // exactly one entry, which was never a cross-block edit.
            #expect(harness.model.planCrossBlockEdit(range: selection, replacement: "") == nil)

            // TRACE 4 (13u2 UNIT C): …and the span is no longer a dead end.
            // #109's law clamps it to the block's own text, so a TYPE-OVER
            // replaces that block in place. RED ON OLD: this refused.
            let clamped = try #require(harness.model.planClampedInBlockEdit(
                range: selection, replacement: "Fresh."))
            #expect(clamped.range == beta, "clamped to the block's text — the break stands")
            harness.replace(selection, with: "Fresh.")
            await harness.flush()
            let texts = try harness.storeSlots().compactMap(\.text)
            #expect(texts
                == ["Alpha one.", "Fresh.", "Gamma three."])
        }
    }

    /// The open tail is not the decliner: the same span in a tail-free note
    /// declines identically — and, since 13u2 UNIT C, clamps identically too.
    ///
    /// **RED ON OLD** on its last two lines: the type-over refused.
    @Test func traceTheOpenTailIsNotTheDecliner() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { harness in
            #expect(harness.model.index.tailLength == nil, "no tail in this note")
            let beta = harness.model.index.range(ofEntryAt: 1)
            let selection = NSRange(location: beta.location, length: beta.length + 1)
            #expect(harness.model.index.verdict(
                replacing: selection, replacementIsSingleNewline: false,
                segmentation: .paragraph) == .refuse(.crossesBlockBoundary))
            #expect(harness.model.planCrossBlockEdit(range: selection, replacement: "") == nil)

            harness.replace(selection, with: "Fresh.")
            await harness.flush()
            let texts = try harness.storeSlots().compactMap(\.text)
            #expect(texts
                == ["Alpha one.", "Fresh.", "Gamma three."],
                "the clamp does not need a tail either")
        }
    }

    // MARK: - The geometry brain (pure)

    /// Entries "aa"(2) "bbb"(3) "c"(1) tile as
    /// `aa \n bbb \n c` → starts 0/3/7, ends 2/6/8, length 8.
    private static func index(_ lengths: [Int], tail: Int? = nil) -> BlockRangeIndex {
        BlockRangeIndex(
            entries: lengths.enumerated().map {
                BlockRangeIndex.Entry(
                    blockID: "b\($0.offset)", variantID: "v\($0.offset)",
                    length: $0.element, editable: true)
            },
            tailLength: tail)
    }

    /// The same tiling with entry `gap` still waiting for its variant — the
    /// shape a sync arrival leaves behind (`variantID == nil`, `editable`
    /// false: the editor renders the block and refuses to type into it).
    private static func indexWithGap(_ lengths: [Int], gap: Int) -> BlockRangeIndex {
        BlockRangeIndex(
            entries: lengths.enumerated().map {
                BlockRangeIndex.Entry(
                    blockID: "b\($0.offset)",
                    variantID: $0.offset == gap ? nil : "v\($0.offset)",
                    length: $0.element, editable: $0.offset != gap)
            },
            tailLength: nil)
    }

    /// **THE GAP FENCE, PINNED MAC-SIDE** (13l Act 1, A1-MINOR-1 — a COVERAGE
    /// pin: green on HEAD by design, no red-on-old owed).
    ///
    /// The fence is a real NARROWING of the Mac's shipped J9 gesture, made in
    /// the shared brain by the mobile round, and its only pin lived in the
    /// phone's suite — so a Mac-suite-only regression run stayed green over a
    /// regression in a Mac behaviour. That is what this closes; it asserts the
    /// SHIPPED rule and touches no semantics (13u owns that seam's policy).
    ///
    /// The rule itself: a gap slot is a block whose variant has not arrived,
    /// which both editors already declare read-only in words. Tombstoning one
    /// takes the peer's paragraph when the variant lands (tombstone-wins,
    /// SyncSpec §6) — text she has never seen — so a run containing one
    /// declines, and ONLY the gap declines it.
    @Test func aRunContainingANotYetArrivedBlockHasNoPlanOnTheMacToo() {
        let index = Self.indexWithGap([2, 3, 1], gap: 1)
        // "aa\nbbb\nc" — the whole document, geometry-perfect as a run.
        let all = NSRange(location: 0, length: 8)
        #expect(index.wholeBlockRun(covering: all) == 0...2,
                "the GEOMETRY is a whole-block run — the fence is what declines")
        #expect(index.wholeBlockDeletion(covering: all, replacement: "") == nil)
        #expect(index.wholeBlockRunAwaitsSync(covering: all),
                "…and the face can name the real reason rather than the residual one")

        // The blocks that DID arrive still delete: the fence is the gap,
        // never the neighbourhood of one.
        #expect(index.wholeBlockDeletion(
            covering: NSRange(location: 0, length: 3), replacement: "") == ["b0"])
        #expect(!index.wholeBlockRunAwaitsSync(covering: NSRange(location: 0, length: 3)))

        // A span that is no run at all reports no gap either — the copy
        // chooser must never blame sync for a partial selection.
        #expect(!index.wholeBlockRunAwaitsSync(covering: NSRange(location: 4, length: 4)))

        // And a LOCKED take is deliberately NOT fenced (#33(a)'s unrestricted
        // delete). Here so the gap fence can never quietly grow into an
        // editability fence — the predicate is `variantID == nil`, nothing else.
        let locked = BlockRangeIndex(
            entries: [
                BlockRangeIndex.Entry(blockID: "b0", variantID: "v0", length: 2, editable: true),
                BlockRangeIndex.Entry(blockID: "b1", variantID: "v1", length: 3, editable: false),
            ],
            tailLength: nil)
        #expect(locked.wholeBlockDeletion(
            covering: NSRange(location: 0, length: 6), replacement: "") == ["b0", "b1"])
        #expect(!locked.wholeBlockRunAwaitsSync(covering: NSRange(location: 0, length: 6)))
    }

    @Test func wholeBlockRunClaimsAParagraphPlusEitherOfItsNewlines() {
        let index = Self.index([2, 3, 1])
        // Block 1 alone is [3,6); with its trailing newline [3,7); with its
        // leading one [2,6); with both [2,7).
        #expect(index.wholeBlockRun(covering: NSRange(location: 3, length: 3)) == 1...1)
        #expect(index.wholeBlockRun(covering: NSRange(location: 3, length: 4)) == 1...1)
        #expect(index.wholeBlockRun(covering: NSRange(location: 2, length: 4)) == 1...1)
        #expect(index.wholeBlockRun(covering: NSRange(location: 2, length: 5)) == 1...1)
        // A run of two, and the whole document.
        #expect(index.wholeBlockRun(covering: NSRange(location: 0, length: 6)) == 0...1)
        #expect(index.wholeBlockRun(covering: NSRange(location: 0, length: 7)) == 0...1)
        #expect(index.wholeBlockRun(covering: NSRange(location: 0, length: 8)) == 0...2)
    }

    @Test func wholeBlockRunRefusesPartialCoverageAndTailText() {
        let index = Self.index([2, 3, 1])
        // Half of block 1 plus its newline — a PARTIAL block; her ruling
        // keeps those on their existing road.
        #expect(index.wholeBlockRun(covering: NSRange(location: 4, length: 3)) == nil)
        // Block 0's tail half through block 1 whole.
        #expect(index.wholeBlockRun(covering: NSRange(location: 1, length: 5)) == nil)
        // Out of bounds.
        #expect(index.wholeBlockRun(covering: NSRange(location: 0, length: 9)) == nil)

        // With an open tail, the last separator may be taken but never the
        // tail's own text.
        let tailed = Self.index([2, 3], tail: 4)   // "aa \n bbb \n tail", length 10
        #expect(tailed.wholeBlockRun(covering: NSRange(location: 3, length: 3)) == 1...1)
        #expect(tailed.wholeBlockRun(covering: NSRange(location: 3, length: 4)) == 1...1)
        #expect(tailed.wholeBlockRun(covering: NSRange(location: 3, length: 5)) == nil,
                "one character of tail text in the span and the answer is no")
    }

    /// **THE A8 PIN (13j ladder A round 1 — red-on-old).** A ZERO-LENGTH
    /// entry sitting exactly AT the span's end has `ends == upperBound`
    /// without being covered — the half-open span stops at its position —
    /// and the primary trailing lookup used to grab it, bracketing one more
    /// empty block than the selection covers. Trailing edge only: at the
    /// LEADING edge a zero-length entry at `range.location` IS inside the
    /// half-open span, so `first` needs no mirror (the implementer's own
    /// arithmetic, reproduced). The `range.length > 1` fence off A7's carve
    /// and #34's seam is untouched — the sibling pins above hold it.
    @Test func wholeBlockRunDoesNotGrabAZeroLengthEntryAtTheSpansEnd() {
        // Three empty blocks: entries at 0, 1, 2 (each zero-length), the two
        // separators at 0 and 1. The span [0,2) covers e0, both separators
        // and e1 — and STOPS AT e2's position, so e2 is not in the run.
        let empties = Self.index([0, 0, 0])
        #expect(empties.wholeBlockRun(covering: NSRange(location: 0, length: 2)) == 0...1)
        // A text block, its separator, then a trailing empty block: the span
        // covering the text and its newline ends AT the empty's position.
        let trailingEmpty = Self.index([5, 0])
        #expect(trailingEmpty.wholeBlockRun(covering: NSRange(location: 0, length: 6)) == 0...0)
        // …and a zero-length entry genuinely INSIDE the span still counts:
        // with a tail behind it, [0,3) reaches one past e2's own separator,
        // so all three empties are covered and the run says so.
        let tailed = Self.index([0, 0, 0], tail: 2)
        #expect(tailed.wholeBlockRun(covering: NSRange(location: 0, length: 3)) == 0...2)
    }

    /// **The seam carves keep every case they ruled.** A one-character
    /// deletion is A7's/#34's geometry, and this road must never route around
    /// their fan / nothing-unshown authorizations.
    @Test func wholeBlockRunNeverClaimsASingleSeparator() {
        let index = Self.index([2, 3, 1])
        #expect(index.wholeBlockRun(covering: NSRange(location: 2, length: 1)) == nil)
        #expect(index.wholeBlockRun(covering: NSRange(location: 6, length: 1)) == nil)
        // …including beside an EMPTY block, which is exactly A7's case.
        let withEmpty = Self.index([0, 3])          // "" \n "bbb", length 4
        #expect(withEmpty.wholeBlockRun(covering: NSRange(location: 0, length: 1)) == nil)
    }

    // MARK: - The route (her case, end to end)

    /// **HER CASE.** Select one whole paragraph the way a triple-click does —
    /// the paragraph plus the newline the eye sees — and press Delete. The
    /// paragraph goes; the refusal never appears.
    @Test func aWholeParagraphSelectionDeletesTheBlock() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { harness in
            harness.type("\n", at: harness.model.index.documentLength)
            harness.type("tail")
            await harness.settle()

            let beta = harness.model.index.range(ofEntryAt: 1)
            harness.replace(NSRange(location: beta.location, length: beta.length + 1), with: "")
            await harness.flush()

            let texts = try await harness.database.read { db in
                try Queries.renderPost(db, containerID: harness.postID).compactMap(\.text)
            }
            #expect(texts == ["Alpha one.", "Gamma three."],
                    "the selected paragraph is gone — not emptied, not merged")
            #expect(harness.model.statusMessage == BlockSelectionCopy.deletedNote(1),
                    "the delete compound's own receipt speaks, never the refusal")
        }
    }

    /// ONE ⌥⌘Z entry, and it restores exactly — then ⇧⌥⌘Z puts it back
    /// (a compound is redoable exactly when every leg is; `deleteBlock` is).
    @Test func theRouteIsOneUndoEntryAndItRoundTrips() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { harness in
            let beta = harness.model.index.range(ofEntryAt: 1)
            harness.replace(NSRange(location: beta.location, length: beta.length + 1), with: "")
            await harness.flush()

            let stack = harness.session.undoStack
            #expect(stack.topLabel == "Delete Blocks",
                    "the 13e batch-4 compound is what landed — her ruling's letter")

            try await harness.session.runner.run { ops in _ = try stack.undo(with: ops) }
            let restored = try await harness.database.read { db in
                try Queries.renderPost(db, containerID: harness.postID).compactMap(\.text)
            }
            #expect(restored == ["Alpha one.", "Beta two.", "Gamma three."],
                    "one ⌥⌘Z restores the paragraph byte-identically, in place")

            try await harness.session.runner.run { ops in _ = try stack.redo(with: ops) }
            let redone = try await harness.database.read { db in
                try Queries.renderPost(db, containerID: harness.postID).compactMap(\.text)
            }
            #expect(redone == ["Alpha one.", "Gamma three."], "⇧⌥⌘Z takes it away again")
        }
    }

    /// Several whole paragraphs in one selection go in ONE compound.
    @Test func aRunOfWholeParagraphsGoesUnderOneEntry() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { harness in
            let alpha = harness.model.index.range(ofEntryAt: 0)
            let beta = harness.model.index.range(ofEntryAt: 1)
            harness.replace(
                NSRange(location: alpha.location, length: beta.upperBound - alpha.location + 1),
                with: "")
            await harness.flush()

            let texts = try await harness.database.read { db in
                try Queries.renderPost(db, containerID: harness.postID).compactMap(\.text)
            }
            #expect(texts == ["Gamma three."])
            #expect(harness.model.statusMessage == BlockSelectionCopy.deletedNote(2))

            let stack = harness.session.undoStack
            try await harness.session.runner.run { ops in _ = try stack.undo(with: ops) }
            let restored = try await harness.database.read { db in
                try Queries.renderPost(db, containerID: harness.postID).compactMap(\.text)
            }
            #expect(restored == ["Alpha one.", "Beta two.", "Gamma three."],
                    "ONE undo entry for the whole run — not two")
        }
    }

    /// **Partial selections keep today's behaviour** (her ruling's second
    /// half): a span that covers block 1 only in part still takes the
    /// ratified merge-then-edit road, not the delete road.
    @Test func aPartialSelectionStillTakesTheMergeThenEditRoad() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { harness in
            // "one.\nBeta " — the Phase 11 ratified case, untouched.
            let range = NSRange(location: 6, length: 10)
            #expect(harness.model.planWholeBlockDeletion(range: range, replacement: "") == nil)
            harness.replace(range, with: "")
            await harness.flush()
            let texts = try await harness.database.read { db in
                try Queries.renderPost(db, containerID: harness.postID).compactMap(\.text)
            }
            #expect(texts == ["Alpha two."], "the halves still JOIN — nothing about this changed")
        }
    }

    /// A type-over of a whole-block span is a REPLACEMENT, not a delete, and
    /// keeps its own road — the typed characters must never be dropped on the
    /// floor by a delete compound.
    @Test func typingOverAWholeBlockSpanIsNotADelete() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { harness in
            let alpha = harness.model.index.range(ofEntryAt: 0)
            let span = NSRange(location: alpha.location, length: alpha.length + 1)
            #expect(harness.model.planWholeBlockDeletion(range: span, replacement: "X") == nil)
        }
    }
}
