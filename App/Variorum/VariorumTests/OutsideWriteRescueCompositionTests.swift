//
//  OutsideWriteRescueCompositionTests.swift
//  VariorumTests
//
//  VX-664 × VX-683 B — the ring-end seam COMPOSED with the guarded autosave
//  (the VX-849 run, batch 3 — the record `notes/plans/fixes/
//  vx-849-typed-over-rescue.md`, BATCH 3 RECORD, piece 2: G1 and G3).
//
//  The seam (VX-677's A-677-1): a ring owner's delivery that carries stored
//  words for the live pane's take which differ from what the pane HOLDS, with
//  nothing of hers pending, is an outside write — confirmed on a fresh read,
//  the ring ends. The rescue (batch 1): an autosave whose snapshot the row no
//  longer holds keeps her words on the row and lands the displaced words as the
//  `'conflict'` take. Two holes where the two met:
//
//  G1 — "nothing of hers pending" read the coordinator's `pending`, which a
//  flush EMPTIES before its write lands. An owner that adopts deliveries while a
//  write flies (Read ▸ edit, the Blocks workbench, the book Index) consumed a
//  pull's delivery mid-flight as an outside write: the fresh read ran while her
//  write was still in the writer, CONFIRMED, and her ring ended mid-typing — the
//  very case the run's brief says the ring deliberately does NOT end (her words
//  then land and the rescue keeps both). Her buffer dropped in the same window.
//
//  G3 — a live pane never adopts projection text (P-3), so between a delivery
//  that carried an outside write and the ring-end its confirmation runs, the
//  owner's projection holds the outside words while the pane still shows hers.
//  A keystroke in that gap was recorded on the PROJECTION's text as its
//  snapshot, so the guarded autosave found the row "unchanged" and wrote her
//  pre-write words over the outside words, unseen — the remote words survived
//  nowhere (VX-664's own class re-entering through the confirmation's gap).
//
//  RED ON OLD — every pin here drives only pre-fix API (the owners' seams, the
//  coordinator, a pull's row write, the AI's edit), so on the pre-fix tree they
//  fail for the BEHAVIORAL reason named in each. The writer is HELD from a
//  background thread where a write must be provably in flight (batch 1's
//  `WriterHold`; an on-disk pool store, whose readers never wait on it).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-664 × VX-683 B — the ring-end seam composed with the guarded autosave", .serialized)
struct OutsideWriteRescueCompositionTests {
    private static let base = "The paragraph her ring is in."
    private static let hers = "The paragraph her ring is in. She types on."
    private static let remote = "The phone's version of this paragraph, pulled in."
    private static let aiWords = "An AI's rewrite of the take, landed while she paused."

    // MARK: - Staging

    /// A pull's own row write on the LOCALLY-CLEAN path: apply mode set inside
    /// the transaction (SyncSpec §3 — the outbox triggers suppressed), the
    /// remote text written over the clean row. No `Sync/` source is called.
    private static func applyAsSyncPull(_ db: AppDatabase, _ variantID: String, _ text: String) throws {
        try db.write { db in
            try db.execute(sql: "INSERT INTO _sync_applying (applying) VALUES (1)")
            try db.execute(
                sql: "UPDATE variant SET working_text = ?, sync_version = sync_version + 1 WHERE id = ?",
                arguments: [text, variantID])
            try db.execute(sql: "DELETE FROM _sync_applying")
        }
    }

    private static func stored(_ db: AppDatabase, _ variantID: String) throws -> String? {
        try db.read { try Variant.fetchOne($0, key: variantID)?.workingText }
    }

    /// The block's live takes other than `take`, as (text, label).
    private static func cards(
        _ db: AppDatabase, block: String, besides take: String
    ) throws -> [(text: String, label: String?)] {
        try db.read { db in
            try Row.fetchAll(
                db,
                sql: """
                SELECT working_text, label FROM variant
                WHERE block_id = ? AND id != ? AND deleted_at IS NULL ORDER BY fan_position
                """,
                arguments: [block, take]
            ).map { ($0["working_text"], $0["label"]) }
        }
    }

