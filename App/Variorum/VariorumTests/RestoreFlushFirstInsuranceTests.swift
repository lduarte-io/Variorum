//
//  RestoreFlushFirstInsuranceTests.swift
//  VariorumTests
//
//  P-849-1 (PROVISIONAL — the VX-849 run, batch 3, piece 3; the record
//  `notes/plans/fixes/vx-849-typed-over-rescue.md`): HER OWN restore doors
//  flush her pending typing FIRST, keep ONE quiet `kind='auto'` savepoint of the
//  words the restore is about to replace, then act — and the ring-end (VX-664)
//  makes a live pane adopt the restored words. A deliberate act of hers then
//  never meets a stale buffer and never mints a `'conflict'` card (R-683-2's
//  premise), and nothing she typed since her last savepoint becomes
//  unreachable (OverallModel §3's insurance doctrine: insure what an act is
//  about to make unreachable — the MCP bracket is the precedent).
//
//  The doors: the History & Lineage surface's Commits face Restore
//  (`CommitsFaceModel.restore` — the Mac's one production restore door; it
//  already flushed, honestly since VX-402, and kept no savepoint), and the
//  board's own `TakesViewModel.restoreCommit` (no production caller today; it
//  ran on the bare runner with no flush, so a restore under her pending typing
//  was answered by her own late autosave rescuing the RESTORED words as a card).
//
//  RED ON OLD — both pins drive only pre-fix API, so on the pre-fix tree they
//  fail for the behavioral reasons named in each.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("P-849-1 — her restore doors flush first and insure what they replace", .serialized)
struct RestoreFlushFirstInsuranceTests {
    private static let first = "The first block, as she left it."
    private static let moment = "The paragraph as she saved it."

    private static func withWorld(
        _ body: @MainActor (AppSession, AppDatabase, String, [String]) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 8491))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the note she restores in")
            var blocks: [String] = []
            for text in [Self.first, Self.moment] {
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

    private static func stored(_ db: AppDatabase, _ variantID: String) throws -> String? {
        try db.read { try Variant.fetchOne($0, key: variantID)?.workingText }
    }

    private static func quietSavepoints(_ db: AppDatabase, _ variantID: String) throws -> [CommitPoint] {
        try db.read { db in
            try CommitPoint
                .filter(Column("variant_id") == variantID && Column("kind") == CommitKind.auto.rawValue)
                .order(Column("created_at"), Column("id"))
                .fetchAll(db)
        }
    }

    private static func cards(_ db: AppDatabase, block: String, besides take: String) throws -> [String] {
        try db.read { db in
            try String.fetchAll(
                db,
                sql: """
                SELECT working_text FROM variant
                WHERE block_id = ? AND id != ? AND deleted_at IS NULL ORDER BY fan_position
                """,
                arguments: [block, take])
        }
    }

    private static func takesModel(_ session: AppSession, _ postID: String) throws -> TakesViewModel {
        let suite = "RestoreFlushFirstInsuranceTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return TakesViewModel(session: session, postID: postID, defaults: defaults)
    }

    private static func eventually(
        timeout: TimeInterval = 2, _ predicate: @MainActor () -> Bool
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while !predicate(), Date() < deadline {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
        }
        return predicate()
    }

    /// **RED ON OLD — THE COMMITS FACE'S RESTORE, with her typing pending in the
    /// take's live Takes pane.** The face flushed her typing first (it always
    /// did) and then restored the moment over it — keeping NO savepoint, so the
    /// words she typed since the moment survived nowhere (never committed; the
    /// restore overwrote the row). Now one quiet savepoint holds them, the row
    /// holds the moment, no card is minted, and her ring ends on the restored
    /// words (VX-664).
    @Test func theCommitsFaceKeepsWhatHerRestoreReplacesInAQuietSavepoint() async throws {
        try await Self.withWorld { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let commit = try session.operations.commit(take)
            let model = try Self.takesModel(session, postID)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID, blockID: blocks[1], variantID: take))
            let typed = Self.moment + " Typed since the moment, then she restored."
            model.paneEdited(variantID: take, newText: typed)
            #expect(model.autosave.isDirty, "fixture: her typing sits in the debounce")

            let history = CommitsFaceModel(session: session, request: BlockHistoryRequest(
                postID: postID, blockID: blocks[1], focusedVariantID: take))
            await history.restore(commit, of: take)

            #expect(try Self.stored(db, take) == Self.moment, "the moment is the take's text")
            #expect(try Self.quietSavepoints(db, take).map(\.text) == [typed],
                    "RED ON OLD: the words she typed since the moment survived nowhere")
            #expect(try Self.quietSavepoints(db, take).first?.message == nil,
                    "her road's quiet kind — unnamed (the wire's bracket names its own)")
            #expect(try Self.cards(db, block: blocks[1], besides: take).isEmpty,
                    "a deliberate act of hers never mints a 'conflict' card (R-683-2)")
            model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
            #expect(await Self.eventually { model.focusedPane == nil },
                    "the ring ends on the restored words (VX-664)")
        }
    }

    /// **RED ON OLD — THE BOARD'S OWN RESTORE DOOR, with her typing pending.**
    /// It ran on the bare runner: the restore landed, then her pending autosave
    /// (built on the pre-restore text) found the row changed and RESCUED — her
    /// typing kept the row and the restored words became a `'conflict'` card: her
    /// own act undone by her own keystrokes, a card she never asked for. Now it
    /// flushes first, insures, then restores.
    @Test func theBoardsRestoreDoorFlushesHerTypingFirstAndMintsNoCard() async throws {
        try await Self.withWorld { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let commit = try session.operations.commit(take)
            let since = Self.moment + " Changed since."
            try session.operations.autosave(take, text: since, charDelta: 15)
            let model = try Self.takesModel(session, postID)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID, blockID: blocks[1], variantID: take))
            let typed = since + " And typed on."
            model.paneEdited(variantID: take, newText: typed)

            await model.restoreCommit(commit)
            #expect(await model.flushPendingText(), "whatever was still pending lands")

            #expect(try Self.stored(db, take) == Self.moment,
                    "RED ON OLD: her late autosave landed over the restore")
            #expect(try Self.cards(db, block: blocks[1], besides: take).isEmpty,
                    "RED ON OLD: the restored words became a 'conflict' card — her own act minted one")
            #expect(try Self.quietSavepoints(db, take).map(\.text) == [typed],
                    "the words the restore replaced, kept quietly")
        }
    }

    /// GUARD — a restore whose replaced words her last savepoint already holds
    /// mints no insurance (deduped — the insurance family's one rule), and a
    /// restore with nothing typed since behaves exactly as before.
    @Test func aRestoreOverWordsHerLastSavepointHoldsMintsNoInsurance() async throws {
        try await Self.withWorld { session, db, postID, blocks in
            let take = try Self.chosen(db, postID, blocks[1])
            let moment = try session.operations.commit(take)
            let since = Self.moment + " Saved again."
            try session.operations.autosave(take, text: since, charDelta: 12)
            _ = try session.operations.commit(take)
            let history = CommitsFaceModel(session: session, request: BlockHistoryRequest(
                postID: postID, blockID: blocks[1], focusedVariantID: take))
            await history.restore(moment, of: take)
            #expect(try Self.stored(db, take) == Self.moment)
            #expect(try Self.quietSavepoints(db, take).isEmpty, "her last savepoint already holds them")
        }
    }
}
