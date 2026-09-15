//
//  RoundAFixTests.swift
//  VariorumTests
//
//  Phase 13e, LADDER ROUND A — the fix session's pins (A-1, A-3, A-4).
//
//  A-1 [MINOR] The Takes board's `deleteSelectedBlocks` HALF-ACTED in the
//      vanished-pick race: it filtered the picks against the store's order
//      and deleted whatever survived, while Write's host handed every pick
//      to the compound and let the operation refuse — one declared act with
//      two behaviours, and the board's own doc comment described Write's.
//  A-3 [NIT] `mergeSelectedBlocks` asked CONTIGUITY first, so the same race
//      came back as "these aren't next to each other" when the truth was
//      that a picked block is gone.
//  A-4 [NIT] The take card's context rows typed their chord suffixes by
//      hand beside a registry that declares them (AR-1(e) leaves those keys
//      hers to re-pick). Cleanliness, not a bug — the guard here is the
//      agreement, and the words are pinned UNCHANGED as the no-change proof.
//
//  A-5 (the `@MainActor` annotation on `TakeClipboard`) carries no pin
//  deliberately: the reviewer labelled it SPECULATIVE, no mechanism was
//  traceable, and a pin would have passed on both sides — the hallucination
//  guard's own instruction.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

// MARK: - A board, its store, and the picks

@MainActor
private func withBoard<T>(
    seedBlocks: [String],
    _ body: @MainActor (RoundABoard) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 23))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let post = try session.operations.createPost(title: "13e round A")
        for text in seedBlocks {
            // A fixture mint is not a gesture (13u1 UNIT 2 — the
            // `withEditor` harness's own rule, stated there).
            _ = try session.operations.newBlock(
                in: post.id, text: text, registeringUndo: false)
        }
        let board = RoundABoard(
            session: session, database: db,
            model: TakesViewModel(session: session, postID: post.id),
            postID: post.id)
        try board.reload()
        return try await body(board)
    }
}

@MainActor
private struct RoundABoard {
    let session: AppSession
    let database: AppDatabase
    let model: TakesViewModel
    let postID: String

    func reload() throws {
        model.adopt(try database.read { try Queries.takesProjection($0, post: postID) })
    }

    func blockIDs() throws -> [String] {
        try database.read { try Queries.renderPost($0, containerID: postID) }.map(\.blockID)
    }

    func texts() throws -> [String] {
        try database.read { try Queries.renderPost($0, containerID: postID) }
            .compactMap(\.text)
    }
}

// MARK: - A-1: the board rolls back exactly as Write does

@MainActor
@Suite("The board's multi-delete rolls the whole gesture back (round A, A-1)")
struct BoardDeleteRollbackTests {
    /// **The red-on-old pin.** The reachable race, staged exactly as batch
    /// 4's Write pin stages it: a picked block leaves the note AFTER she
    /// picked it (another pane, the other half of a split, a sync arrival),
    /// and the projection is deliberately NOT reloaded — that window is
    /// precisely where the surface still offers the ghost.
    ///
    /// Pre-fix the board filtered the ghost out and deleted the survivor, so
    /// "one" really died and nothing was said. The compound's atomic
    /// rollback is what the act promises instead.
    @Test func aVanishedPickRollsTheWholeGestureBackAndSaysSo() async throws {
        try await withBoard(seedBlocks: ["one", "two", "three"]) { board in
            let ids = try board.blockIDs()
            board.model.toggleMergeSelection(ids[0])
            board.model.toggleMergeSelection(ids[1])
            try await board.session.runner.run { ops in try ops.deleteBlock(ids[1]) }
            // The staging delete is itself an entry — the claim is that the
            // GESTURE adds none.
            let depthBefore = board.session.undoStack.depth

            await board.model.deleteSelectedBlocks()

            #expect(try board.texts() == ["one", "three"],
                    "NOTHING the gesture touched was deleted — the compound unwound")
            #expect(board.model.statusMessage == BlockSelectionCopy.blockGone,
                    "the same sentence Write's host speaks for the same race")
            #expect(board.session.undoStack.depth == depthBefore,
                    "a rolled-back gesture registers no entry of its own")
            #expect(board.model.mergeSelection.count == 2,
                    "the picks survive a refusal (the seal refusal's shape)")
        }
    }

    /// The attribution half, and the guard against over-refusing: with every
    /// pick still in the note the act is byte-unchanged — every picked block
    /// goes, under ONE entry, and the selection clears. (Passes on both
    /// sides of the revert deliberately; a red here would have meant the fix
    /// broke the ordinary road.)
    @Test func everyPickStillGoesWhenTheNoteHoldsThemAll() async throws {
        try await withBoard(seedBlocks: ["one", "two", "three", "four"]) { board in
            let ids = try board.blockIDs()
            board.model.toggleMergeSelection(ids[0])
            board.model.toggleMergeSelection(ids[2])

            await board.model.deleteSelectedBlocks()
            try board.reload()

            #expect(try board.texts() == ["two", "four"])
            #expect(board.model.mergeSelection.isEmpty)
            #expect(board.session.undoStack.depth == 1)
            #expect(board.session.undoStack.topLabel == "Delete Blocks")
        }
    }
}