    /// The predicate holds for the whole window (a guard's patience — the
    /// confirmation is a fresh read off the main thread, then a hop back).
    private static func stays(
        for seconds: TimeInterval = 0.4, _ predicate: @MainActor () -> Bool
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            if !predicate() { return false }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
        }
        return predicate()
    }

    /// A world over an ON-DISK pool store (a held writer must leave readers
    /// free), one note with one block.
    private static func withPoolWorld(
        _ body: @MainActor (AppSession, AppDatabase, String, String, String) async throws -> Void
    ) async throws {
        let (db, directory) = try AutosaveCoordinatorTests.poolStore()
        defer { try? FileManager.default.removeItem(at: directory) }
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 664))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the note a pull and her typing share")
            let made = try session.operations.newBlock(
                in: post.id, text: Self.base, registeringUndo: false)
            try await body(session, db, post.id, made.block.id, made.variant.id)
        }
    }

    /// An in-memory world, two blocks (the second her ring's).
    private static func withWorld(
        _ body: @MainActor (AppSession, AppDatabase, String, [String]) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 664))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the note an AI and her typing share")
            var blocks: [String] = []
            for text in ["The first block, as she left it.", Self.base] {
                blocks.append(try session.operations.newBlock(
                    in: post.id, text: text, registeringUndo: false).block.id)
            }
            try await body(session, db, post.id, blocks)
        }
    }

    private static func chosen(_ db: AppDatabase, _ postID: String, _ blockID: String) throws -> String {
        try #require(try db.read { try Queries.renderPost($0, containerID: postID) }
            .first { $0.blockID == blockID }?.variantID)
    }

    // MARK: - G1 — a delivery consumed while her own write flies

    /// **RED ON OLD — READ ▸ EDIT (the TOC model, which adopts every delivery):
    /// she types; a pull lands the phone's words on the clean row inside her
    /// debounce; her debounce fires and the rescue write is IN FLIGHT (the writer
    /// held); the pull's delivery is consumed NOW.** On the old tree the guard read
    /// `pending` — already emptied by the flush — so the delivery was judged an
    /// outside write, the fresh read (a reader — it never waits on the writer)
    /// still saw the phone's words, and her ring ENDED mid-typing; her buffer
    /// dropped with it. The ring must stay: nothing landed on the row from
    /// outside that her own in-flight write will not rescue.
    @Test func aPullConsumedWhileHerRescueWriteFliesLeavesReadEditsRing() async throws {
        try await Self.withPoolWorld { session, db, postID, block, take in
            let model = BlockTOCViewModel(session: session, postID: postID)
            model.adopt(rows: try await db.read { try Queries.blockTOC($0, post: postID) })
            model.makeLive(block, variantID: take)
            #expect(model.liveBlockID == block, "fixture: the block is live")

            model.paneEdited(variantID: take, oldText: Self.base, newText: Self.hers)
            try Self.applyAsSyncPull(db, take, Self.remote)

            let hold = WriterHold()
            hold.hold(db)
            let coordinator = model.autosave
            let flight = Task { await coordinator.flushNow() }
            try await AutosaveCoordinatorTests.waitUntil { coordinator.pending.isEmpty && coordinator.isDirty }

            // The pull's delivery, consumed while her rescue write flies.
            model.adopt(rows: try await db.read { try Queries.blockTOC($0, post: postID) })
            let ringStayed = await Self.stays { model.liveBlockID == block }
            let shown = model.displayText(variantID: take, storeText: Self.remote)
            hold.release()
            await flight.value

            #expect(ringStayed, "RED ON OLD: the delivery consumed mid-flight ended her ring while she typed")
            #expect(shown == Self.hers,
                    "RED ON OLD: her buffer dropped while her write flew — the mirror read the pull's words")
            // Then the write landed exactly as batch 1 built it, and its echo
            // never ends her ring.
            #expect(try Self.stored(db, take) == Self.hers, "her buffer keeps the row (R-683-1)")
            let rescued = try Self.cards(db, block: block, besides: take)
            #expect(rescued.map(\.text) == [Self.remote], "the pull's words are the card")
            #expect(rescued.first?.label == "conflict", "R-683-2")
            model.adopt(rows: try await db.read { try Queries.blockTOC($0, post: postID) })
            #expect(await Self.stays { model.liveBlockID == block }, "her own echo never ends the ring")
        }
    }

    /// **RED ON OLD — THE BOOK INDEX (adopts every delivery through its per-note
    /// observation): the same flight, the same delivery.**
    @Test func aPullConsumedWhileHerRescueWriteFliesLeavesTheIndexRing() async throws {
        try await Self.withPoolWorld { session, db, postID, block, take in
            let edit = BookIndexEditModel(session: session)
            edit.makeLive(postID: postID, blockID: block, variantID: take, storedText: Self.base)
            #expect(edit.liveBlockID == block, "fixture: the Index block is live")

            edit.paneEdited(postID: postID, variantID: take, oldText: Self.base, newText: Self.hers)
            try Self.applyAsSyncPull(db, take, Self.remote)

            let hold = WriterHold()
            hold.hold(db)
            let coordinator = session.autosave(forPost: postID)  // the note's ONE coordinator
            defer { session.releaseAutosave(forPost: postID) }
            let flight = Task { await coordinator.flushNow() }
            try await AutosaveCoordinatorTests.waitUntil { coordinator.pending.isEmpty && coordinator.isDirty }

            edit.settle(postID: postID, rows: try await db.read { try Queries.blockTOC($0, post: postID) })
            let ringStayed = await Self.stays { edit.liveBlockID == block }
            let shown = edit.displayText(variantID: take, storeText: Self.remote)
            hold.release()
            await flight.value

            #expect(ringStayed, "RED ON OLD: the delivery consumed mid-flight ended her ring while she typed")
            #expect(shown == Self.hers, "RED ON OLD: her buffer dropped while her write flew")
            #expect(try Self.stored(db, take) == Self.hers)
            #expect(try Self.cards(db, block: block, besides: take).map(\.text) == [Self.remote])
        }
    }

    // MARK: - G3 — a keystroke in the confirmation's gap

    /// **RED ON OLD — TAKES: an AI's `edit_take` lands on the take while she
    /// paused; the board adopts its delivery (the suspicion raised, its fresh
    /// read not yet run) and, in that gap, she types — into a live pane that
    /// still shows HER words (a live pane never adopts — P-3).** On the old tree
    /// the keystroke's snapshot was the board's PROJECTION text — the AI's words
    /// — so the guarded autosave found the row "unchanged" and wrote her pre-edit
    /// words over the AI's, unseen: the AI's words survived nowhere but its
    /// "after" savepoint. Now the snapshot is what the pane holds, so the row
    /// changed under it and the rescue keeps both: her words on the row, the AI's
    /// the `'conflict'` card. (The ring's own fate in this race rides the
    /// confirmation's timing — G1's held-writer pins assert the ring; this one
    /// asserts the words.)
    @Test func aKeystrokeInTheConfirmationGapIsRescuedNeverWrittenOver() async throws {
        try await Self.withWorld { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let suite = "OutsideWriteRescueCompositionTests-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            let model = TakesViewModel(session: session, postID: postID, defaults: defaults)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID, blockID: blocks[1], variantID: take))
            #expect(model.focusedPane?.variantID == take, "fixture: her ring is in the take")

            try session.operations.editTakeUnderInsurance(
                take, text: Self.aiWords, expectedText: Self.base, client: "claude-code",
                undoLabel: "claude-code's edit")
            model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
            // Her keystroke in the gap — the pane still shows her words.
            model.paneEdited(variantID: take, newText: Self.hers)
            #expect(await model.flushPendingText(), "fixture: her typing landed")

            #expect(try Self.stored(db, take) == Self.hers, "her buffer keeps the row (R-683-1)")
            let rescued = try Self.cards(db, block: blocks[1], besides: take)
            #expect(rescued.map(\.text) == [Self.aiWords],
                    "RED ON OLD: her keystroke wrote her pre-edit words over the AI's edit — the AI's words survived nowhere on the take's fan")
            #expect(rescued.first?.label == "conflict", "R-683-2")
        }
    }

    /// **RED ON OLD — CANVAS (an owner that adopts its projection directly):
    /// the same gap, the same keystroke.**
    @Test func aCanvasKeystrokeInTheConfirmationGapIsRescuedNeverWrittenOver() async throws {
        try await Self.withWorld { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let model = CanvasViewModel(session: session, containerID: postID)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: postID) })
            model.focus(blockID: blocks[1], variantID: take)
            #expect(model.isPaneLive(blockID: blocks[1], variantID: take), "fixture: the card is live")

            try session.operations.editTakeUnderInsurance(
                take, text: Self.aiWords, expectedText: Self.base, client: "claude-code",
                undoLabel: "claude-code's edit")
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: postID) })
            model.paneEdited(blockID: blocks[1], variantID: take, newText: Self.hers)
            await session.autosave(forPost: postID).flushNow()
            session.releaseAutosave(forPost: postID)

            #expect(try Self.stored(db, take) == Self.hers, "her buffer keeps the row (R-683-1)")
            #expect(try Self.cards(db, block: blocks[1], besides: take).map(\.text) == [Self.aiWords],
                    "RED ON OLD: her keystroke wrote her pre-edit words over the AI's edit")
        }
    }

    // MARK: - Guards (green on both sides — the false-positive class)

    /// GUARD — her own successive runs in Read ▸ edit, each echoed between,
    /// never mint a card and never end her ring.
    @Test func readEditsOwnSuccessiveRunsNeverMintACardNorEndTheRing() async throws {
        try await Self.withPoolWorld { session, db, postID, block, take in
            let model = BlockTOCViewModel(session: session, postID: postID)
            model.adopt(rows: try await db.read { try Queries.blockTOC($0, post: postID) })
            model.makeLive(block, variantID: take)
            model.paneEdited(variantID: take, oldText: Self.base, newText: Self.base + " A.")
            await model.autosave.flushNow()
            model.adopt(rows: try await db.read { try Queries.blockTOC($0, post: postID) })
            model.paneEdited(variantID: take, oldText: Self.base + " A.", newText: Self.base + " A. B.")
            await model.autosave.flushNow()
            model.adopt(rows: try await db.read { try Queries.blockTOC($0, post: postID) })
            #expect(try Self.stored(db, take) == Self.base + " A. B.")
            #expect(try Self.cards(db, block: block, besides: take).isEmpty, "her own words are never somebody else's")
            #expect(await Self.stays { model.liveBlockID == block })
        }
    }
}
