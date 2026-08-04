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
    /// The server-side canonical user (`user_settings.local_user_id`) the
    /// harness seeds — one of the Fragments agents' confirmed test-vector
    /// users, lowercased UUID text per their convention.
    let canonicalUserID: String

    /// The deterministic id both apps derive for a day (the REAL namespace,
    /// the server's canonical user — the join key's whole trick).
    func entryID(day: String) -> String {
        FragmentsContract.entryID(
            namespace: config.idNamespace,
            canonicalUser: canonicalUserID, dayKey: day)!
    }

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

    /// The Fragments server's live body for a day (nil = absent/
    /// tombstoned), OPENED (Phase 14b: the bridge pushes `e1:` ciphertext;
    /// assertions compare words — the wire form has its own pins in
    /// `BridgeEncryptionTests`). Legacy plaintext (a pre-E2EE
    /// `fragmentsAppWrites` seed) returns verbatim, same as the landing's
    /// own rule.
    func fragmentsBody(day: String) async throws -> String? {
        try BridgeTestKeys.opened(
            await server.liveEntry(userID: config.userID, date: day)?.body, day: day)
    }

    /// The RAW wire body (ciphertext included) — for the pins that assert
    /// the mirror never holds her words.
    func fragmentsWireBody(day: String) async -> String? {
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
    localUserID: String? = "9f1c2b3a-4d5e-6f70-8192-a3b4c5d6e7f8",
    _ body: (BridgeHarness) async throws -> Void
) async throws {
    try await withOperationsAsync(seed: seed) { ops, db in
        // The REAL namespace (confirmed 2026-07-09) and a confirmed
        // test-vector canonical user; `localUserID: nil` models the
        // account-not-yet-synced state (the fail-closed gate).
        let config = FragmentsBridgeConfiguration(userID: "user-author")
        let server = FakeFragmentsServer(
            visibilityHorizon: visibilityHorizon, localUserID: localUserID)
        // Phase 14b: the fixed journal-key world — every bridge suite runs
        // over ciphertext (the engine's default provider refuses, which is
        // the designed pause; pinned separately in BridgeEncryptionTests).
        let engine = BridgeEngine(
            transport: server, configuration: config,
            keyProvider: FixedBridgeKeyProvider())
        try await body(BridgeHarness(
            ops: ops, db: db, server: server, engine: engine, config: config,
            canonicalUserID: localUserID ?? "9f1c2b3a-4d5e-6f70-8192-a3b4c5d6e7f8"))
    }
}
