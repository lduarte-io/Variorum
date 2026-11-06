//
//  OutsideWriteRingEndTests.swift
//  VariorumTests
//
//  VX-664 (the VX-677 run, batch 1 — the record `notes/plans/fixes/
//  vx-677-editor-panes-ai-door.md`, BATCH 1 RECORD; her ruling on the ticket,
//  option (a) scoped; the architect's A-677-1): EVERY ring owner ends its ring
//  when an outside write lands on the live pane's OWN take — at its existing
//  delivery seam, confirmed on a fresh read — and never otherwise.
//
//  Each pin drives a different REAL road into the store (the operation the
//  door calls — never a stand-in), then hands the owner the delivery its
//  observation would (a fresh read through the owner's own seam), and reads
//  the owner's ONE answer: is the ring still live? The surface half — a pane
//  that stops being live goes read and adopts the stored words — is the
//  existing read arm (VX-440's W-1 pins hold it) and the mounted pins in
//  `OutsideWriteLivePaneTests`.
//
//  The sweep table's rows, pinned here (S-numbers are the record's):
//  S1 restore → Write's take panel, Compare · S2 MCP restore_commit → Read ▸
//  edit · S3 MCP edit_take → Takes · S4 Replace in Every Take → the Blocks
//  workbench · S5 extract → Canvas · S6 divide → Takes · S7 the board's Split
//  at Newlines → Takes · S8 move span to a new take → Canvas · S9 a structural
//  undo → Takes · S10 another window's typing → Takes, the book Index · S11 a
//  sync apply → Lenses.
//
//  RED ON OLD (`rev664`, the rule neutralized): every `…RingEnds…` pin — the
//  ring stays live over words the store no longer holds. GUARDS (green on both
//  sides): her own typing, a stale photograph, an outside write racing her
//  pending typing (VX-683's class — the buffer stays authoritative).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withOutsideWriteWorld<T>(
    blocks texts: [String],
    _ body: @MainActor (AppSession, AppDatabase, String, [String]) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 664))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let post = try session.operations.createPost(title: "the note an outside write reaches")
        var blocks: [String] = []
        for text in texts {
            blocks.append(try session.operations.newBlock(
                in: post.id, text: text, registeringUndo: false).block.id)
        }
        return try await body(session, db, post.id, blocks)
    }
}

/// Poll a predicate across main-actor turns (the confirmation is a fresh
/// read off the main thread, then a hop back).
@MainActor
private func eventually(
    timeout: TimeInterval = 2, _ predicate: @MainActor () -> Bool
) async -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while !predicate(), Date() < deadline {
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(10))
    }
    return predicate()
}

/// The ring STAYS for the whole window — a guard's patience.
@MainActor
private func stays(for seconds: TimeInterval = 0.4, _ predicate: @MainActor () -> Bool) async -> Bool {
    let deadline = Date().addingTimeInterval(seconds)
    while Date() < deadline {
        if !predicate() { return false }
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(10))
    }
    return predicate()
}

@MainActor
@Suite("VX-664 — every ring owner ends its ring on an outside write to its own take", .serialized)
struct OutsideWriteRingEndTests {
    private static let first = "The first block, as she left it."
    private static let second = "The second block, the one her ring is in."

    // MARK: - Reads

