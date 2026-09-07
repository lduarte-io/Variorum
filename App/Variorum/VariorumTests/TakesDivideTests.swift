//
//  TakesDivideTests.swift
//  VariorumTests
//
//  Phase 13d, batch 3 — her A9, verbatim: *"i desperately need divide in
//  takes mode"*, ruled at the 13c ratify walk (QUESTIONS #41) to land in
//  13d. Divide now acts WITHOUT leaving the board: an unfanned block takes
//  a plain divide at the pane caret; a fanned block opens the take
//  ceremony right there, seeded from the take the caret is actually in.
//
//  The two pins this suite exists for, above all the coverage:
//
//  1. `theTakesWorldAndWritesWorldPlanAlike` — the ONE-BRAIN claim,
//     enforced by test rather than asserted in a comment (the architect's
//     binding addition at the proposal gate). Identical block text, caret
//     and fan arity must produce the same verdict CLASS and the same
//     SNAPPED CUT through both doors' worlds.
//  2. `theForkIsReadFromTheStoreNotTheFrozenProjection` — batch 2's
//     precedent applied one door over. The takes projection is
//     deliberately frozen while any buffer is dirty, so a fan that arrives
//     mid-burst is invisible to it; reading the fork from `projection.fans`
//     would divide a block that has takes. Batch 2's revert D is the
//     receipt for what that costs.
//
//  Scope is DIVIDE ONLY (the batch's brief): extract, make-block and merge
//  keep the carry choreography, pinned here so a future session cannot
//  widen the door by accident. *(13j J4b widened that one line: MERGE from
//  the ⌘-click selection acts here too now — its pins live in
//  `FanHandsTests`. The three carried acts named above are unchanged.)*
//
//  **13j batch 4 (J4) — A JUSTIFIED EDIT to the ceremony openings below.**
//  Her 2026-08-03 ruling flipped ⌘⇧D on a fanned block to the DUPLICATING
//  divide; the sheet is ⌥⌘⇧D's now (`divideFocused(ceremony: true)`). Every
//  ceremony rule this suite pinned is pinned unchanged, through the door
//  that opens it; the default road's own board pins live in
//  `FannedDefaultsBoardTests`, and one pin here —
//  `theForkIsReadFromTheStoreNotTheFrozenProjection` — got STRONGER by the
//  flip (see its note).
//

import AppKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Divide, natively in Takes (13d batch 3, A9)")
struct TakesDivideTests {
    /// A board over a fresh store, with the projection adopted by hand
    /// (the observation never fires under the test host).
    @MainActor
    private struct Board {
        let session: AppSession
        let database: AppDatabase
        let model: TakesViewModel
        let postID: String

        func reload() throws {
            model.adopt(try database.read { try Queries.takesProjection($0, post: postID) })
        }

        func slots() throws -> [Queries.RenderedBlock] {
            try database.read { try Queries.renderPost($0, containerID: postID) }
        }

        func focus(blockID: String, variantID: String, caret: Int) {
            let key = TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: blockID, variantID: variantID)
            model.focus(key)
            model.notePaneSelection(
                variantID: variantID, range: NSRange(location: caret, length: 0))
        }

