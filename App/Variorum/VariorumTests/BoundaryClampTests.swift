//
//  BoundaryClampTests.swift
//  VariorumTests
//
//  **#109's BOUNDARY-CLAMP LAW, PINNED** (13u2 UNIT C). Her ruling of
//  2026-09-15 at the 13u1 checkpoint, whose binding text is
//  `notes/QUESTIONS.md` #109's RULED block:
//
//    **ONE uniform law: a selection edge sitting on a block boundary CLAMPS
//    to block text — separators are structure, never deletable content — and
//    NO boundary-anchored selection refuses.**
//
//  Her words for shape (i): *"I leant towards taking it as an in-block
//  edit… if it's on the boundary, why not treat it as just part of that one
//  block?"* Her pick for shape (ii): *"Take it — build at 13u2"* (the (d)
//  TRIM road).
//
//  The behaviour pins here drive the REAL keystroke path — `insertText`
//  through the gate's cross-block arm, the deferred road, the surface — and
//  then read the STORE. The geometry pins drive the pure brain, where every
//  edge of the family is reachable with no store and no timing.
//
//  The fixture used throughout: `"Alpha one.\nBeta two.\nGamma three."`
//    A = [0,10)   separator at 10
//    B = [11,20)  separator at 20
//    C = [21,33)
//

import AppKit
import Foundation
import Testing
import VariorumCore

@testable import Variorum

@Suite("The boundary-clamp law (13u2 UNIT C — her #109)")
struct BoundaryClampTests {

    // MARK: - The geometry, in the pure brain

    private static func index(_ lengths: [Int], tail: Int? = nil) -> BlockRangeIndex {
        BlockRangeIndex(
            entries: lengths.enumerated().map {
                BlockRangeIndex.Entry(
                    blockID: "b\($0.offset)", variantID: "v\($0.offset)",
                    length: $0.element, editable: true)
            },
            tailLength: tail)
    }

