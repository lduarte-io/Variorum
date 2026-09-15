//
//  CrossBlockCompoundTests.swift
//  VariorumTests
//
//  **HER ITEM 5, PINNED** (13u1 UNIT 2). Her direction (2026-08-21):
//  *"obvious and intuitive operations like selecting a bunch of visible text
//  and deleting should be allowed - the refusing because of different blocks
//  is more annoying than it's worth"*, with the north star beside it: *"my
//  goal is for it to not feel like a headache compared to using a different
//  editor."*
//
//  Every test here drives the REAL keystroke path — `textView.insertText`
//  through `NSTextInputClient` → the gate's cross-block arm → the deferred
//  compound → the structural rewrite — and then reads the STORE. A plan-level
//  assertion proves geometry; only the store proves rows.
//
//  The rulings each pin holds are named at the pin.
//

import AppKit
import Foundation
import Testing
import VariorumCore

@testable import Variorum

@Suite("The cross-block compound (13u1 UNIT 2 — her item 5)")
struct CrossBlockCompoundTests {

    // MARK: - R-13u-2: where the ends join, and where they do not

    /// **The everyday case, and the one her ruling optimizes for.** Select
    /// from the middle of one paragraph into the middle of another and press
    /// ⌫: the selection vanishes and the remainders become ONE paragraph,
    /// *"the way any editor would join them"*. Both cut ends sit
    /// mid-paragraph, so the ends MERGE — through the standing `merge`, so
    /// both originals are preserved whole with `derived_from` edges (her
    /// condition: *the previous blocks must be EASY TO SEE in lineage*).
    @Test func aSpanFromMidParagraphToMidParagraphJoinsTheRemainders() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            #expect(h.documentText == "Alpha one.\nBeta two.")
            // "one.\nBeta " — from offset 6 through offset 16.
            h.replace(NSRange(location: 6, length: 10), with: "")
            await h.flush()

            let texts = try h.storeSlots().compactMap(\.text)
            #expect(texts == ["Alpha two."], "ONE block: the remainders joined, with no space minted")
            #expect(h.documentText == "Alpha two.")

