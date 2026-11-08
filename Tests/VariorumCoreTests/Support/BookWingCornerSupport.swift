import Foundation
import GRDB
@testable import VariorumCore

/// VX-893 (the VX-912 run, batch B2 — `notes/plans/fixes/vx-912-open-source-
/// gating.md`, "## B2 record"): the shared plumbing of the three corner
/// suites (`BookWingStraggleBeltTests`, `BookWingAnchorRankConvergenceTests`,
/// `BookWingSizedCornerCoverageTests`) — `BookWingConvergenceTests`' own
/// helpers, namespaced so no file-scope name collides.
enum BookWingCorner {
    /// The straggle belt's one-shot deferral marker (LOCAL-ONLY `sync_state`).
    static let deferralKey = "book_wing_mend_deferred"

    static func wingOf(_ client: SyncClient, post postID: String) throws -> String? {
        try client.db.fetchString("SELECT wing_id FROM container WHERE id = ?", [postID])
    }

    static func isLiveMember(_ client: SyncClient, _ postID: String, of bookID: String) throws -> Bool {
        try client.db.fetchInt(
            """
            SELECT COUNT(*) FROM reading_post
            WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL AND status = 'member'
            """, [bookID, postID]) == 1
    }

    static func membershipID(_ client: SyncClient, _ postID: String, in bookID: String) throws -> String? {
        try client.db.fetchString(
            "SELECT id FROM reading_post WHERE reading_id = ? AND post_id = ? ORDER BY id LIMIT 1",
            [bookID, postID])
    }

    /// A membership row's (status, provenance, dead?).
    static func row(
        _ client: SyncClient, _ id: String
    ) throws -> (status: String, provenance: String?, dead: Bool)? {
        try client.db.read { db in
            try Row.fetchOne(
                db, sql: "SELECT status, arrival_provenance, deleted_at FROM reading_post WHERE id = ?",
                arguments: [id]
            ).map { ($0["status"], $0["arrival_provenance"], ($0["deleted_at"] as String?) != nil) }
        }
    }

    /// The deferral marker as this device holds it — `postID → the note's
    /// stored wing when the mend deferred` — or nil when none is armed.
    static func deferrals(_ client: SyncClient) throws -> [String: String]? {
        guard let json = try client.db.fetchString(
            "SELECT value FROM sync_state WHERE key = ?", [deferralKey]) else { return nil }
        return try JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: String]
    }

    static func knownSeq(_ client: SyncClient, membership id: String) throws -> Int? {
        try client.db.fetchInt(
            "SELECT server_seq FROM sync_row_seq WHERE table_name = 'reading_post' AND row_id = ?", [id])
    }

    /// A wing-mend demotion's stamp: kind `wing_mend`, an `at`, no client.
    static func isWingMendDemotion(_ json: String?) -> Bool {
        guard let provenance = ArrivalProvenance.decode(json) else { return false }
        return provenance.knownKind == .wingMend && provenance.client == nil && provenance.at != nil
    }

    /// Push, step the server clock past the A5 band, pull — until every
    /// device is clean and at the head (a band of 0 is the plain harness).
    static func settle(
        _ clients: [SyncClient], server: FakeSyncServer, band: Int64 = 0, maxRounds: Int = 12
    ) async throws {
        for _ in 1...maxRounds {
            for client in clients { try await client.push() }
            await server.advanceClock(by: band + 1)
            for client in clients { try await client.pull() }
            let head = await server.headSeq
            let quiet = try clients.allSatisfy { client in
                try client.outboxCount() == 0
                    && client.db.fetchString(
                        "SELECT value FROM sync_state WHERE key = 'last_server_seq'") == String(head)
            }
            if quiet { return }
        }
        throw SyncHarnessError.neverQuiesced(maxRounds: maxRounds)
    }

    /// A device files a fresh note into `bookID` — the book as it sees it.
    static func fileOffline(
        _ client: SyncClient, into bookID: String, title: String = "filed offline"
    ) throws -> String {
        try client.with { ops, _ in
            let note = try ops.createPost(title: title, profile: .generic)
            _ = try ops.addPostToReading(note.id, to: bookID)
            return note.id
        }
    }
}
