//
//  TypedOverRescueSurfaceTests.swift
//  VariorumTests
//
//  VX-683 B on the SURFACES (the VX-849 run, batch 1 — the record
//  `notes/plans/fixes/vx-849-typed-over-rescue.md`, BATCH 1 RECORD; the memo
//  `notes/plans/fixes/vx-683-sync-into-debounce.md`, R-683-1…4): every editing
//  surface hands its coordinator the text its edit was built on, and the
//  coordinator's write carries the RUN's first snapshot as the guarded
//  autosave's `expectedText`. A row changed under the run since (a sync pull
//  in the debounce window, the MCP door, a second window) is RESCUED: her
//  buffer keeps the row, the displaced words land as the `'conflict'` take.
//
//  RED ON OLD — the two surface pins (`…RescuesThePullsWords`) drive only
//  pre-fix API (the real typing road, a pull's row write, the flush), so on
//  the pre-fix tree they fail for the BEHAVIORAL reason: the pull's words
//  survive nowhere. The coordinator pins name the new `basedOn:` parameter
//  (compile-red on the pre-fix tree; their behavioral red is the record's
//  named revert). GUARDS (green on both sides): her own successive runs never
//  mint a card — the false-positive class this guard must never grow.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-683 B — the surfaces carry the snapshot; a typed-over row is rescued", .serialized)
struct TypedOverRescueSurfaceTests {
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