            // Both originals are in the new block's lineage, preserved whole.
            let merged = try #require(try h.storeSlots().first?.blockID)
            let ancestors = try await h.database.read { db -> [String] in
                let nodes = try Queries.ancestors(db, of: merged)
                return try nodes.compactMap { node in
                    try Queries.blockFan(db, blockID: node.blockID).first?.workingText
                }
            }
            #expect(ancestors.sorted() == ["Alpha one.", "Beta two."],
                    "both halves are kept whole under Came from")
        }
    }

    /// **R-13u-2, the BLOCK-SEAM half** (the 13u1 kickoff sitting: *"paragraph
    /// break" covers BOTH a block seam and an internal newline*). The
    /// selection opens at the very start of the first block — a cut at the
    /// paragraph break the eye reads between two blocks — so the remainders
    /// do NOT join. Her own words: *"if the place cut at was a paragraph
    /// though, I don't think it should be merged."*
    @Test func aSpanOpeningAtABlockSStartDoesNotJoinTheEnds() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            // From offset 0 through "Beta " — the first block goes whole.
            h.replace(NSRange(location: 0, length: 16), with: "")
            await h.flush()

            let texts = try h.storeSlots().compactMap(\.text)
            #expect(texts == ["two."],
                    "the wholly covered block went to the Trash; the remainder kept its own block")
        }
    }

    /// **R-13u-2, the INTERNAL-NEWLINE half** — I4's surface paragraphs. The
    /// first block holds two paragraphs of its own; the selection opens right
    /// after its internal newline, which is a paragraph break all the same,
    /// so the ends keep their own blocks.
    @Test func aSpanOpeningAfterAnInternalNewlineDoesNotJoinTheEnds() async throws {
        try await withEditor(seedBlocks: ["Alpha one.\nAlpha two.", "Beta three."]) { h in
            #expect(h.documentText == "Alpha one.\nAlpha two.\nBeta three.")
            // From offset 11 (right after the INTERNAL newline) through "Beta ".
            h.replace(NSRange(location: 11, length: 16), with: "")
            await h.flush()

            let texts = try h.storeSlots().compactMap(\.text)
            #expect(texts == ["Alpha one.\n", "three."],
                    "two blocks: the cut sat at an internal paragraph break")
        }
    }

    /// The mirror at the other end: the selection CLOSES right before an
    /// internal newline, so the ends do not join either. One rule, both
    /// ends — which is why `cutIsAtAParagraphBreak` is one function.
    @Test func aSpanClosingAtAnInternalParagraphEndDoesNotJoinTheEnds() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.\nBeta three."]) { h in
            // From "one." through the END of "Beta two." (offset 20), which
            // is immediately before the internal newline.
            h.replace(NSRange(location: 6, length: 14), with: "")
            await h.flush()

            let texts = try h.storeSlots().compactMap(\.text)
            #expect(texts == ["Alpha ", "\nBeta three."],
                    "two blocks: the closing cut sat at an internal paragraph break")
        }
    }

    // MARK: - The middles: the Trash/tray road, ONE undo entry

    /// **Her ruling's first clause:** blocks the selection covers WHOLE ride
    /// `deleteBlock` — the 13j Trash/tray road, every take preserved, Put
    /// back real. The ends survive, keep their identity, and join because
    /// both cuts are mid-paragraph.
    @Test func whollyCoveredMiddlesGoToTheTrayAndTheEndsJoin() async throws {
        try await withEditor(
            seedBlocks: ["Alpha one.", "Beta two.", "Gamma three.", "Delta four."]
        ) { h in
            let before = try h.storeSlots().map(\.blockID)
            // "one.\nBeta two.\nGamma three.\nDelta " — offsets 6 through 40.
            h.replace(NSRange(location: 6, length: 34), with: "")
            await h.flush()

            let texts = try h.storeSlots().compactMap(\.text)
            #expect(texts == ["Alpha four."], "one joined block survives")

            // The two middles really are TOMBSTONED, not merged away — the
            // whole point of the Trash/tray road, and what makes Put back
            // real.
            let deleted = try await h.database.read { [postID = h.postID] db in
                try Queries.trayBlocks(db, postID: postID, now: harnessNow).map(\.blockID)
            }
            #expect(deleted.sorted() == [before[1], before[2]].sorted(),
                    "the middles wait in this note's tray")
        }
    }

    /// **ONE gesture = ONE ⌥⌘Z entry**, and the exact-row redo beside it
    /// (AppSpec §9's structural redo: *undo → redo returns the store to the
    /// post-do rows with every ID intact*). This is the grammar the Blocks
    /// workbench's bulk bar already speaks — one undo grammar, never two.
    @Test func theWholeGestureIsOneUndoEntryAndRedoReturnsTheExactRows() async throws {
        try await withEditor(
            seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]
        ) { h in
            let before = try h.storeSlots()
            let depthBefore = h.session.undoStack.depth

            h.replace(NSRange(location: 6, length: 21), with: "")  // "one.…Gamma "
            await h.flush()
            #expect(h.session.undoStack.depth == depthBefore + 1,
                    "ONE entry for the whole compound")
            #expect(h.session.undoStack.topLabel == CrossBlockCompound.undoLabel)
            let after = try h.storeSlots()
            #expect(after.compactMap(\.text) == ["Alpha three."])

            let stack = h.session.undoStack
            try await h.session.runner.run { ops in _ = try stack.undo(with: ops) }
            try h.reload()
            let undone = try h.storeSlots()
            #expect(undone.map(\.blockID) == before.map(\.blockID),
                    "undo puts the exact blocks back, in order")
            #expect(undone.compactMap(\.text) == before.compactMap(\.text))

            try await h.session.runner.run { ops in _ = try stack.redo(with: ops) }
            try h.reload()
            let redone = try h.storeSlots()
            #expect(redone.map(\.blockID) == after.map(\.blockID),
                    "redo is exact-row: the SAME merged block id comes back")
            #expect(redone.compactMap(\.text) == after.compactMap(\.text))
        }
    }

    // MARK: - Fans (her ruling, and #11a's standing rule at the ends)

    /// **A fanned MIDDLE deletes WHOLE to the tray** — her ruling, and the
    /// one place item 5 supersedes #11a, which emptied the middle's shown
    /// take and left a blank block with a fan hanging on it. *"Recoverable,
    /// family intact"* is what she chose instead: the block is tombstoned
    /// with its whole fan, and Put back returns all of it.
    @Test func aFannedMiddleBlockGoesToTheTrayWithItsWholeFan() async throws {
        try await withEditor(
            seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]
        ) { h in
            let middle = try h.storeSlots()[1]
            try await h.session.runner.run { ops in
                let take = try ops.branchVariant(middle.blockID, from: middle.variantID!)
                try ops.autosave(take.id, text: "Beta two, another take.", charDelta: 20)
            }
            try h.reload()

            h.replace(NSRange(location: 6, length: 21), with: "")  // "one.…Gamma "
            await h.flush()

            let texts = try h.storeSlots().compactMap(\.text)
            #expect(texts == ["Alpha three."])
            let deleted = try await h.database.read { [postID = h.postID] db in
                try Queries.trayBlocks(db, postID: postID, now: harnessNow)
            }
            #expect(deleted.map(\.blockID) == [middle.blockID])
            // Its takes rode with it — NOTHING was emptied in place. They
            // are cascade-tombstoned under the block's exact stamp, which is
            // precisely what makes `restoreBlock` bring the whole family
            // back (Put back is real).
            let fan = try await h.database.read { [blockID = middle.blockID] db -> [String] in
                // Read PAST the cascade tombstones deliberately — that they
                // are tombstoned under the block's own stamp is exactly what
                // makes `restoreBlock` bring the whole family back.
                try Queries.deletedTakes(db, blockID: blockID, now: harnessNow)
                    .map(\.workingText).sorted()
            }
            #expect(fan == ["Beta two, another take.", "Beta two."].sorted(),
                    "both takes are preserved on the tombstoned block")
        }
    }

    /// **A fan on a surviving END suppresses the JOIN, never the edit**
    /// (#11a's standing rule, carried forward: *the halves JOIN only where no
    /// fan hangs on the seam*). The chosen take takes its edit; the other
    /// take is untouched; the two blocks stay two blocks.
    @Test func aFanOnASurvivingEndKeepsTwoBlocksAndTouchesOnlyTheChosenTake() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let first = try h.storeSlots()[0]
            try await h.session.runner.run { ops in
                let take = try ops.branchVariant(first.blockID, from: first.variantID!)
                try ops.autosave(take.id, text: "Alpha one, unshown.", charDelta: 18)
            }
            try h.reload()

            h.replace(NSRange(location: 6, length: 10), with: "")  // "one.\nBeta "
            await h.flush()

            let texts = try h.storeSlots().compactMap(\.text)
            #expect(texts == ["Alpha ", "two."], "TWO blocks — a keystroke won't fold a fan away")
            let fan = try await h.database.read { [blockID = first.blockID] db in
                try Queries.blockFan(db, blockID: blockID).map(\.workingText)
            }
            #expect(fan.contains("Alpha one, unshown."), "the unshown take is untouched")
            let status = try #require(h.model.statusMessage)
            #expect(status.contains("one has takes"),
                    "the receipt says WHY they stayed apart: \(status)")
        }
    }

    /// **U-1's correctness half, as a law:** never authorize from stale
    /// state. The projection is deliberately frozen while the buffer is
    /// dirty, so a take that ARRIVES during a typing burst is invisible to
    /// it — and the join must still stand down. The fan is read from the
    /// STORE inside the flight, so it does.
    ///
    /// **RED ON OLD:** the retired planner read `fanArities` from
    /// `model.slots` at plan time, so this block looked unfanned and the two
    /// blocks were merged away with the newly arrived take left hanging on a
    /// released original.
    @Test func aTakeArrivingDuringTheTypingBurstStopsTheJoin() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let first = try h.storeSlots()[0]
            // Dirty the buffer: the projection freezes from here.
            h.type("!", at: 10)
            #expect(h.model.autosave.isDirty)

            // A take lands from elsewhere — another pane, a sync arrival.
            try await h.session.runner.run { ops in
                let take = try ops.branchVariant(first.blockID, from: first.variantID!)
                try ops.autosave(take.id, text: "Alpha one, from elsewhere.", charDelta: 25)
            }
            #expect(h.model.slots[0].activeVariantCount == 1,
                    "the PROJECTION still says one take — this is the stale state")

            h.replace(NSRange(location: 6, length: 11), with: "")  // "one.!\nBeta "
            await h.flush()

            let texts = try h.storeSlots().compactMap(\.text)
            #expect(texts == ["Alpha ", "two."],
                    "the join stood down on the STORE's answer, not the projection's")
        }
    }

    // MARK: - Refusals: sealed note + locked take, and nothing else

    /// **R-13u-1: a locked take anywhere in the selection REFUSES THE WHOLE
    /// gesture, naming the lock.** One gesture, one answer — the bulk
    /// grammar's all-or-nothing precedent (#93(c)). Nothing is deleted,
    /// nothing is edited, and the refusal says so.
    @Test func aLockedTakeInTheRunRefusesTheWholeGestureNamingTheLock() async throws {
        try await withEditor(
            seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]
        ) { h in
            let middle = try h.storeSlots()[1]
            try await h.session.runner.run { ops in try ops.lockVariant(middle.variantID!) }
            try h.reload()

            h.replace(NSRange(location: 6, length: 21), with: "")
            await h.flush()

            let texts = try h.storeSlots().compactMap(\.text)
            #expect(texts == ["Alpha one.", "Beta two.", "Gamma three."],
                    "NOTHING changed — refuse whole")
            let status = try #require(h.model.statusMessage)
            #expect(status.contains("locked"), "the refusal names the lock: \(status)")
            #expect(status.contains("nothing was changed") || status.contains("Nothing was changed"),
                    "…and says nothing happened: \(status)")
        }
    }

    /// **A SEALED note refuses before any plan runs** — the seal freezes
    /// everything under the post, and the gate's own guard is what she meets.
    @Test func aSealedNoteRefusesTheGestureBeforeAnyPlanRuns() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            try await h.session.runner.run { ops in try ops.lockPost(h.postID) }
            try h.reload()

            // The seal's first face is that the surface itself goes
            // read-only, so a keystroke never reaches the gate at all; the
            // gate's own guard is the belt behind it, and this drives it
            // directly.
            #expect(h.textView.isEditable == false, "a sealed note's surface is read-only")
            #expect(h.model.shouldChangeText(
                in: NSRange(location: 6, length: 10), replacement: "") == false)
            #expect(h.model.statusMessage?.contains("sealed") == true)
            #expect(try h.storeSlots().compactMap(\.text) == ["Alpha one.", "Beta two."])
        }
    }

    /// **The GAP fence** (item 8's U-3): a block whose variant has not
    /// ARRIVED renders with zero length, so a span runs straight past it —
    /// and tombstoning it would delete a peer's paragraph under
    /// tombstone-wins, one keystroke after the app said aloud that the block
    /// is read-only until it syncs. The compound's run is an index RANGE
    /// precisely so it can SEE that block, and the refusal names it.
    ///
    /// **RED ON OLD:** the retired planner collected by intersection, never
    /// saw the gap, planned a merge ACROSS it, and the operations layer
    /// refused with a raw `blocksNotAdjacent(first:second:)` enum dump.
    /// *(Renamed at the 13u1 ladder, round 1 — it was
    /// `…AndNamesTheBlockThatHasNotArrived`, but the sentence deliberately
    /// names the CAUSE, never a block: naming rows is the enum-dump class
    /// this whole family exists to end.)*
    @Test func aGapInsideTheSpanRefusesAndNamesTheCause() async throws {
        try await withEditor { h in
            h.model.applyProjection([
                slot("b0", text: "Alpha one."),
                slot("b1", text: nil),            // the gap: no variant yet
                slot("b2", text: "Beta two."),
            ])
            #expect(h.model.planCrossBlockEdit(
                range: NSRange(location: 6, length: 11), replacement: "") == nil)

            let cause = CrossBlockRefusal.diagnose(
                range: NSRange(location: 6, length: 11),
                index: h.model.index, slots: h.model.slots)
            #expect(cause == .unsyncedBlock, "the refusal names the real cause, not the residual")
            #expect(!CrossBlockRefusal.message(for: cause).contains("blocksNotAdjacent"),
                    "never the raw enum")
        }
    }

    /// **THE SHAPE SHE RULED ON, NOW TAKEN** (13u2 UNIT C — #109's boundary
    /// -clamp law). A span can open (or close) ON the boundary separator
    /// while reaching into TWO OR MORE blocks' characters — anchor the
    /// selection at a paragraph's END (the offset before the newline) and
    /// ⇧-extend into the paragraph after next. The 13u1 ladder's round 1
    /// landed a pin here on that span's REFUSAL and its exact sentence; her
    /// ruling of 2026-09-15 replaced the refusal with the (d) TRIM road, so
    /// the pin says what the trim does instead.
    ///
    /// **RED ON OLD:** `planCrossBlockEdit` answered nil for this span (the
    /// run's contiguity guard), and the diagnosis spoke *"One end of this
    /// selection sits on the boundary between two blocks."*
    ///
    /// *(The store-level behaviour — b1 to the tray, b2's partial edit, no
    /// join — is pinned in `BoundaryClampTests`, which drives the same span
    /// through the real keystroke path.)*
    @Test func aSpanOpeningOnTheBoundaryIsTakenByTheTrim() async throws {
        try await withEditor { h in
            h.model.applyProjection([
                slot("b0", text: "Alpha one."),   //  0..10, separator at 10
                slot("b1", text: "Beta two."),    // 11..20, separator at 20
                slot("b2", text: "Gamma three."), // 21..33
            ])
            // From the END of b0 (offset 10 — ON the separator) through
            // "Gamma " — b1 covered whole, b2 in part, b0's characters
            // untouched.
            let span = NSRange(location: 10, length: 17)
            let plan = try #require(
                h.model.planCrossBlockEdit(range: span, replacement: ""),
                "the trim takes the span her ruling said to take")
            #expect(plan.deletedBlockIDs == ["b1"],
                    "the block beside the trimmed separator is covered WHOLE")
            #expect(plan.leading == nil, "b0 contributes no characters and is not an end")
            #expect(plan.trailing?.blockID == "b2")
            #expect(plan.trailing?.newText == "three.")
            #expect(plan.joinsEnds == false,
                    "R-13u-2 answers the join: the trimmed cut sits at a paragraph break")
        }
    }

    /// A lone separator can never reach the compound — which is what makes
    /// the A7 carve and #34's seam merge safe to run before it. Walked over
    /// EVERY separator of an empty-heavy document, because 13u1 UNIT 2
    /// widened the run to include zero-length entries and "a separator
    /// intersects nothing" stopped being the whole argument.
    @Test func aLoneSeparatorCanNeverReachTheCompound() async throws {
        try await withEditor { h in
            h.model.applyProjection([
                slot("b0", text: ""),
                slot("b1", text: "alpha"),
                slot("b2", text: ""),
                slot("b3", text: ""),
                slot("b4", text: "beta"),
            ])
            for offset in 0..<h.model.index.documentLength {
                let separator = NSRange(location: offset, length: 1)
                #expect(h.model.planCrossBlockEdit(range: separator, replacement: "") == nil,
                        "a one-character range reached the compound at \(offset)")
            }
        }
    }

    // MARK: - The SEVENTH quiet auto-commit occasion

    /// **Her own insurance idea, at the gesture it was invented for**: a
    /// quiet savepoint of every take the compound will EDIT, landing before
    /// a single row changes. The reason is the doctrine's: the structural
    /// rewrite clears the text-undo stack, so the state about to be
    /// overwritten has no ⌘Z road afterwards.
    @Test func theCompoundLeavesAQuietSavepointOfEveryTakeItEdits() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let before = try h.storeSlots()
            let firstTake = try #require(before[0].variantID)
            let secondTake = try #require(before[1].variantID)

            // A fan on the first end keeps BOTH ends alive (no merge), so
            // both takes are edit targets and both must be insured.
            try await h.session.runner.run { ops in
                _ = try ops.branchVariant(before[0].blockID, from: firstTake)
            }
            try h.reload()

            h.replace(NSRange(location: 6, length: 10), with: "")
            await h.flush()

            let saved = try await h.database.read { db -> [String: [String]] in
                var byTake: [String: [String]] = [:]
                for take in [firstTake, secondTake] {
                    byTake[take] = try Queries.commitHistory(db, variantID: take)
                        .filter { $0.kind == .auto }
                        .map(\.text)
                }
                return byTake
            }
            #expect(saved[firstTake] == ["Alpha one."],
                    "the state right BEFORE the gesture, saved quietly")
            #expect(saved[secondTake] == ["Beta two."])
        }
    }

    // MARK: - Typing over a cross-block selection

    /// Typing over a selection that covers whole paragraphs behaves the way
    /// every editor behaves: ONE paragraph holding what you typed. The first
    /// block survives (the typed text belongs where the selection opened),
    /// the rest go to the tray.
    @Test func typingOverAWholeParagraphRunLeavesOneBlockHoldingWhatYouTyped() async throws {
        try await withEditor(
            seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]
        ) { h in
            let before = try h.storeSlots().map(\.blockID)
            h.replace(NSRange(location: 0, length: 33), with: "Fresh.")
            await h.flush()

            let slots = try h.storeSlots()
            #expect(slots.compactMap(\.text) == ["Fresh."])
            #expect(slots.map(\.blockID) == [before[0]],
                    "the FIRST block keeps its identity and holds the typed text")
        }
    }

    /// **HER LEGIBILITY MANDATE, pinned at the words**: *"receipts name where
    /// every block went."* Both destinations, by the nouns the rest of the
    /// app uses for them, and short enough to survive the quiet line's
    /// one-line truncation — the walk measured the first build falling off
    /// the bar at exactly the join clause.
    @Test func theReceiptNamesBothDestinationsAndStaysShortEnoughToRead() async throws {
        try await withEditor(
            seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]
        ) { h in
            h.replace(NSRange(location: 6, length: 21), with: "")
            await h.flush()
            let status = try #require(h.model.statusMessage)
            #expect(status.contains(TrayPath.menuLabel), "where the middle went")
            #expect(status.contains(BlockHistoryPath.cameFromSection),
                    "where the two ends went")
            #expect(status.contains("\u{2325}\u{2318}Z"), "and the road back")
            #expect(status.count <= 100,
                    "short enough for the quiet line: \(status.count) — \(status)")
        }
    }
}