// MARK: - A-3: merge names the vanished pick

@MainActor
@Suite("Merge names a vanished pick rather than calling it a gap (round A, A-3)")
struct BoardMergeDiagnosisTests {
    /// **The red-on-old pin.** Two neighbours picked; one leaves the note
    /// before the merge fires. Pre-fix the contiguity test failed (it
    /// requires every picked id to be IN the order) and the board reported a
    /// gap — sending her to look for adjacency that was never the problem.
    @Test func aVanishedPickIsNamedAsGoneNotAsAGap() async throws {
        try await withBoard(seedBlocks: ["one", "two", "three"]) { board in
            let ids = try board.blockIDs()
            board.model.toggleMergeSelection(ids[0])
            board.model.toggleMergeSelection(ids[1])
            try await board.session.runner.run { ops in try ops.deleteBlock(ids[1]) }
            let depthBefore = board.session.undoStack.depth

            await board.model.mergeSelectedBlocks()

            #expect(board.model.statusMessage == BlockSelectionCopy.blockGoneForMerge)
            #expect(board.model.statusMessage?.contains("next to each other") != true,
                    "the adjacency line is the WRONG diagnosis for this race")
            #expect(try board.texts() == ["one", "three"], "nothing was merged")
            #expect(board.session.undoStack.depth == depthBefore, "nothing registered")
        }
    }

    /// …and the real gap still says gap. This is the attribution pin: it
    /// passes on both sides of the revert, which is what proves the fix
    /// narrowed the diagnosis rather than replacing one wrong answer with
    /// another.
    @Test func aGenuineGapStillSaysGap() async throws {
        try await withBoard(seedBlocks: ["one", "two", "three"]) { board in
            let ids = try board.blockIDs()
            board.model.toggleMergeSelection(ids[0])
            board.model.toggleMergeSelection(ids[2])

            await board.model.mergeSelectedBlocks()

            #expect(board.model.statusMessage?.contains("next to each other") == true)
            #expect(try board.texts() == ["one", "two", "three"], "nothing merged")
        }
    }

    /// The two refusals are one sentence apart, and the verb is the part
    /// that has to be true on each door.
    @Test func theTwoRacesWearTheSameSentenceOneVerbApart() {
        #expect(BlockSelectionCopy.blockGone.contains("Nothing was deleted;"))
        #expect(BlockSelectionCopy.blockGoneForMerge.contains("Nothing was merged;"))
        #expect(BlockSelectionCopy.blockGone.hasPrefix(
            "One of the blocks you picked is already gone"))
        #expect(BlockSelectionCopy.blockGoneForMerge.hasPrefix(
            "One of the blocks you picked is already gone"))
    }
}

// MARK: - A-4: the card's chords come from the registry