    @MainActor
    private static func withPaneWorld<T>(
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 683))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the typed-over note")
            var blocks: [String] = []
            for text in texts {
                blocks.append(try session.operations.newBlock(
                    in: post.id, text: text, registeringUndo: false).block.id)
            }
            return try await body(session, db, post.id, blocks)
        }
    }

    private static func takesModel(_ session: AppSession, _ postID: String) throws -> TakesViewModel {
        let suite = "TypedOverRescueSurfaceTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return TakesViewModel(session: session, postID: postID, defaults: defaults)
    }

    private static func takesProjection(_ db: AppDatabase, _ postID: String) throws -> Queries.TakesProjection {
        try db.read { try Queries.takesProjection($0, post: postID) }
    }

    private static func chosen(_ db: AppDatabase, _ postID: String, _ blockID: String) throws -> String {
        try #require(try db.read { try Queries.renderPost($0, containerID: postID) }
            .first { $0.blockID == blockID }?.variantID)
    }

    // MARK: - Write (the editor seam)

    /// **RED ON OLD — WRITE: she types; a pull lands the phone's words on the
    /// clean row inside the debounce window; her autosave then fires.** Pre-fix
    /// it blind-wrote and the phone's words survived nowhere. Now her buffer
    /// keeps the row (R-683-1) and the phone's words are the `'conflict'` take.
    @Test func writeTypingOverASyncPullRescuesThePullsWords() async throws {
        try await withEditor(seedBlocks: ["The base."]) { h in
            let take = try #require(h.model.slots.first?.variantID)
            let block = try #require(h.model.slots.first?.blockID)
            h.type(" Her next sentence.", at: "The base.".utf16.count)
            #expect(h.model.autosave.isDirty, "fixture: her typing sits in the debounce window")
            try Self.applyAsSyncPull(h.database, take, "The phone's rewrite.")

            await h.flush()

            #expect(try Self.stored(h.database, take) == "The base. Her next sentence.",
                    "her buffer keeps the row (R-683-1)")
            let rescued = try Self.cards(h.database, block: block, besides: take)
            #expect(rescued.map(\.text) == ["The phone's rewrite."],
                    "RED ON OLD: the pull's words survived nowhere")
            #expect(rescued.first?.label == "conflict", "R-683-2")
        }
    }

    /// GUARD — WRITE: her own successive runs (type, land, type again, land —
    /// with and without the projection's echo adopted between) never mint a
    /// card: each run's snapshot is her own last landed text.
    @Test func writeHerOwnSuccessiveRunsNeverMintACard() async throws {
        try await withEditor(seedBlocks: ["One."]) { h in
            let take = try #require(h.model.slots.first?.variantID)
            let block = try #require(h.model.slots.first?.blockID)
            h.type(" Two.", at: "One.".utf16.count)
            await h.flush()
            h.type(" Three.", at: "One. Two.".utf16.count)
            await h.flush()
            try h.reload()  // the echo adopted
            h.type(" Four.", at: "One. Two. Three.".utf16.count)
            await h.flush()
            #expect(try Self.stored(h.database, take) == "One. Two. Three. Four.")
            #expect(try Self.cards(h.database, block: block, besides: take).isEmpty,
                    "her own words are never somebody else's")
        }
    }

    // MARK: - Takes (a pane surface — `PaneTextAuthority`'s callers)

    /// **RED ON OLD — A TAKES PANE: the same race on the board's live pane.**
    @Test func takesPaneTypingOverASyncPullRescuesThePullsWords() async throws {
        let second = "The second block, the one her ring is in."
        try await Self.withPaneWorld(blocks: ["First.", second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let model = try Self.takesModel(session, postID)
            model.adopt(try Self.takesProjection(db, postID))
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID, blockID: blocks[1], variantID: take))
            model.paneEdited(variantID: take, newText: second + " Still typing")
            try Self.applyAsSyncPull(db, take, "A phone's edit, mid-keystroke.")

            #expect(await model.flushPendingText())

            #expect(try Self.stored(db, take) == second + " Still typing", "R-683-1")
            let rescued = try Self.cards(db, block: blocks[1], besides: take)
            #expect(rescued.map(\.text) == ["A phone's edit, mid-keystroke."],
                    "RED ON OLD: the pull's words survived nowhere")
            #expect(rescued.first?.label == "conflict")
        }
    }

    /// GUARD — A TAKES PANE: her own successive runs never mint a card.
    @Test func takesPaneHerOwnSuccessiveRunsNeverMintACard() async throws {
        let second = "Second."
        try await Self.withPaneWorld(blocks: ["First.", second]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let model = try Self.takesModel(session, postID)
            model.adopt(try Self.takesProjection(db, postID))
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID, blockID: blocks[1], variantID: take))
            model.paneEdited(variantID: take, newText: "Second. A.")
            #expect(await model.flushPendingText())
            model.paneEdited(variantID: take, newText: "Second. A. B.")
            #expect(await model.flushPendingText())
            model.adopt(try Self.takesProjection(db, postID))
            model.paneEdited(variantID: take, newText: "Second. A. B. C.")
            #expect(await model.flushPendingText())
            #expect(try Self.stored(db, take) == "Second. A. B. C.")
            #expect(try Self.cards(db, block: blocks[1], besides: take).isEmpty)
        }
    }

    // MARK: - The coordinator (the run's snapshot)

    /// The run's FIRST snapshot rides the write — the coalesced keystrokes
    /// after it were built on her own pending text, never on the store, so a
    /// later `basedOn` never replaces it.
    @Test func aRunCarriesItsFirstSnapshotAcrossCoalescedKeystrokes() async throws {
        try await Self.withPaneWorld(blocks: ["Base."]) { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[0])
            let coordinator = AutosaveCoordinator(runner: session.runner, sleep: { _ in throw CancellationError() })
            coordinator.record(variantID: take, text: "Base. A", charDelta: 2, basedOn: "Base.")
            coordinator.record(variantID: take, text: "Base. AB", charDelta: 1, basedOn: "Base. A")
            #expect(coordinator.pending[take]?.expectedText == "Base.")
            try Self.applyAsSyncPull(db, take, "Remote.")
            await coordinator.flushNow()
            #expect(try Self.stored(db, take) == "Base. AB")
            #expect(try Self.cards(db, block: blocks[0], besides: take).map(\.text) == ["Remote."])
        }
    }

    /// A REFUSED write never landed, so the newer run recorded while it flew
    /// (built on the refused text) inherits the OLDER snapshot: once the lock
    /// lifts, the retry writes over an untouched row with no spurious card.
    @Test func aRefusedWriteHandsItsOlderSnapshotToTheNewerRun() async throws {
        let (db, directory) = try AutosaveCoordinatorTests.poolStore()
        defer { try? FileManager.default.removeItem(at: directory) }
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 683))
        } operation: { @MainActor in
            let ops = Operations()
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "a")
            let take = made.variant.id
            try ops.lockVariant(take)   // the write in flight will refuse
            let coordinator = AutosaveCoordinator(
                runner: OperationsRunner(operations: ops), sleep: { _ in throw CancellationError() })
            let hold = WriterHold()
            hold.hold(db)
            coordinator.record(variantID: take, text: "a1", charDelta: 1, basedOn: "a")
            let flight = Task { await coordinator.flushNow() }
            try await AutosaveCoordinatorTests.waitUntil { coordinator.pending.isEmpty && coordinator.isDirty }
            // She types on while it flies — built on her refused-to-be text.
            coordinator.record(variantID: take, text: "a1 a2", charDelta: 3, basedOn: "a1")
            hold.release()
            await flight.value
            #expect(coordinator.pending[take]?.expectedText == "a",
                    "the newer run stands on the snapshot the refused text never replaced")

            try ops.unlockVariant(take)
            await coordinator.flushNow()
            #expect(try Self.stored(db, take) == "a1 a2")
            #expect(try Self.cards(db, block: made.block.id, besides: take).isEmpty,
                    "no spurious card: the row was never changed under her")
        }
    }
}