// MARK: - The MENU flight the doors did not wait for (KnownIssues, 13u1 UNIT 2)

/// **The neighbour UNIT 1 traced and deliberately left** (the 18c ladder's
/// R3-1 named it as NOT its finding; UNIT 1 fixed the keystroke CHAIN and
/// re-traced this one rather than folding it in, because widening the guard
/// changes what the quit door WAITS FOR — door semantics, not a loop — and
/// the flight and the compound are one subject at this unit).
///
/// `EditorViewModel.finalizeWork`'s guard read the dirty flags and
/// `pendingCrossBlockTask`, **never `structuralInFlight`** — so a divide,
/// merge or ceremony launched from a MENU (which arms no compound handle,
/// because there was no refused keystroke to arm one) was a flight every
/// door replied "done" over, with its operation still in the writer queue.
@Suite("The menu flight's door await (13u1 UNIT 2)")
struct MenuFlightDoorAwaitTests {

    /// **RED ON OLD at the door's own call:** `finalizeWork()` returned nil
    /// while a menu-born flight was up, so quit, lock, seal and teardown all
    /// believed there was nothing to wait for.
    @Test func theQuitDoorAwaitsAMenuBornStructuralFlight() async throws {
        try await withEditor(seedBlocks: ["Alpha", "Beta"]) { h in
            h.textView.setSelectedRange(NSRange(location: 0, length: 0))
            h.model.updateCaretContext()

            // A MENU gesture: ⌘⇧⏎'s door, straight into `runStructural`.
            // Nothing is dirty, no mint is in flight, no tail is open, and
            // no compound handle is armed — the exact three-false-flags
            // state the old guard read.
            let flight = Task { @MainActor in await h.model.insertBlockBelowCaret() }
            await Task.yield()
            #expect(h.model.structuralInFlight, "the flight is up")
            #expect(!h.model.autosave.isDirty)
            #expect(h.model.pendingCrossBlockTask == nil, "a menu gesture arms no handle")

            let door = try #require(h.model.finalizeWork(),
                                    "RED ON OLD: the door replied nil over a live flight")
            await door.value
            #expect(!h.model.structuralInFlight, "the door waited the flight out")

            await flight.value
            #expect(try h.storeSlots().count == 3, "and the block really landed")
        }
    }
}