    /// The two edges, each trimmed by exactly one character — and a span with
    /// neither edge on a separator left byte-identical, which is what keeps
    /// every shape 13u1 already took byte-unchanged.
    @Test func eitherEdgeOnASeparatorTrimsByOneAndNothingElseMoves() {
        let ranges = Self.index([10, 9, 12]).entryRanges()
        #expect(ranges == [
            NSRange(location: 0, length: 10),
            NSRange(location: 11, length: 9),
            NSRange(location: 21, length: 12),
        ])
        // Trailing edge ON the separator at 10 (the span stops exactly where
        // B begins) — shape (i).
        #expect(CrossBlockCompound.clampedToBlockText(
            NSRange(location: 6, length: 5), ranges: ranges)
            == NSRange(location: 6, length: 4))
        // Leading edge ON it (the span opens at A's end) — shape (i)'s mirror.
        #expect(CrossBlockCompound.clampedToBlockText(
            NSRange(location: 10, length: 5), ranges: ranges)
            == NSRange(location: 11, length: 4))
        // Shape (ii): opens on the separator, reaches into TWO blocks.
        #expect(CrossBlockCompound.clampedToBlockText(
            NSRange(location: 10, length: 17), ranges: ranges)
            == NSRange(location: 11, length: 16))
        // …and its mirror: closes on the separator after B.
        #expect(CrossBlockCompound.clampedToBlockText(
            NSRange(location: 6, length: 15), ranges: ranges)
            == NSRange(location: 6, length: 14))
        // BOTH edges on separators at once.
        #expect(CrossBlockCompound.clampedToBlockText(
            NSRange(location: 10, length: 11), ranges: ranges)
            == NSRange(location: 11, length: 9))
        // Neither edge on one: untouched, exactly.
        #expect(CrossBlockCompound.clampedToBlockText(
            NSRange(location: 6, length: 10), ranges: ranges)
            == NSRange(location: 6, length: 10))
        #expect(CrossBlockCompound.clampedToBlockText(
            NSRange(location: 0, length: 33), ranges: ranges)
            == NSRange(location: 0, length: 33))
    }

    /// **THE TAIL FENCE** (the ruling's own, from the 13u1 ladder's sanity
    /// pass): *the trim speaks only of a separator BETWEEN TWO BLOCKS.* The
    /// open tail is not a block, so its separator is never a candidate — and
    /// the loop's `ranges.count - 1` bound is the whole fence.
    @Test func theOpenTailsOwnSeparatorIsNeverTrimmed() {
        let tailed = Self.index([10, 9], tail: 4)   // tail separator at 20
        let ranges = tailed.entryRanges()
        #expect(tailed.tailSeparatorOffset == 20)
        // A span closing ON the tail's separator keeps its end where she put
        // it, so the plan still declines on contiguity and the TAIL's own
        // cause and road are what she reads.
        #expect(CrossBlockCompound.clampedToBlockText(
            NSRange(location: 6, length: 15), ranges: ranges)
            == NSRange(location: 6, length: 15))
        // The inter-block separator at 10 is trimmed in the same document —
        // the fence is the tail's separator, never "no trimming near a tail".
        #expect(CrossBlockCompound.clampedToBlockText(
            NSRange(location: 6, length: 5), ranges: ranges)
            == NSRange(location: 6, length: 4))
        // A tail-free document's LAST separator is its tail separator's
        // absence, not a boundary: the last entry's end is the document end.
        let bare = Self.index([10, 9])
        #expect(CrossBlockCompound.clampedToBlockText(
            NSRange(location: 6, length: 14), ranges: bare.entryRanges())
            == NSRange(location: 6, length: 14))
    }

    /// **THE ONE ASYMMETRY, and it has a ruled precedent** —
    /// `BlockRangeIndex.wholeBlockRun`'s A8 fence from the other side. A
    /// ZERO-LENGTH entry's position IS its predecessor's separator offset. At
    /// the LEADING edge that entry is INSIDE the half-open span (she dragged
    /// from the blank line), so trimming there would drop the empty block out
    /// of her own selection — the leading trim therefore requires the entry
    /// to have characters. At the TRAILING edge the mirror is false: a
    /// zero-length entry at `upperBound` is NOT covered, so the trailing trim
    /// needs no such condition.
    @Test func aZeroLengthEntryAtTheSpansStartIsNotTrimmedAway() {
        // "" \n "bbbb" \n "cccc"  →  ranges [0,0) [1,5) [6,10)
        let leadingEmpty = Self.index([0, 4, 4])
        let ranges = leadingEmpty.entryRanges()
        #expect(ranges.first == NSRange(location: 0, length: 0))
        #expect(CrossBlockCompound.clampedToBlockText(
            NSRange(location: 0, length: 8), ranges: ranges)
            == NSRange(location: 0, length: 8),
            "the empty first block stays inside the span she made")

        // The trailing mirror: "aaaaa" \n "" \n "ccccc" → [0,5) [6,6) [7,12).
        let middleEmpty = Self.index([5, 0, 5])
        let mid = middleEmpty.entryRanges()
        #expect(mid == [
            NSRange(location: 0, length: 5),
            NSRange(location: 6, length: 0),
            NSRange(location: 7, length: 5),
        ])
        // [2,6) stops AT the empty block's position without covering it, so
        // its trailing edge really is sitting on the separator at 5.
        #expect(CrossBlockCompound.clampedToBlockText(
            NSRange(location: 2, length: 4), ranges: mid)
            == NSRange(location: 2, length: 3))
        // [2,7) COVERS the empty block (its position is inside the span) and
        // closes on the separator after it: exactly one trim, and the empty
        // block stays in the run for the plan to send to the tray.
        #expect(CrossBlockCompound.clampedToBlockText(
            NSRange(location: 2, length: 5), ranges: mid)
            == NSRange(location: 2, length: 4))
    }

    /// **THE DEGENERATE SHAPE.** A span that is exactly ONE separator holds
    /// no block text at all: both edges trim toward each other and cross. The
    /// answer is a zero-length span at the LEADING block's own end — where
    /// the selection opened — and a DELETE there is declined outright, so
    /// A7's empty-block carve and #34's texted-seam merge keep every case
    /// they ruled. *(PROVISIONAL — QUESTIONS #111.)*
    @Test func theLoneSeparatorCollapsesToTheLeadingBlocksEndAndADeleteIsNotThisRoads() {
        let index = Self.index([10, 9])
        let ranges = index.entryRanges()
        #expect(CrossBlockCompound.clampedToBlockText(
            NSRange(location: 10, length: 1), ranges: ranges)
            == NSRange(location: 10, length: 0))
        // Typing over it lands at A's end — a legal in-block offset.
        let typed = CrossBlockCompound.clampedInBlockEdit(
            replacing: NSRange(location: 10, length: 1), with: "X",
            index: index, surfaceText: { _ in "" })
        #expect(typed?.range == NSRange(location: 10, length: 0))
        #expect(typed?.entryIndex == 0)
        // Deleting it is A7's / #34's keystroke, and this road declines so it
        // can never route around their authorizations.
        #expect(CrossBlockCompound.clampedInBlockEdit(
            replacing: NSRange(location: 10, length: 1), with: "",
            index: index, surfaceText: { _ in "" }) == nil)
    }

    /// Shape (ii) is NOT this road's: once the clamped span still reaches two
    /// blocks it belongs to the compound, which trims for itself.
    @Test func aClampedSpanReachingTwoBlocksIsNotAnInBlockEdit() {
        let index = Self.index([10, 9, 12])
        #expect(CrossBlockCompound.clampedInBlockEdit(
            replacing: NSRange(location: 10, length: 17), with: "",
            index: index, surfaceText: { _ in "" }) == nil)
        // …and a span with no edge on a boundary is not this road's either.
        #expect(CrossBlockCompound.clampedInBlockEdit(
            replacing: NSRange(location: 6, length: 10), with: "",
            index: index, surfaceText: { _ in "" }) == nil)
    }

    // MARK: - What `.partialBlockAcrossSeam` retired to

    /// **THE RETIREMENT, PROVEN RATHER THAN ASSERTED.** #109's ruling says
    /// the boundary cause *"retires to the shapes that remain, if any"*. The
    /// boundary FAMILY is gone — every shape above is taken — but the case is
    /// not unreachable, so it was renamed to what genuinely survives rather
    /// than deleted. This pin drives the survivor the pure brain can reach:
    /// a SEAM keystroke whose neighbour the PROJECTION cannot describe yet
    /// (`slots` is deliberately held stale while the buffer is dirty and can
    /// be shorter than `entries`), where A7's carve declines on its own
    /// bounds guard and step 1's fan/archived/comment reads are all skipped.
    ///
    /// The sentence must no longer claim a geometry, and must still name a
    /// road that opens (the 13u1 ladder's rule).
    @Test func theSurvivingResidualsAreNamedAndNeitherIsAGeometry() {
        // SURVIVOR 1 — the SEAM keystroke no carve could take. An EMPTY
        // block beside a texted one (A7's own geometry) with NO projection
        // yet: A7 declines on its bounds guard and step 1's fan/archived/
        // comment reads are all skipped, so none of them can say which
        // authorization failed. (On the phone this shape is permanent: it
        // has no seam carves at all.)
        let seam = BlockRangeIndex(
            entries: [
                BlockRangeIndex.Entry(blockID: "b0", variantID: "v0", length: 0, editable: true),
                BlockRangeIndex.Entry(blockID: "b1", variantID: "v1", length: 3, editable: true),
            ],
            tailLength: nil)
        #expect(CrossBlockRefusal.diagnose(
            range: NSRange(location: 0, length: 1), index: seam, slots: [])
            == .seamKeystrokeDeclined)
        let seamMessage = CrossBlockRefusal.message(for: .seamKeystrokeDeclined)
        #expect(seamMessage.contains("can't join these two blocks"),
                "it names what declined: \(seamMessage)")
        #expect(seamMessage.contains("Merge"),
                "…and the deliberate merge, which really opens: \(seamMessage)")

        // SURVIVOR 2 — step 4's fallback, whose production reach is a
        // surface that disagrees with its own index.
        let clean = Self.index([2, 3, 1])
        #expect(CrossBlockRefusal.diagnose(
            range: NSRange(location: 1, length: 5), index: clean,
            slots: [slot("b0", text: "aa"), slot("b1", text: "bbb"), slot("b2", text: "c")])
            == .surfaceNotSettled)

        // NEITHER may keep the retired boundary geometry in its words.
        for cause in [CrossBlockRefusal.Cause.seamKeystrokeDeclined, .surfaceNotSettled] {
            let message = CrossBlockRefusal.message(for: cause)
            #expect(!message.lowercased().contains("boundary"),
                    "the retired geometry must not survive in the words: \(message)")
            #expect(!message.contains("Nudge that end"),
                    "…nor the road that only helped that geometry: \(message)")
        }
        let settling = CrossBlockRefusal.message(for: .surfaceNotSettled)
        #expect(settling.contains("settling"), "it names what actually declined: \(settling)")
        #expect(settling.contains("moment"), "…and a road that opens: \(settling)")
    }

    // MARK: - Shape (i): clamp and EDIT, through the real keystroke path

    /// **HER SHAPE (i).** Drag from the middle of a paragraph and release
    /// exactly where the next one begins, then press ⌫. The selection clamps
    /// to that block's text and edits; the break she selected STANDS.
    ///
    /// **RED ON OLD:** this refused — *"One end of this selection sits on the
    /// boundary between two blocks."* — and nothing changed in the store.
    @Test func aSpanEndingWhereTheNextBlockBeginsClampsAndEdits() async throws {
        try await withEditor(
            seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]
        ) { h in
            let before = try h.storeSlots().map(\.blockID)
            // "one." plus the separator at 10 — released exactly where
            // "Beta" begins.
            h.replace(NSRange(location: 6, length: 5), with: "")
            await h.flush()

            let after = try h.storeSlots()
            #expect(after.compactMap(\.text) == ["Alpha ", "Beta two.", "Gamma three."],
                    "the block lost its tail; the break stands and nothing merged")
            #expect(after.map(\.blockID) == before, "every block kept its identity")
            #expect(h.model.statusMessage == nil, "no refusal: \(h.model.statusMessage ?? "")")
            #expect(h.documentText == "Alpha \nBeta two.\nGamma three.")
        }
    }

    /// **The mirror.** Anchor at a paragraph's END — the offset before the
    /// newline, an everyday anchor — and ⇧-extend into the next paragraph.
    ///
    /// **RED ON OLD:** the same refusal, nothing changed.
    @Test func aSpanOpeningAtAParagraphsEndClampsAndEdits() async throws {
        try await withEditor(
            seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]
        ) { h in
            let before = try h.storeSlots().map(\.blockID)
            // The separator at 10 plus "Beta " (five characters of B).
            h.replace(NSRange(location: 10, length: 6), with: "")
            await h.flush()

            let after = try h.storeSlots()
            #expect(after.compactMap(\.text) == ["Alpha one.", "two.", "Gamma three."],
                    "the next block lost its head; the break stands")
            #expect(after.map(\.blockID) == before)
            #expect(h.model.statusMessage == nil, "no refusal: \(h.model.statusMessage ?? "")")
        }
    }

    /// A gesture that TYPES over the same span lands its text inside the one
    /// block, where the selection opened.
    ///
    /// **RED ON OLD:** refused; the typed character was dropped.
    @Test func typingOverABoundaryAnchoredSpanLandsInsideTheOneBlock() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            h.replace(NSRange(location: 6, length: 5), with: "X")
            await h.flush()

            let texts = try h.storeSlots().compactMap(\.text)
            #expect(texts == ["Alpha X", "Beta two."])
        }
    }

    /// **The whole paragraph plus BOTH its newlines, typed over.** A DELETE
    /// of this span is her J9 gesture (the paragraph GOES, tray and all) and
    /// keeps its own road above this one; a type-over is not a delete, so it
    /// clamps to the block whole and replaces its text in place.
    ///
    /// **RED ON OLD:** refused.
    @Test func typingOverAParagraphWithBothItsNewlinesReplacesItInPlace() async throws {
        try await withEditor(
            seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]
        ) { h in
            let before = try h.storeSlots().map(\.blockID)
            // From A's end (10) through B's trailing separator (20).
            h.replace(NSRange(location: 10, length: 11), with: "Fresh.")
            await h.flush()

            let after = try h.storeSlots()
            #expect(after.compactMap(\.text) == ["Alpha one.", "Fresh.", "Gamma three."])
            #expect(after.map(\.blockID) == before, "B kept its identity — nothing was minted")
        }
    }

    /// **The undo grammar, and this is the reason shape (i) is not a
    /// compound.** After the clamp the gesture is an ordinary in-block edit,
    /// so ⌘Z is AppKit's own text undo and the STRUCTURAL stack is untouched
    /// — no ⌥⌘Z entry appears for a plain deletion inside one paragraph.
    ///
    /// *(What is asserted here is the half a harness CAN see: no structural
    /// entry, and no structural rewrite of the tiling. `NSTextView.undoManager`
    /// comes from the view's WINDOW, and this harness mounts no window, so it
    /// is nil here for every road alike — the ⌘Z half is walked in the app
    /// instead, and the UNIT C record carries that capture.)*
    @Test func shapeOneIsOrdinaryTextUndoAndRegistersNoStructuralEntry() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let depth = h.session.undoStack.depth
            h.replace(NSRange(location: 6, length: 5), with: "")
            await h.flush()

            let texts = try h.storeSlots().compactMap(\.text)
            #expect(texts == ["Alpha ", "Beta two."])
            #expect(h.session.undoStack.depth == depth,
                    "no structural entry for an in-block edit")
            #expect(h.model.index.entries.count == 2,
                    "…and no structural rewrite: the tiling is what it was")
            #expect(h.textView.allowsUndo, "the surface's own undo is on")
        }
    }

    /// A clamped span inside a LOCKED take refuses in that take's own words —
    /// the ordinary in-block refusal, not a boundary one. The road the law
    /// opens is the ordinary road, refusals included.
    @Test func aClampedSpanInsideALockedTakeRefusesInTheTakesOwnWords() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let first = try h.storeSlots()[0]
            try await h.session.runner.run { ops in try ops.lockVariant(first.variantID!) }
            try h.reload()

            h.replace(NSRange(location: 6, length: 5), with: "")
            await h.flush()

            let texts = try h.storeSlots().compactMap(\.text)
            #expect(texts == ["Alpha one.", "Beta two."],
                    "nothing changed")
            let status = try #require(h.model.statusMessage)
            #expect(status.contains("locked"), "the refusal names the lock: \(status)")
        }
    }

    // MARK: - Shape (ii): the TRIM, through the real keystroke path

    /// **HER SHAPE (ii), verbatim from #109:** *anchor the selection at a
    /// paragraph's END (the offset before the newline) and ⇧-extend into the
    /// paragraph after next.* The edge separator is absorbed into the run, so
    /// the block beside it is covered WHOLE and rides `deleteBlock` to the
    /// tray; the far end keeps its ordinary partial edit; R-13u-2 answers the
    /// join (the cut at the trimmed end sits at a paragraph break, so the
    /// ends keep their own blocks).
    ///
    /// **RED ON OLD:** the compound's contiguity guard refused this exact
    /// span — it is the pin the 13u1 ladder's F-2 landed, and the shape she
    /// ruled *"Take it"* on.
    @Test func aSpanOpeningOnTheSeparatorTrimsAndTraysTheWholeBlock() async throws {
        try await withEditor(
            seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]
        ) { h in
            let before = try h.storeSlots().map(\.blockID)
            // From the END of A (offset 10 — ON the separator) through
            // "Gamma ": B covered whole, C in part, A's characters untouched.
            h.replace(NSRange(location: 10, length: 17), with: "")
            await h.flush()

            let after = try h.storeSlots()
            #expect(after.compactMap(\.text) == ["Alpha one.", "three."],
                    "A untouched; B gone; C keeps its own block — no join at a paragraph break")
            #expect(after.map(\.blockID) == [before[0], before[2]])

            let trayed = try await h.database.read { [postID = h.postID] db in
                try Queries.trayBlocks(db, postID: postID, now: harnessNow).map(\.blockID)
            }
            #expect(trayed == [before[1]], "the wholly covered block waits in this note's tray")
        }
    }

    /// The trailing mirror: from mid-paragraph through a whole one, closing
    /// exactly where the paragraph after it begins.
    ///
    /// **RED ON OLD:** refused on the same guard.
    @Test func aSpanClosingOnTheSeparatorTrimsAndTraysTheWholeBlock() async throws {
        try await withEditor(
            seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]
        ) { h in
            let before = try h.storeSlots().map(\.blockID)
            // "one." + B whole + the separator at 20, stopping where C begins.
            h.replace(NSRange(location: 6, length: 15), with: "")
            await h.flush()

            let after = try h.storeSlots()
            #expect(after.compactMap(\.text) == ["Alpha ", "Gamma three."])
            #expect(after.map(\.blockID) == [before[0], before[2]])

            let trayed = try await h.database.read { [postID = h.postID] db in
                try Queries.trayBlocks(db, postID: postID, now: harnessNow).map(\.blockID)
            }
            #expect(trayed == [before[1]])
        }
    }

    /// **ONE ⌥⌘Z entry for a trimmed compound**, exactly as for any other —
    /// one undo grammar, never two — and undo puts the exact rows back.
    @Test func theTrimmedGestureIsOneStructuralEntryAndUndoRestoresTheExactRows() async throws {
        try await withEditor(
            seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]
        ) { h in
            let before = try h.storeSlots()
            let depth = h.session.undoStack.depth

            h.replace(NSRange(location: 10, length: 17), with: "")
            await h.flush()
            #expect(h.session.undoStack.depth == depth + 1)
            #expect(h.session.undoStack.topLabel == CrossBlockCompound.undoLabel)

            let stack = h.session.undoStack
            try await h.session.runner.run { ops in _ = try stack.undo(with: ops) }
            try h.reload()
            let undone = try h.storeSlots()
            #expect(undone.map(\.blockID) == before.map(\.blockID))
            #expect(undone.compactMap(\.text) == before.compactMap(\.text))
        }
    }

    /// An EMPTY block sitting where the trim lands is an ordinary member of
    /// the run: covered whole, so it goes to the tray with everything else.
    /// (13u1's U-4 fix, meeting the clamp.)
    @Test func anEmptyBlockAtTheTrimmedEndGoesToTheTrayLikeAnyOther() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "", "Gamma three."]) { h in
            // "Alpha one." \n "" \n "Gamma three." → A=[0,10) E=[11,11) C=[12,24)
            #expect(h.documentText == "Alpha one.\n\nGamma three.")
            let before = try h.storeSlots().map(\.blockID)
            // "one." + the separator at 10 + the empty block + its separator.
            h.replace(NSRange(location: 6, length: 6), with: "")
            await h.flush()

            let after = try h.storeSlots()
            #expect(after.compactMap(\.text) == ["Alpha ", "Gamma three."])
            #expect(after.map(\.blockID) == [before[0], before[2]])
            let trayed = try await h.database.read { [postID = h.postID] db in
                try Queries.trayBlocks(db, postID: postID, now: harnessNow).map(\.blockID)
            }
            #expect(trayed == [before[1]], "the empty block she selected really went")
        }
    }

    // MARK: - What the law does NOT take: the tail, and the locks

    /// **THE TAIL FENCE, in the app.** A span closing on the OPEN TAIL's own
    /// separator keeps the tail's cause and the tail's road — the tail is not
    /// a block, so it is never a neighbour the run can absorb.
    @Test func aSpanClosingOnTheTailsSeparatorStillSpeaksTheTailsRefusal() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            h.type("\n", at: h.model.index.documentLength)
            h.type("tail")
            await h.settle()
            #expect(h.model.index.tailLength == 4)

            // "one." + separator + B whole + the TAIL's separator (20).
            h.replace(NSRange(location: 6, length: 15), with: "")
            await h.flush()

            let texts = try h.storeSlots().compactMap(\.text)
            #expect(texts == ["Alpha one.", "Beta two."],
                    "nothing changed — the tail fence holds")
            let status = try #require(h.model.statusMessage)
            #expect(status.contains("isn't a block yet"),
                    "the tail's own cause, not a boundary one: \(status)")
            #expect(status.contains("pause typing"), "…and the tail's own road: \(status)")
        }
    }

    /// The EMPTY tail's doorstep keeps its own cause too (the 13u1 ladder's
    /// R2-1 split — an empty tail never mints, so its road is the nudge and
    /// the empty line's own delete).
    @Test func aSpanClosingOnAnEmptyTailsSeparatorKeepsItsOwnRefusal() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            h.type("\n", at: h.model.index.documentLength)
            await h.settle()
            #expect(h.model.index.tailLength == 0)

            h.replace(NSRange(location: 6, length: 15), with: "")
            await h.flush()

            let texts = try h.storeSlots().compactMap(\.text)
            #expect(texts == ["Alpha one.", "Beta two."])
            let status = try #require(h.model.statusMessage)
            #expect(status.contains("empty line"), "the empty tail's own cause: \(status)")
        }
    }

    /// **R-13u-1 still binds a TRIMMED run:** a locked take anywhere in the
    /// run refuses the whole gesture, naming the lock. *(Green on both trees
    /// — a PRESERVED behaviour, pinned here because the clamp changed which
    /// spans reach the run at all.)*
    @Test func aLockedTakeInATrimmedRunStillRefusesTheWholeGesture() async throws {
        try await withEditor(
            seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]
        ) { h in
            let middle = try h.storeSlots()[1]
            try await h.session.runner.run { ops in try ops.lockVariant(middle.variantID!) }
            try h.reload()

            h.replace(NSRange(location: 10, length: 17), with: "")
            await h.flush()

            let texts = try h.storeSlots().compactMap(\.text)
            #expect(texts
                == ["Alpha one.", "Beta two.", "Gamma three."], "NOTHING changed")
            let status = try #require(h.model.statusMessage)
            #expect(status.contains("locked"), "the refusal names the lock: \(status)")
        }
    }

    /// **A locked block the clamp TRIMMED PAST does not refuse.** The run is
    /// derived from the span she made, and a block whose separator was merely
    /// trimmed contributes no characters — so it is not in the run, and
    /// R-13u-1 cannot refuse a gesture that does not touch it. (This is
    /// exactly the cost option (c) was criticised for in #109, and the law
    /// does not pay it.)
    @Test func aLockedBlockBesideTheTrimmedSeparatorDoesNotRefuse() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let first = try h.storeSlots()[0]
            try await h.session.runner.run { ops in try ops.lockVariant(first.variantID!) }
            try h.reload()

            // Opens ON A's trailing separator and edits only B.
            h.replace(NSRange(location: 10, length: 6), with: "")
            await h.flush()

            let texts = try h.storeSlots().compactMap(\.text)
            #expect(texts == ["Alpha one.", "two."],
                    "the locked neighbour was never touched, and never refused")
        }
    }
}