        func paneKey(blockID: String, variantID: String) -> TakesViewModel.PaneKey {
            TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: blockID, variantID: variantID)
        }
    }

    private func withBoard<T>(
        seedBlocks: [String] = ["The first sentence here. The second sentence here."],
        _ body: @MainActor (Board) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "A9")
            for text in seedBlocks {
                _ = try session.operations.newBlock(in: post.id, text: text)
            }
            let model = TakesViewModel(session: session, postID: post.id)
            let board = Board(
                session: session, database: db, model: model, postID: post.id)
            try board.reload()
            return try await body(board)
        }
    }

    // MARK: - THE ONE-BRAIN PIN (binding, the gate's addition)

    @Test func theTakesWorldAndWritesWorldPlanAlike() async throws {
        // The claim constraint 1 makes is that Takes consults the SAME
        // planner as Write, not a sibling. A comment cannot prove that; a
        // verdict comparison can. Identical text, identical caret,
        // identical arity — through Write's real world and through the
        // board's synthetic one.
        let text = "The first sentence here. The second sentence here."
        try await withEditor(seedBlocks: [text]) { editor in
            let slot = try #require(try editor.storeSlots().first)
            let variantID = try #require(slot.variantID)
            let take = try #require(
                try editor.database.read { db in
                    try Queries.blockFan(db, blockID: slot.blockID)
                }.first)

            let model = TakesViewModel(session: editor.session, postID: editor.postID)
            model.adopt(try editor.database.read {
                try Queries.takesProjection($0, post: editor.postID)
            })

            // Every caret in the block, both arities — the whole domain,
            // not a sampled one.
            for arity in [1, 2] {
                for caret in 0...text.utf16.count {
                    let writeWorld = StructuralGesturePlanner.World(
                        index: BlockRangeIndex(
                            entries: [BlockRangeIndex.Entry(
                                blockID: slot.blockID, variantID: variantID,
                                length: text.utf16.count, editable: true)],
                            tailLength: nil),
                        fanArities: [arity],
                        sealed: false,
                        textAt: { _ in text })
                    let takesWorld = model.divideWorld(
                        slot: slot, take: take, arity: arity)

                    let selection = NSRange(location: caret, length: 0)
                    let fromWrite = StructuralGesturePlanner.plan(
                        .divideAtCursor, selection: selection, world: writeWorld)
                    let fromTakes = StructuralGesturePlanner.plan(
                        .divideAtCursor, selection: selection, world: takesWorld)
                    #expect(fromWrite == fromTakes,
                            "caret \(caret), arity \(arity): the two doors disagree")
                }
            }

            // Non-vacuity: the domain really does contain all three verdict
            // classes, so an "always equal" pass means something.
            @MainActor func verdicts(_ arity: Int) -> Set<String> {
                var seen: Set<String> = []
                let world = model.divideWorld(slot: slot, take: take, arity: arity)
                for caret in 0...text.utf16.count {
                    switch StructuralGesturePlanner.plan(
                        .divideAtCursor,
                        selection: NSRange(location: caret, length: 0), world: world) {
                    case .divide: seen.insert("divide")
                    case .divideW: seen.insert("divideW")
                    case .refusal: seen.insert("refusal")
                    default: seen.insert("other")
                    }
                }
                return seen
            }
            // Snap-and-proceed is the ratified contract (2026-07-06 item
            // 2), so on a multi-word block EVERY caret — 0 and the end
            // included — snaps to an interior word edge and divides; the
            // refusal class belongs to blocks with no interior boundary
            // (pinned separately below). Both doors agree on that too,
            // which is the point of comparing them across the whole range.
            #expect(verdicts(1) == ["divide"])
            #expect(verdicts(2) == ["divideW"])
        }
    }

    @Test func theSnappedCutIsTheOneWordRuleBothDoorsShare() async throws {
        // The gate asked for the cut OFFSET too, not only the class: a
        // caret mid-word must land on the same word edge either way
        // (S4-22's word-edge floor, `BoundarySnapping.settle`).
        let text = "The first sentence here. The second sentence here."
        try await withBoard(seedBlocks: [text]) { board in
            let slot = try #require(try board.slots().first)
            let take = try #require(
                try board.database.read { db in
                    try Queries.blockFan(db, blockID: slot.blockID)
                }.first)
            let world = board.model.divideWorld(slot: slot, take: take, arity: 1)
            // Caret 7 sits inside "first"; both doors snap to the same edge.
            guard case .divide(_, _, let cut) = StructuralGesturePlanner.plan(
                .divideAtCursor, selection: NSRange(location: 7, length: 0), world: world)
            else { return #expect(Bool(false), "expected a plain divide") }
            #expect(cut == StructuralGesturePlanner.snapToInteriorBoundary(7, in: text),
                    "the snap is the planner's own, not a second rule")
        }
    }

    // MARK: - The unfanned case, end to end, without leaving the board

    @Test func divideCutsTheBlockRightHereAndNeverSwitchesModes() async throws {
        try await withBoard { board in
            let slot = try #require(try board.slots().first)
            let variantID = try #require(slot.variantID)
            board.focus(blockID: slot.blockID, variantID: variantID, caret: 25)

            await board.model.divideFocused()
            try board.reload()

            let texts = try board.slots().compactMap(\.text)
            #expect(texts == ["The first sentence here.", "The second sentence here."],
                    "two blocks, cut at the sentence the caret sat on")
            // A9's whole point: NOTHING was carried to Write.
            #expect(board.session.commandRouter.pendingWriteIntent == nil)
            #expect(board.model.divideWCeremony == nil, "no ceremony on an unfanned block")
            #expect(board.model.statusMessage?.isEmpty == false, "and it speaks")

            // The ordinary structural undo/redo, riding the ops
            // registration — nothing new was registered.
            let stack = board.session.undoStack
            #expect(stack.depth == 1)
            try await board.session.runner.run { ops in _ = try stack.undo(with: ops) }
            try board.reload()
            let undone = try board.slots().compactMap(\.text)
            #expect(undone == ["The first sentence here. The second sentence here."])
            try await board.session.runner.run { ops in _ = try stack.redo(with: ops) }
            try board.reload()
            let redone = try board.slots().count
            #expect(redone == 2)
        }
    }

    @Test func theRingLandsOnTheSuccessorTheWayWritesCaretDoes() async throws {
        try await withBoard { board in
            let slot = try #require(try board.slots().first)
            let variantID = try #require(slot.variantID)
            board.focus(blockID: slot.blockID, variantID: variantID, caret: 25)

            await board.model.divideFocused()
            try board.reload()

            let successor = try #require(try board.slots().last)
            #expect(board.model.focusedPane?.blockID == successor.blockID,
                    "Write puts the caret at the successor's start; the ring mirrors it")
        }
    }

    // MARK: - The fanned case: the ceremony opens IN PLACE

    @Test func aFannedBlockOpensTheCeremonyOnTheBoard() async throws {
        try await withBoard { board in
            let slot = try #require(try board.slots().first)
            let chosen = try #require(slot.variantID)
            _ = try board.session.operations.branchVariant(slot.blockID, from: chosen)
            try board.reload()

            board.focus(blockID: slot.blockID, variantID: chosen, caret: 25)
            await board.model.divideFocused(ceremony: true)

            let ceremony = try #require(board.model.divideWCeremony)
            #expect(ceremony.blockID == slot.blockID)
            #expect(ceremony.takes.count == 2)
            #expect(board.session.commandRouter.pendingWriteIntent == nil,
                    "the ceremony opened HERE — no mode switch")
            // Nothing was cut by opening.
            let untouched = try board.slots().count
            #expect(untouched == 1)
        }
    }

    @Test func theCeremonySeedsFromTheTakeTheCaretIsIn_notTheChosenOne() async throws {
        // THE generalization this batch made: Write derived the seed from
        // its own index, which shows the CHOSEN take. A board's caret may
        // sit in a pane that is not chosen, and the propagation must run
        // from THAT take's text.
        try await withBoard(seedBlocks: ["Alpha beta gamma."]) { board in
            let slot = try #require(try board.slots().first)
            let chosen = try #require(slot.variantID)
            let other = try board.session.operations.branchVariant(
                slot.blockID, from: chosen)
            let otherText = "Wholly different words entirely here."
            try board.session.operations.autosave(
                other.id, text: otherText, charDelta: otherText.count)
            try board.reload()

            // The caret sits in the NON-chosen take.
            board.focus(blockID: slot.blockID, variantID: other.id, caret: 7)
            await board.model.divideFocused(ceremony: true)

            let ceremony = try #require(board.model.divideWCeremony)
            #expect(ceremony.activeVariantID == other.id,
                    "the seed is the take she was looking at, not the chosen one")
            let seeded = try #require(ceremony.takes.first { $0.id == other.id })
            #expect(seeded.marked, "the seed take is pre-marked")
            #expect(seeded.cut == StructuralGesturePlanner.snapToInteriorBoundary(
                7, in: otherText),
                    "and its cut is the caret's, snapped by the one word rule")
        }
    }

    @Test func confirmingTheCeremonyDividesTheTakesFromTheBoard() async throws {
        try await withBoard(seedBlocks: ["Alpha beta. Gamma delta."]) { board in
            let slot = try #require(try board.slots().first)
            let chosen = try #require(slot.variantID)
            _ = try board.session.operations.branchVariant(slot.blockID, from: chosen)
            try board.reload()

            board.focus(blockID: slot.blockID, variantID: chosen, caret: 11)
            await board.model.divideFocused(ceremony: true)
            let ceremony = try #require(board.model.divideWCeremony)

            // Mark and place the second take too, then confirm.
            let second = try #require(ceremony.takes.first { $0.id != chosen })
            board.model.ceremony.toggleTake(second.id)
            board.model.ceremony.placeCut(takeID: second.id, cut: 11)
            #expect(board.model.divideWCeremony?.canConfirm == true)

            await board.model.ceremony.confirm()
            try board.reload()

            #expect(board.model.divideWCeremony == nil, "the sheet dismisses on landing")
            let slots = try board.slots()
            #expect(slots.count == 2, "the W's two successors stand where A stood")
            #expect(board.session.undoStack.depth == 1)
        }
    }

    /// **A JUSTIFIED EDIT (18f batch 1, U-5), claim intact.** I10-at-birth is
    /// still the subject; what changed is that the sheet now opens on an
    /// ARRANGEMENT, so the same refusal is spoken twice — once in the
    /// preset's words (the bottom block would be takeless) and once in the
    /// hand-placed sheet's (the second block). Both arms are pinned, because
    /// both are roads she can take.
    @Test func theCeremonyRefusesToConfirmWhileEveryCheckedTakeParksTheSameWay() async throws {
        // I10-at-birth, at the new mount: the sheet's own gate, unchanged
        // by the move (the op's `divideSideWouldBeEmpty` is the belt).
        try await withBoard(seedBlocks: ["Alpha beta. Gamma delta."]) { board in
            let slot = try #require(try board.slots().first)
            let chosen = try #require(slot.variantID)
            _ = try board.session.operations.branchVariant(slot.blockID, from: chosen)
            try board.reload()

            board.focus(blockID: slot.blockID, variantID: chosen, caret: 11)
            await board.model.divideFocused(ceremony: true)
            let ceremony = try #require(board.model.divideWCeremony)
            let length = ceremony.takes.first { $0.id == chosen }
                .map { $0.variant.workingText.utf16.count } ?? 0
            board.model.ceremony.placeCut(takeID: chosen, cut: length)  // park at the end

            #expect(board.model.divideWCeremony?.canConfirm == false)
            #expect(board.model.divideWCeremony?.confirmBlocker?
                .contains("bottom block would be born without a take") == true,
                "the keep-on-top preset's own words for the same I10 refusal")

            board.model.ceremony.setArrangement(.perTake)
            #expect(board.model.divideWCeremony?.canConfirm == false)
            #expect(board.model.divideWCeremony?.confirmBlocker?
                .contains("second block would be born without a take") == true,
                "and the hand-placed sheet's, unchanged")
        }
    }

    @Test func cancellingTheCeremonyTouchesNothing() async throws {
        try await withBoard { board in
            let slot = try #require(try board.slots().first)
            let chosen = try #require(slot.variantID)
            _ = try board.session.operations.branchVariant(slot.blockID, from: chosen)
            try board.reload()

            board.focus(blockID: slot.blockID, variantID: chosen, caret: 25)
            await board.model.divideFocused(ceremony: true)
            #expect(board.model.divideWCeremony != nil)

            board.model.ceremony.cancel()
            #expect(board.model.divideWCeremony == nil)
            let unchanged = try board.slots().count
            #expect(unchanged == 1)
            #expect(board.session.undoStack.depth == 0)
        }
    }

    // MARK: - THE STORE-READ FORK (the ruled reading; batch 2's precedent)

    @Test func theForkIsReadFromTheStoreNotTheFrozenProjection() async throws {
        try await withBoard { board in
            let slot = try #require(try board.slots().first)
            let chosen = try #require(slot.variantID)
            board.focus(blockID: slot.blockID, variantID: chosen, caret: 25)

            // A take arrives — from her phone, from sync, from a sibling
            // surface — while the board's projection is NOT re-adopted.
            // This is exactly what the dirty-buffer freeze produces.
            _ = try board.session.operations.branchVariant(slot.blockID, from: chosen)
            #expect(board.model.projection.fans[slot.blockID]?.count == 1,
                    "the projection still shows ONE take — the staleness is real")

            await board.model.divideFocused()

            // 13j J4 — A JUSTIFIED EDIT that STRENGTHENS this pin, re-aimed
            // at 18c batch 1's keep-on-top shape (U-2). Its claim is
            // unchanged and is the one that matters: the fork is read from
            // the STORE, never from the frozen projection. Before the flip
            // the evidence was "a sheet opened"; now the fanned road ACTS, so
            // the evidence is the act itself — A RELEASED and the arrived
            // take riding whole onto the top block, rather than the plain
            // divide the stale fan would have produced (which would have kept
            // this block's identity and left it holding one take).
            #expect(board.model.divideWCeremony == nil, "the default road acts, it does not ask")
            let after = try board.slots()
            #expect(after.count == 2)
            #expect(after.allSatisfy { $0.blockID != slot.blockID },
                    "A was released whole — the fanned road, not the plain one")
            #expect(after.map(\.activeVariantCount) == [2, 1],
                    "the take the projection could not see rode onto the TOP block")
        }
    }

    // MARK: - Refusals, all the operation's own

    @Test func aSealedPostRefusesAndSpeaks() async throws {
        try await withBoard { board in
            let slot = try #require(try board.slots().first)
            let variantID = try #require(slot.variantID)
            try board.session.operations.lockPost(board.postID)
            try board.reload()
            board.focus(blockID: slot.blockID, variantID: variantID, caret: 25)

            await board.model.divideFocused()

            #expect(board.model.statusMessage == RefusalCopy.message(for: .sealed))
            let sealedSlots = try board.slots().count
            #expect(sealedSlots == 1)
            #expect(board.model.divideWCeremony == nil)
        }
    }

    @Test func aLockedTakeRefusesThePlainDivideAndTheCeremonyDoesNot() async throws {
        // Phase 3 op semantics, encoded in the planner and inherited whole:
        // a plain divide edits the buffer (a lock refuses); the ceremony
        // COPIES takes (a lock is fine there).
        try await withBoard { board in
            let slot = try #require(try board.slots().first)
            let variantID = try #require(slot.variantID)
            try board.session.operations.lockVariant(variantID)
            try board.reload()
            board.focus(blockID: slot.blockID, variantID: variantID, caret: 25)

            await board.model.divideFocused()
            #expect(board.model.statusMessage == RefusalCopy.message(for: .lockedVariant))
            let lockedSlots = try board.slots().count
            #expect(lockedSlots == 1)

            // Fan it: the same locked take now opens the ceremony.
            _ = try board.session.operations.branchVariant(slot.blockID, from: variantID)
            try board.reload()
            board.focus(blockID: slot.blockID, variantID: variantID, caret: 25)
            await board.model.divideFocused(ceremony: true)
            #expect(board.model.divideWCeremony != nil)
        }
    }

    @Test func withNoCaretPlacedItActsAtTheBlockStartExactlyAsWritesCarryDoorDoes() async throws {
        // Written the other way round first, asserting a refusal — and the
        // pin was wrong, not the code. With no reported selection the
        // offset is 0, and SNAP-AND-PROCEED (the ratified contract, item 2)
        // settles 0 onto the nearest INTERIOR word edge: it divides near
        // the start. That is exactly what the carry door produces, because
        // `moveToWriteAndRun` sets `offsetInBlock = carried?.location ?? 0`
        // and Write then plans the same command at the same offset — so
        // this IS the parity, and inventing a refusal here would have been
        // inventing product behaviour.
        let text = "The first sentence here. The second sentence here."
        try await withBoard(seedBlocks: [text]) { board in
            let slot = try #require(try board.slots().first)
            let variantID = try #require(slot.variantID)
            board.model.focus(board.paneKey(blockID: slot.blockID, variantID: variantID))

            await board.model.divideFocused()
            try board.reload()

            let cut = try #require(
                StructuralGesturePlanner.snapToInteriorBoundary(0, in: text))
            // Compared through the op's OWN halving function: divide seam-
            // trims (the Phase 3 ratification), so the first half is not
            // simply text[..<cut] — reading the raw offset here cost this
            // pin one honest red.
            let halves = try #require(
                BoundarySnapping.seamTrimmedHalves(text, cutAtUTF16: cut))
            let texts = try board.slots().compactMap(\.text)
            #expect(texts == [halves.first, halves.second],
                    "the cut is where the one snap brain puts a caret of 0")
        }
    }

    @Test func aBlockWithNoInteriorBoundaryIsWhatActuallyRefuses() async throws {
        // The `.nothingToDo` class, reached honestly: one word has no
        // interior word edge, so there is nowhere legal to cut.
        try await withBoard(seedBlocks: ["Alpha"]) { board in
            let slot = try #require(try board.slots().first)
            let variantID = try #require(slot.variantID)
            board.focus(blockID: slot.blockID, variantID: variantID, caret: 2)

            await board.model.divideFocused()

            #expect(board.model.statusMessage == RefusalCopy.message(for: .nothingToDo))
            let intact = try board.slots().count
            #expect(intact == 1)
        }
    }

    @Test func aStaleSelectionFromAPaneSheLeftIsNotBorrowed() async throws {
        // The choreographer's own carried-caret rule, reused: a selection
        // counts only when it belongs to the FOCUSED pane's take. The
        // discriminating claim is where the cut lands — not that it
        // refuses (snap-and-proceed means offset 0 still divides).
        let second = "Delta epsilon zeta."
        try await withBoard(seedBlocks: ["Alpha beta gamma.", second]) { board in
            let slots = try board.slots()
            let firstTake = try #require(slots.first?.variantID)
            let secondSlot = try #require(slots.last)
            let secondTake = try #require(secondSlot.variantID)

            // A caret reported for the FIRST block's take…
            board.model.notePaneSelection(
                variantID: firstTake, range: NSRange(location: 12, length: 0))
            // …while the ring sits in the SECOND block.
            board.model.focus(
                board.paneKey(blockID: secondSlot.blockID, variantID: secondTake))

            await board.model.divideFocused()
            try board.reload()

            let texts = try board.slots().compactMap(\.text)
            #expect(texts.count == 3, "the SECOND block divided")
            let atStart = try #require(
                StructuralGesturePlanner.snapToInteriorBoundary(0, in: second))
            let halves = try #require(
                BoundarySnapping.seamTrimmedHalves(second, cutAtUTF16: atStart))
            #expect([texts[1], texts[2]] == [halves.first, halves.second],
                    "cut at the block start — NOT at the stale caret's offset 12")
            #expect(atStart != 12, "the two readings are genuinely distinguishable")
        }
    }

    /// 13d cold review F-3 (red-on-old): when the take the caret was in
    /// has VANISHED from the live fan (archived by sync or a sibling
    /// surface, behind the frozen projection), the door refuses and
    /// speaks — Write's posture exactly (`DivideWCeremony.open`'s
    /// takes-changed line) — rather than silently dividing a take she was
    /// never in at a caret offset from the one that died. The pre-fix
    /// fallback (`?? liveActive.first`) did exactly that.
    @Test func aVanishedSeedTakeRefusesInsteadOfDividingAnotherTake() async throws {
        try await withBoard(seedBlocks: ["Alpha beta gamma delta."]) { board in
            let slot = try #require(try board.slots().first)
            let chosen = try #require(slot.variantID)
            board.focus(blockID: slot.blockID, variantID: chosen, caret: 11)

            // A second take exists, and the CARET's take is then archived —
            // both behind the frozen projection (no reload; the staleness
            // is the point).
            _ = try board.session.operations.branchVariant(slot.blockID, from: chosen)
            try board.session.operations.archiveVariant(chosen)

            await board.model.divideFocused()

            #expect(board.model.statusMessage?.contains("takes changed") == true,
                    "the vanished seed refuses and speaks — Write's posture")
            #expect(board.model.divideWCeremony == nil, "no ceremony over a guessed seed")
            try board.reload()
            let texts = try board.slots().compactMap(\.text)
            #expect(texts == ["Alpha beta gamma delta."],
                    "nothing was cut — the surviving take is untouched")
        }
    }

    @Test func withNoBlockInReachItSaysWhereToClick() async throws {
        try await withBoard(seedBlocks: ["Alpha beta gamma.", "Delta epsilon zeta."]) { board in
            #expect(board.model.commandTargetSlot == nil, "two blocks, nothing focused")
            await board.model.divideFocused()
            #expect(board.model.statusMessage?.contains("Click into a block first") == true)
            let untargetedSlots = try board.slots().count
            #expect(untargetedSlots == 2)
        }
    }

    // MARK: - The flight latch: both of its jobs

    @Test func aSecondDivideRefusesWhileOneIsStillLanding() async throws {
        try await withBoard { board in
            let slot = try #require(try board.slots().first)
            let variantID = try #require(slot.variantID)
            board.focus(blockID: slot.blockID, variantID: variantID, caret: 25)

            board.model.structuralInFlight = true
            await board.model.divideFocused()

            #expect(board.model.statusMessage == "Another structural change is still landing.")
            let busySlots = try board.slots().count
            #expect(busySlots == 1, "nothing landed behind the busy door")
        }
    }

    @Test func thePanesFreezeForTheFlight() async throws {
        // The correctness half, and the reason the latch exists at all: a
        // keystroke between the flush and the op would autosave the block's
        // PRE-divide text back over the half the op just truncated. A
        // frozen pane is not editable (`PaneSurface`: isEditable = isLive).
        try await withBoard { board in
            let slot = try #require(try board.slots().first)
            let variantID = try #require(slot.variantID)
            let key = board.paneKey(blockID: slot.blockID, variantID: variantID)
            board.model.focus(key)
            #expect(board.model.isPaneLive(key), "live at rest")

            board.model.structuralInFlight = true
            #expect(!board.model.isPaneLive(key), "frozen for the flight")

            board.model.structuralInFlight = false
            #expect(board.model.isPaneLive(key), "and live again after it")
        }
    }

    @Test func aSealedPostStillHasNoLivePane() async throws {
        // The pre-existing suppression reason, unchanged by the fold — the
        // disjunction must not have replaced it.
        try await withBoard { board in
            let slot = try #require(try board.slots().first)
            let variantID = try #require(slot.variantID)
            let key = board.paneKey(blockID: slot.blockID, variantID: variantID)
            board.model.focus(key)
            try board.session.operations.lockPost(board.postID)
            try board.reload()
            #expect(!board.model.isPaneLive(key))
        }
    }

    // MARK: - Scope: DIVIDE only

    @Test func extractMakeBlockAndMergeStillCarryToWrite() async throws {
        try await withBoard { board in
            let slot = try #require(try board.slots().first)
            let variantID = try #require(slot.variantID)
            // A mounted detail must exist, or `requestMode` refuses and
            // CLEARS the parking (the round-1 MAJOR's half-a rule) — the
            // pin would then read "no carry" for the wrong reason.
            _ = board.session.commandRouter.registerDetail(
                postID: board.postID, mode: .takes) { _ in }
            for act in [StructuralAct.extract, .makeBlock, .merge] {
                board.session.commandRouter.pendingWriteIntent = nil
                board.focus(blockID: slot.blockID, variantID: variantID, caret: 25)
                board.model.runStructuralDoor(act)
                // The choreography parks its intent asynchronously.
                for _ in 0..<200 where board.session.commandRouter.pendingWriteIntent == nil {
                    await Task.yield()
                    try? await Task.sleep(for: .milliseconds(1))
                }
                let intent = try #require(
                    board.session.commandRouter.pendingWriteIntent,
                    "\(act) still carries — this batch moved DIVIDE only")
                #expect(intent.followUp == .structural(act))
            }
        }
    }

    @Test func theDivideDoorNeverParksAWriteIntent() async throws {
        try await withBoard { board in
            let slot = try #require(try board.slots().first)
            let variantID = try #require(slot.variantID)
            board.focus(blockID: slot.blockID, variantID: variantID, caret: 25)

            board.model.runStructuralDoor(.divide)
            for _ in 0..<200 {
                if try board.slots().count > 1 { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }

            #expect(board.session.commandRouter.pendingWriteIntent == nil,
                    "divide acts here now — the carry door is retired for it")
            let divided = try board.slots().count
            #expect(divided == 2)
        }
    }

    // MARK: - The registry declaration (P-1)

    @Test func divideIsDeclaredNATIVEInBothBoards() {
        let capability = CapabilityRegistry.capability(.divide)
        #expect(capability.takesAccess == .native)
        #expect(capability.availability(CapabilityContext(mode: .takes)) == .act)
        #expect(capability.availability(CapabilityContext(mode: .lenses)) == .act,
                "the shared-model precedent: a native door lands in BOTH boards")
        #expect(capability.availability(
            CapabilityContext(mode: nil, takesBoardAttached: true)) == .act,
            "a board mounted outside a post detail acts too (13c 2B's lesson)")
    }

    @Test func theOtherThreeStructuralVerbsStillDeclareTheCarry() {
        for id in [CapabilityID.extract, .makeBlock, .merge] {
            #expect(CapabilityRegistry.capability(id).takesAccess == .moveAndExecute,
                    "\(id) is untouched — scope was divide only")
            #expect(CapabilityRegistry.capability(id)
                .availability(CapabilityContext(mode: .takes)) == .actElsewhere(.write))
        }
    }
}
