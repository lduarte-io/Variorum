import Dependencies
import Foundation
import GRDB
@testable import VariorumCore

/// The Phase 9b bridge world: the deterministic `withOperationsAsync`
/// dependencies (ticking clock, incrementing UUIDs) + a fake Fragments
/// server + an engine wired to it. Every suite drives BOTH surfaces the way
/// the real world does — Variorum through Operations, Fragments through the
/// fake server's push door — and the engine's rounds in between.
struct BridgeHarness {
    let ops: Operations
    let db: AppDatabase
    let server: FakeFragmentsServer
    let engine: BridgeEngine
    let config: FragmentsBridgeConfiguration

    // MARK: Variorum-side conveniences

    /// A journal entry with one block holding `text` (the common shape).
    @discardableResult
    func makeEntry(day: String, text: String) throws -> (container: Container, variantID: String) {
        let entry = try ops.createOrOpenJournalEntry(entryDate: day).container
        let minted = try ops.newBlock(in: entry.id, text: text, at: .end)
        return (entry, minted.variant.id)
    }

    /// The rendered text of the day's canonical entry (the shared query).
    func rendered(day: String) throws -> String? {
        try db.read { db in
            guard let entry = try Queries.canonicalJournalEntry(db, day: day)
            else { return nil }
            return try Queries.renderedText(db, containerID: entry.id)
        }
    }

    func commitTexts(variantID: String) throws -> [String] {
        try db.read { db in
            try String.fetchAll(
                db,
                sql: "SELECT text FROM commit_point WHERE variant_id = ? ORDER BY created_at, id",
                arguments: [variantID])
        }
    }

    /// Live variants (text, label) on the entry's blocks, fan order.
    func liveVariants(blockID: String) throws -> [(text: String, label: String?)] {
        try db.read { db in
            try Row.fetchAll(
                db,
                sql: """
                    SELECT working_text, label FROM variant
                    WHERE block_id = ? AND deleted_at IS NULL
                    ORDER BY fan_position, id
                    """,
                arguments: [blockID])
                .map { ($0["working_text"], $0["label"]) }
        }
    }

    func firstBlockID(day: String) throws -> String? {
        try db.read { db in
            try String.fetchOne(
                db,
                sql: """
                    SELECT cb.block_id FROM container_block cb
                    JOIN container c ON c.id = cb.container_id
                    WHERE c.profile = 'journal' AND c.entry_date = ?
                      AND c.deleted_at IS NULL AND cb.deleted_at IS NULL
                    ORDER BY cb.position, cb.id LIMIT 1
                    """,
                arguments: [day])
        }
    }

    func dayState(_ day: String) throws -> String? {
        try db.read { try BridgeEngine.dayState($0, dayKey: day) }
    }

    // MARK: Fragments-side conveniences

    /// The Fragments server's live body for a day (nil = absent/tombstoned).
    func fragmentsBody(day: String) async -> String? {
        await server.liveEntry(userID: config.userID, date: day)?.body
    }

    /// A strictly-later-than-everything stamp for Fragments-app writes: the
    /// deterministic clock starts 2026-07-01 and ticks seconds, so 2027
    /// stamps always win LWW when tests want the Fragments side newer.
    func fragmentsStamp(_ offset: Int) -> String {
        String(format: "2027-01-01T00:00:%02d.000Z", offset)
    }
}

func withBridge(
    seed: UInt64 = 1,
    visibilityHorizon: Int64 = 0,
    _ body: (BridgeHarness) async throws -> Void
) async throws {
    try await withOperationsAsync(seed: seed) { ops, db in
        let config = FragmentsBridgeConfiguration(
            idNamespace: UUID(uuidString: "6ba7b811-9dad-11d1-80b4-00c04fd430c8")!,
            canonicalUserKey: "author",
            userID: "user-author")
        let server = FakeFragmentsServer(visibilityHorizon: visibilityHorizon)
        let engine = BridgeEngine(transport: server, configuration: config)
        try await body(BridgeHarness(
            ops: ops, db: db, server: server, engine: engine, config: config))
    }
}