// MARK: - Row 43's two halves, together (13u1 UNIT 2)

/// **THE ⌘Z-ACROSS-A-BREAK JUDGMENT, and what it actually costs after this
/// unit.** `KnownIssuesAndTechDebt.md`'s row has two halves and they turn out
/// to be one story:
///
/// (1) every structural rewrite CLEARS the text-undo stack — the standing
/// directive at `applyDifferentialStructural`, `applyDifferential` and
/// `renderFull` — so with the chip ON, ⌘Z after a paragraph break stops at
/// the break. **The directive stands** (the judgment is made and reasoned in
/// this unit's record: AppKit offers no way to drop a SUFFIX of NSTextView's
/// own registrations, and re-registering across a rewritten storage is not a
/// thing `NSUndoManager` can do).
///
/// (2) `newBlock` registered no structural undo entry — which is what made
/// half (1) bite hardest, and this is the pin for it: **before R-13u-3, the
/// text stack was cleared AND the structural stack had nothing from the ⏎,
/// so ⌘Z did nothing and said nothing.** The sign at the junction (13j J7)
/// needs a structural label to speak, and there was none.
@MainActor
@Suite("⌘Z across a paragraph break, after R-13u-3", .serialized)
struct ReturnKeyUndoSignTests {

    @Test func afterAReturnMintTheSignSpeaksAndTheStructuralUndoRemovesTheBlock() async throws {
        try await withEditor(seedBlocks: ["Alpha"]) { h in
            let hosted = ReturnKeyTraceTests.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            // Type, so the TEXT stack has something in it.
            h.type(" more", at: 5)
            await h.flush()
            #expect(h.textView.undoManager?.canUndo == true)

            // ⏎ at the block's end: U-1's act mints an empty block below.
            h.textView.setSelectedRange(
                NSRange(location: h.model.index.documentLength, length: 0))
            h.model.updateCaretContext()
            h.textView.keyDown(with: ReturnKeyTraceTests.returnEvent(
                shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()
            #expect(try h.storeSlots().count == 2, "the block was minted")

            // HALF (1), unchanged and deliberate: the text stack is gone.
            #expect(h.textView.undoManager?.canUndo == false,
                    "the structural rewrite cleared text-undo — the standing directive")

            // HALF (2), R-13u-3: the structural stack now holds the mint, so
            // the junction sign can speak. **RED ON OLD: `newBlock`
            // registered nothing, so this label was nil and
            // `EditorUndoHint.message` returned nil — ⌘Z did nothing and
            // said nothing.**
            #expect(h.session.undoMenuState.topLabel == "New Block")
            h.model.showStatus("")
            h.model.speakUndoHint(.undo)
            #expect(h.model.statusMessage == EditorUndoHint.message(
                for: .undo, textStackHasEntries: false,
                structuralUndoLabel: "New Block", structuralRedoLabel: nil),
                "the sign names ⌥⌘Z: \(h.model.statusMessage ?? "nil")")

            // …and the road it names really works.
            let stack = h.session.undoStack
            try await h.session.runner.run { ops in _ = try stack.undo(with: ops) }
            try h.reload()
            #expect(try h.storeSlots().compactMap(\.text) == ["Alpha more"],
                    "⌥⌘Z removed the block ⏎ just made — her ask, verbatim")
        }
    }

}