    private static func chosen(_ db: AppDatabase, _ postID: String, _ blockID: String) throws -> String {
        try #require(try db.read { try Queries.renderPost($0, containerID: postID) }
            .first { $0.blockID == blockID }?.variantID)
    }

    private static func stored(_ db: AppDatabase, _ variantID: String) throws -> String? {
        try db.read { try Variant.fetchOne($0, key: variantID)?.workingText }
    }

    private static func takes(_ session: AppSession, _ postID: String) throws -> TakesViewModel {
        let suite = "OutsideWriteRingEndTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return TakesViewModel(session: session, postID: postID, defaults: defaults)
    }

    private static func takesProjection(_ db: AppDatabase, _ postID: String) throws -> Queries.TakesProjection {
        try db.read { try Queries.takesProjection($0, post: postID) }
    }

    /// The article's key for a block's chosen take.
    private static func article(_ blockID: String, _ variantID: String) -> TakesViewModel.PaneKey {
        TakesViewModel.PaneKey(
            columnID: TakesViewModel.takesMainColumnID, blockID: blockID, variantID: variantID)
    }

    /// A pull's own row write: apply mode set inside the transaction (SyncSpec
    /// §3 — the outbox triggers suppressed), the remote text written over the
    /// locally clean row. The test stages the store state a pull leaves; no
    /// `Sync/` source is touched or called.
    private static func applyAsSyncPull(_ db: AppDatabase, _ variantID: String, _ text: String) throws {
        try db.write { db in
            try db.execute(sql: "INSERT INTO _sync_applying (applying) VALUES (1)")
            try db.execute(
                sql: "UPDATE variant SET working_text = ? WHERE id = ?", arguments: [text, variantID])
            try db.execute(sql: "DELETE FROM _sync_applying")
        }
    }

    // MARK: - Takes (the Takes board's own host)

    /// **S3 — RED ON OLD: an AI's `edit_take` on her live take ends the ring**
    /// (the door's own operation, its bracket savepoints and all), through the
    /// board's REAL delivery road (`deliver` → the projection policy → a fresh
    /// read → `adopt`).
    @Test func takesRingEndsWhenAnAIEditsItsTake() async throws {
        try await withOutsideWriteWorld(blocks: [Self.first, Self.second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let model = try Self.takes(session, postID)
            model.adopt(try Self.takesProjection(db, postID))
            model.focus(Self.article(blocks[1], take))
            #expect(model.focusedPane?.variantID == take, "fixture: her ring is in the take")

            let words = "An AI's edit of the take she has open."
            try session.operations.editTakeUnderInsurance(
                take, text: words, expectedText: Self.second, client: "claude-code",
                undoLabel: "claude-code's edit")
            model.deliver(try Self.takesProjection(db, postID))

            #expect(await eventually { model.focusedPane == nil },
                    "RED ON OLD: the ring stayed over words the store no longer holds")
            #expect(try Self.stored(db, take) == words, "the AI's edit stands")
        }
    }

    /// **S7 — RED ON OLD: the board's OWN Split at Newlines, run on the block
    /// her ring is in** (the unenumerated road: the split keeps the block as
    /// its first paragraph and parks no ring). The ring ends; the first half
    /// is the take's stored words, never the whole text written back.
    @Test func takesRingEndsWhenTheBoardSplitsItsBlockAtNewlines() async throws {
        let twoParagraphs = "The paragraph she is in.\nAnd a second one under it."
        try await withOutsideWriteWorld(blocks: [Self.first, twoParagraphs]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let model = try Self.takes(session, postID)
            model.adopt(try Self.takesProjection(db, postID))
            model.focus(Self.article(blocks[1], take))
            #expect(model.commandTargetSlot?.blockID == blocks[1], "fixture: the split's target is her block")

            await model.structure.splitFocusedBlockAtNewlines()
            #expect(try Self.stored(db, take) == "The paragraph she is in.",
                    "fixture: the block kept its first paragraph")
            model.adopt(try Self.takesProjection(db, postID))

            #expect(await eventually { model.focusedPane?.variantID != take },
                    "RED ON OLD: the ring stayed on the split block's take over its whole old text")
        }
    }

    /// **S6 — RED ON OLD: a DIVIDE of her ring's block from outside the board**
    /// (Write in another window, the AI's `divide_block`): the block keeps its
    /// take as the first half — her pane's take, rewritten.
    @Test func takesRingEndsWhenADivideCutsItsTake() async throws {
        try await withOutsideWriteWorld(blocks: [Self.first, Self.second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let model = try Self.takes(session, postID)
            model.adopt(try Self.takesProjection(db, postID))
            model.focus(Self.article(blocks[1], take))

            _ = try session.operations.divide(blocks[1], cut: 11)
            // Fixture (non-vacuity): the take now holds the FIRST HALF exactly as
            // `divide` stores it — the seam's whitespace trimmed by the op's own
            // pure rule (`BoundarySnapping.seamTrimmedHalves`: "The second", not
            // the raw prefix "The second " this line first expected — the vx677-b1
            // window's red-on-both finding, traced in the record).
            let firstHalf = try #require(
                BoundarySnapping.seamTrimmedHalves(Self.second, cutAtUTF16: 11)?.first)
            #expect(try Self.stored(db, take) == firstHalf, "fixture: the divide rewrote her take")
            model.adopt(try Self.takesProjection(db, postID))

            #expect(await eventually { model.focusedPane == nil }, "RED ON OLD")
        }
    }

    /// **S9 — RED ON OLD: a structural UNDO restoring her ring's take** (⌥⌘Z of
    /// a divide — from any window, any door): the take's whole text comes back
    /// under a pane that held the first half.
    @Test func takesRingEndsWhenAStructuralUndoRestoresItsTake() async throws {
        try await withOutsideWriteWorld(blocks: [Self.first, Self.second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            _ = try session.operations.divide(blocks[1], cut: 11)
            let model = try Self.takes(session, postID)
            model.adopt(try Self.takesProjection(db, postID))
            model.focus(Self.article(blocks[1], take))
            #expect(model.focusedPane?.variantID == take, "fixture: her ring is in the first half")

            _ = try session.undoStack.undo(with: session.operations)
            #expect(try Self.stored(db, take) == Self.second, "fixture: the undo restored the whole take")
            model.adopt(try Self.takesProjection(db, postID))

            #expect(await eventually { model.focusedPane == nil }, "RED ON OLD")
        }
    }

    /// **S10 — RED ON OLD: ANOTHER WINDOW types in the same take** (its own
    /// board, its own live pane, the one per-post pipeline): once its typing
    /// lands, this window's ring — over the old words — ends; the typing
    /// window's own ring stays (its words ARE the store's).
    @Test func takesRingEndsWhenAnotherWindowTypesItsTake() async throws {
        try await withOutsideWriteWorld(blocks: [Self.first, Self.second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let here = try Self.takes(session, postID)
            let there = try Self.takes(session, postID)
            here.adopt(try Self.takesProjection(db, postID))
            there.adopt(try Self.takesProjection(db, postID))
            here.focus(Self.article(blocks[1], take))
            there.focus(Self.article(blocks[1], take))

            let typed = Self.second + " Typed in the other window."
            there.paneEdited(variantID: take, newText: typed)
            #expect(await there.flushPendingText(), "fixture: the other window's typing landed")
            #expect(try Self.stored(db, take) == typed)
            here.adopt(try Self.takesProjection(db, postID))
            there.adopt(try Self.takesProjection(db, postID))

            #expect(await eventually { here.focusedPane == nil },
                    "RED ON OLD: this window's ring stayed over the old words")
            #expect(there.focusedPane?.variantID == take, "the typing window's own ring stays")
        }
    }

    /// GUARD — her OWN typing, landed and echoed, never ends her ring.
    @Test func herOwnTypingNeverEndsTheRing() async throws {
        try await withOutsideWriteWorld(blocks: [Self.first, Self.second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let model = try Self.takes(session, postID)
            model.adopt(try Self.takesProjection(db, postID))
            model.focus(Self.article(blocks[1], take))
            model.paneEdited(variantID: take, newText: Self.second + " She types on.")
            #expect(await model.flushPendingText())
            model.deliver(try Self.takesProjection(db, postID))
            #expect(await stays { model.focusedPane?.variantID == take },
                    "her own echo is never somebody else's write")
        }
    }

    /// GUARD — an outside write racing her PENDING typing on the same take:
    /// the buffer stays authoritative and the ring stays (VX-683's class —
    /// the roads that meet it are insured by flush-first and the brackets).
    @Test func anOutsideWriteRacingHerPendingTypingLeavesTheRing() async throws {
        try await withOutsideWriteWorld(blocks: [Self.first, Self.second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let model = try Self.takes(session, postID)
            model.adopt(try Self.takesProjection(db, postID))
            model.focus(Self.article(blocks[1], take))
            model.paneEdited(variantID: take, newText: Self.second + " Still typing")
            try Self.applyAsSyncPull(db, take, "A phone's edit, mid-keystroke.")
            model.adopt(try Self.takesProjection(db, postID))  // the seam, directly
            #expect(await stays { model.focusedPane?.variantID == take })
            #expect(model.liveBuffers[take] == Self.second + " Still typing", "her pending words stay on screen")
        }
    }

    // MARK: - Lenses (the Takes model, Lenses host)

    /// **S11 — RED ON OLD: a SYNC PULL writes her live Lenses cell's take** —
    /// consumed UI-side from the store's own delivery (zero `Sync/` lines).
    @Test func lensesRingEndsWhenASyncPullWritesItsTake() async throws {
        try await withOutsideWriteWorld(blocks: [Self.first, Self.second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[0])
            let model = try Self.takes(session, postID)
            model.host = .lenses
            model.adopt(try Self.takesProjection(db, postID))
            let column = try #require(model.columns.first { $0.kind == .main })
            model.focus(TakesViewModel.PaneKey(columnID: column.id, blockID: blocks[0], variantID: take))
            #expect(model.focusedPane?.variantID == take)

            try Self.applyAsSyncPull(db, take, "The phone's version of this paragraph.")
            model.deliver(try Self.takesProjection(db, postID))

            #expect(await eventually { model.focusedPane == nil }, "RED ON OLD")
        }
    }

    // MARK: - Write's take panel (the Takes model, scoped to one block)

    /// **S1 — RED ON OLD: a Block History restore beside Write's take panel**
    /// (the panel's model never hears VX-440's parcel — it is neither board).
    @Test func writePanelRingEndsWhenBlockHistoryRestoresItsTake() async throws {
        try await withOutsideWriteWorld(blocks: [Self.first, Self.second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let commit = try session.operations.commit(take)
            let now = "Changed since the moment."
            try session.operations.autosave(take, text: now, charDelta: 12)
            let model = try Self.takes(session, postID)
            model.writePanelBlockID = blocks[1]
            model.adopt(try Self.takesProjection(db, postID))
            model.focus(TakesViewModel.PaneKey(columnID: "write-panel", blockID: blocks[1], variantID: take))
            #expect(model.focusedPane?.variantID == take, "fixture: the panel's pane is live")

            // VX-827 U3b — A JUSTIFIED EDIT: the panel retired whole; the
            // Commits face's Restore is the same restore (an outside write).
            let history = CommitsFaceModel(session: session, request: BlockHistoryRequest(
                postID: postID, blockID: blocks[1], focusedVariantID: take))
            await history.restore(commit, of: take)
            #expect(try Self.stored(db, take) == Self.second, "fixture: restored")
            model.adopt(try Self.takesProjection(db, postID))

            #expect(await eventually { model.focusedPane == nil }, "RED ON OLD")
        }
    }

    // MARK: - Compare

    /// **S1 — RED ON OLD: a Block History restore beside Compare** (the anchor
    /// column's live cell).
    @Test func compareRingEndsWhenBlockHistoryRestoresItsTake() async throws {
        try await withOutsideWriteWorld(blocks: [Self.first, Self.second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[0])
            let commit = try session.operations.commit(take)
            try session.operations.autosave(take, text: "Changed since the moment.", charDelta: 12)
            let model = CompareViewModel(session: session, anchorPostID: postID)
            model.adopt(try await db.read { try CompareViewModel.read($0, anchor: postID, peers: []) })
            let key = PaneTextAuthority.PaneKey(
                columnID: "compare-\(postID)", blockID: blocks[0], variantID: take, context: postID)
            model.focus(key)
            #expect(model.authority.isLive(key), "fixture: the anchor cell is live")

            // VX-827 U3b — A JUSTIFIED EDIT: the Commits face's Restore.
            let history = CommitsFaceModel(session: session, request: BlockHistoryRequest(
                postID: postID, blockID: blocks[0]))
            await history.restore(commit, of: take)
            model.adopt(try await db.read { try CompareViewModel.read($0, anchor: postID, peers: []) })

            #expect(await eventually { model.authority.livePane == nil }, "RED ON OLD")
        }
    }

    // MARK: - Canvas

    /// **S8 — RED ON OLD: Write's "move the span to a new take" rewrites her
    /// live card's take** (the source keeps the remainder).
    @Test func canvasRingEndsWhenASpanMovesOutOfItsTake() async throws {
        try await withOutsideWriteWorld(blocks: [Self.first, Self.second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let model = CanvasViewModel(session: session, containerID: postID)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: postID) })
            model.focus(blockID: blocks[1], variantID: take)
            #expect(model.isPaneLive(blockID: blocks[1], variantID: take), "fixture: the card is live")

            _ = try session.operations.moveSpanToNewTake(
                from: take, span: 0..<11, expectedText: Self.second)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: postID) })

            #expect(await eventually { !model.isPaneLive(blockID: blocks[1], variantID: take) },
                    "RED ON OLD")
        }
    }

    /// **S5 — RED ON OLD: an EXTRACT from her live card's block** (Write's seam
    /// gesture): the source keeps the remainder under her pane.
    @Test func canvasRingEndsWhenAnExtractCutsItsTake() async throws {
        try await withOutsideWriteWorld(blocks: [Self.first, Self.second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let model = CanvasViewModel(session: session, containerID: postID)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: postID) })
            model.focus(blockID: blocks[1], variantID: take)

            let length = (Self.second as NSString).length
            _ = try session.operations.extract(blocks[1], span: (length - 9)..<length)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: postID) })

            #expect(await eventually { !model.isPaneLive(blockID: blocks[1], variantID: take) },
                    "RED ON OLD")
        }
    }

    /// GUARD — a PHOTOGRAPH fetched before her own write landed (the 13e E15
    /// class), consumed by an owner that adopts deliveries directly: the fresh
    /// read dispels the suspicion and her ring stays.
    @Test func aStalePhotographNeverEndsHerRing() async throws {
        try await withOutsideWriteWorld(blocks: [Self.first, Self.second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let model = CanvasViewModel(session: session, containerID: postID)
            let photograph = try await db.read { try Queries.canvasProjection($0, container: postID) }
            model.adopt(photograph)
            model.focus(blockID: blocks[1], variantID: take)
            model.paneEdited(blockID: blocks[1], variantID: take, newText: Self.second + " Hers.")
            await session.autosave(forPost: postID).flushNow()
            #expect(try Self.stored(db, take) == Self.second + " Hers.", "fixture: her typing landed")

            model.adopt(photograph)  // the stale value, consumed after the settle
            #expect(await stays { model.isPaneLive(blockID: blocks[1], variantID: take) },
                    "a photograph of her own words before she typed them never ends her ring")
        }
    }

    // MARK: - Read ▸ edit and the Blocks workbench (the TOC model)

    /// **S2 — RED ON OLD: an AI's `restore_commit` into Read ▸ edit's live
    /// block.**
    @Test func readEditRingEndsWhenAnAIRestoresACommitIntoItsTake() async throws {
        try await withOutsideWriteWorld(blocks: [Self.first, Self.second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[0])
            let commit = try session.operations.commit(take)
            try session.operations.autosave(take, text: "Changed since the moment.", charDelta: 12)
            let model = BlockTOCViewModel(session: session, postID: postID)
            model.adopt(rows: try await db.read { try Queries.blockTOC($0, post: postID) })
            model.makeLive(blocks[0], variantID: take)
            #expect(model.liveBlockID == blocks[0], "fixture: the block is live")

            try session.operations.restoreCommitForClient(
                commit.id, client: "claude-code", undoLabel: "claude-code's restore")
            model.adopt(rows: try await db.read { try Queries.blockTOC($0, post: postID) })

            #expect(await eventually { model.liveBlockID == nil }, "RED ON OLD")
        }
    }

    /// **S4 — RED ON OLD: Write's "Replace in Every Take" rewrites the
    /// workbench panel's live take** (`editTakesAtomically` — the takes Write's
    /// own editor does not show).
    @Test func workbenchRingEndsWhenWriteReplacesInEveryTake() async throws {
        try await withOutsideWriteWorld(blocks: [Self.first, Self.second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let model = BlockTOCViewModel(session: session, postID: postID)
            model.adopt(rows: try await db.read { try Queries.blockTOC($0, post: postID) })
            model.adopt(facts: try await db.read { try Queries.blockWorkbench($0, post: postID) })
            model.makeLive(blocks[1], variantID: take)
            #expect(model.liveBlockID == blocks[1])

            let replaced = Self.second.replacingOccurrences(of: "ring", with: "caret")
            _ = try session.operations.editTakesAtomically(
                [.init(variantID: take, newText: replaced, charDelta: 9)],
                undoLabel: "Replace in Every Take")
            model.adopt(facts: try await db.read { try Queries.blockWorkbench($0, post: postID) })

            #expect(await eventually { model.liveBlockID == nil }, "RED ON OLD")
        }
    }

    // MARK: - The book Index

    /// **S10 — RED ON OLD: another window's typing reaches the book Index's
    /// live block** (any surface's autosave — the store write is the same).
    @Test func bookIndexRingEndsWhenAnotherWindowTypesItsTake() async throws {
        try await withOutsideWriteWorld(blocks: [Self.first, Self.second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[0])
            let edit = BookIndexEditModel(session: session)
            let rows = try await db.read { try Queries.blockTOC($0, post: postID) }
            edit.makeLive(
                postID: postID, blockID: blocks[0], variantID: take,
                storedText: rows.first { $0.blockID == blocks[0] }?.text)
            #expect(edit.liveBlockID == blocks[0], "fixture: the Index block is live")

            try session.operations.autosave(
                take, text: Self.first + " Typed in Write, in another window.", charDelta: 30)
            edit.settle(postID: postID, rows: try await db.read { try Queries.blockTOC($0, post: postID) })

            #expect(await eventually { edit.liveBlockID == nil }, "RED ON OLD")
        }
    }
}