@Suite("The take card's chords are the registry's (round A, A-4)")
struct TakeCardMenuTitleTests {
    /// The drift guard. It is deliberately NOT a red-on-old pin — the
    /// finding is cleanliness, and today's hand-typed suffixes happened to
    /// agree with the registry, so a pin here would have passed on both
    /// sides (the hollow-pin case). What it guards is the FUTURE the finding
    /// names: AR-1(e) leaves these keys hers to re-pick, and after a re-pick
    /// in the registry alone a re-hardcoded suffix disagrees and fails here.
    @Test func everyChordOnTheCardIsTheOneItsCapabilityDeclares() throws {
        for (id, title) in TakeCardMenuCopy.chorded {
            let chord = try #require(CapabilityRegistry.capability(id).shortcutLabel,
                                     "a chorded row's capability must declare its key")
            #expect(title.hasSuffix(" (\(chord))"), "\(id) row: \(title)")
            // …and it wears exactly ONE chord: a hand-typed suffix left
            // beside the derived one would show up as a second bracket.
            #expect(title.filter { $0 == "(" }.count == 1, "\(id) row: \(title)")
        }
    }

    /// The no-change proof (E11's shape): the move to the registry changed
    /// no words at all. These are the literal strings the card rendered
    /// before the fix.
    @Test func theCardsWordsAreByteUnchangedByTheMove() {
        #expect(TakeCardMenuCopy.newTake == "＋ New take — branch of this one (⌘T)")
        #expect(TakeCardMenuCopy.blankTake == "＋ Blank take (⌥⌘T)")
        #expect(TakeCardMenuCopy.archiveTake == "Archive this take (⌘⇧A)")
        #expect(TakeCardMenuCopy.copyAllTakes == "Copy All Takes (⌘⇧C)")
        #expect(TakeCardMenuCopy.takeToBlockBelow == "Move Take into a Block Below (⌥⌘⏎)")
        #expect(TakeCardMenuCopy.takesToBlocks == "Turn All Takes into Blocks (⇧⌥⌘⏎)")
    }

    /// The formatter's own contract: an unshortcut act renders its words
    /// alone, and a door speaking in its own sentence keeps it.
    @Test func theFormatterAppendsAChordOnlyWhereOneIsDeclared() {
        let unshortcut = CapabilityRegistry.capability(.deleteSelectedBlocks)
        #expect(unshortcut.shortcutLabel == nil)
        #expect(unshortcut.menuTitle() == unshortcut.verb)
        #expect(unshortcut.menuTitle("Delete 3 Blocks") == "Delete 3 Blocks")
        #expect(CapabilityRegistry.capability(.copyAllTakes).menuTitle("Copy these")
                == "Copy these (⌘⇧C)")
    }
}

// MARK: - Round 2 (R2-3): a refused gesture leaves the redo future standing

@MainActor
@Suite("A refused multi-delete leaves the redo future standing (round 2, R2-3)")
struct BoardDeleteRedoSurvivalTests {
    /// **Red-on-current pin (ladder round 2, R2-3).** Ghosts used to ride at
    /// the END of the delete chain, so a stale pick the read had ALREADY
    /// detected first committed every survivor's tombstone — each leg
    /// registering, each registration burning the redo future (R1-10's
    /// recorded behavior) — before the ghost's refusal unwound it all.
    /// Ghosts-first keeps the pinned contract byte-identical (refusal +
    /// nothing deleted + picks kept) while the detectable case now refuses
    /// BEFORE any leg lands, so a redo future survives a refused gesture.
    /// The compound remains the guarantee for the true read-to-write race,
    /// which no ordering can pre-detect.
    @Test func aRefusedGestureLeavesTheRedoFutureStanding() async throws {
        try await withBoard(seedBlocks: ["one", "two", "three"]) { board in
            let ids = try board.blockIDs()
            // Pick while both are live — the race window is held open by the
            // projection deliberately not being reloaded.
            board.model.toggleMergeSelection(ids[0])
            board.model.toggleMergeSelection(ids[1])
            // The ghost: "two" leaves behind the surface's back.
            try await board.session.runner.run { ops in try ops.deleteBlock(ids[1]) }
            // A redo future she cares about: "three" deleted, then undone.
            try await board.session.runner.run { ops in try ops.deleteBlock(ids[2]) }
            let stack = board.session.undoStack
            _ = try await board.session.runner.run { ops in
                try stack.undo(with: ops)
            }
            #expect(board.session.undoStack.redoDepth == 1,
                    "staging: one redo entry exists before the gesture")

            await board.model.deleteSelectedBlocks()

            #expect(board.model.statusMessage == BlockSelectionCopy.blockGone,
                    "the refusal is unchanged by the ordering")
            #expect(board.session.undoStack.redoDepth == 1,
                    "a REFUSED gesture must not burn the redo future — pre-fix the survivor's leg registered before the ghost threw")
        }
    }
}
