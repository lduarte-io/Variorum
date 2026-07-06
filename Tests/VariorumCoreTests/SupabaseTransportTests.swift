import Foundation
import Testing
@testable import VariorumCore

/// Wire-shape pinning for the Supabase transport — NO network: the real
/// integration pass is the Phase 5 author-assist gate. These tests keep the
/// Swift DTOs byte-aligned with the shapes documented in
/// `Server/supabase/02_sync_rpc.sql`, so drift on either side fails here
/// before it fails against the author's project.
@Suite("Supabase transport wire shapes (Phase 5, Step 8 — no network)")
struct SupabaseTransportTests {
    @Test func pushItemEncodesTheDocumentedShape() throws {
        let row = SyncRow(
            table: "variant", rowID: "v1",
            columns: [
                "id": .text("v1"), "block_id": .text("b1"),
                "working_text": .text("hello"), "locked": .integer(0),
                "deleted_at": .null,
            ],
            syncVersion: 3)
        let data = try JSONEncoder().encode(PushItem(row: row))
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json?["table"] as? String == "variant")
        #expect(json?["row_id"] as? String == "v1")
        #expect(json?["base_version"] as? Int == 3)
        let columns = json?["columns"] as? [String: Any]
        #expect(columns?["working_text"] as? String == "hello")
        #expect(columns?["locked"] as? Int == 0)
        #expect(columns?["deleted_at"] is NSNull)
        #expect(columns?["sync_version"] == nil, "sync_version rides as base_version, never a column")
    }

    @Test func pushResultsDecodeToOutcomes() throws {
        let accepted = """
            {"status": "accepted", "new_version": 4, "server_seq": 99}
            """.data(using: .utf8)!
        let outcome = try JSONDecoder().decode(PushResult.self, from: accepted).outcome()
        #expect(outcome == .accepted(newVersion: 4, serverSeq: 99))

        let rejected = """
            {"status": "rejected", "current": {"table": "container", "row_id": "c1",
             "sync_version": 2, "server_seq": 41,
             "columns": {"id": "c1", "title": "server truth", "locked": 0}}}
            """.data(using: .utf8)!
        let rejectedOutcome = try JSONDecoder().decode(PushResult.self, from: rejected).outcome()
        guard case .rejected(let current) = rejectedOutcome, let current else {
            Issue.record("reject with current row decoded wrong"); return
        }
        #expect(current.serverSeq == 41)
        #expect(current.row.syncVersion == 2)
        #expect(current.row.columns["title"] == .text("server truth"))
        #expect(current.row.columns["locked"] == .integer(0))

        let rejectedNil = """
            {"status": "rejected", "current": null}
            """.data(using: .utf8)!
        #expect(try JSONDecoder().decode(PushResult.self, from: rejectedNil).outcome()
                == .rejected(current: nil))

        let unknown = """
            {"status": "partial"}
            """.data(using: .utf8)!
        #expect(throws: SupabaseTransportError.malformedResult("unknown status 'partial'")) {
            _ = try JSONDecoder().decode(PushResult.self, from: unknown).outcome()
        }
    }

    @Test func pulledItemsDecodeToPulledRows() throws {
        let data = """
            [{"table": "setting", "row_id": "idle_commit_hours",
              "sync_version": 5, "server_seq": 12,
              "columns": {"key": "idle_commit_hours", "value": "24"}}]
            """.data(using: .utf8)!
        let items = try JSONDecoder().decode([PulledItem].self, from: data).map(\.pulledRow)
        #expect(items.count == 1)
        #expect(items[0].serverSeq == 12)
        #expect(items[0].row.table == "setting")
        #expect(items[0].row.rowID == "idle_commit_hours")
        #expect(items[0].row.syncVersion == 5)
        #expect(items[0].row.columns["value"] == .text("24"))
    }

    @Test func pullRequestEncodesSnakeCaseParameters() throws {
        let data = try JSONEncoder().encode(PullRequest(sinceSeq: 42, maxRows: 500))
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json?["since_seq"] as? Int == 42)
        #expect(json?["max_rows"] as? Int == 500)
    }

    /// The mirror DDL must track the registry: every synced table appears in
    /// both .sql files' table lists, and the local-only tables in neither.
    /// (String-level pinning — the real schema check is the author-assisted
    /// integration pass.)
    @Test func serverSQLFilesCoverExactlyTheRegistry() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // Tests/VariorumCoreTests
            .deletingLastPathComponent()  // Tests
            .deletingLastPathComponent()  // repo root
            .appendingPathComponent("Server/supabase")
        let schema = try strippingComments(String(
            contentsOf: root.appendingPathComponent("01_mirror_schema.sql"), encoding: .utf8))
        let rpc = try strippingComments(String(
            contentsOf: root.appendingPathComponent("02_sync_rpc.sql"), encoding: .utf8))

        for table in SyncSchema.tables {
            #expect(schema.contains("create table \(table.name) ("),
                    "mirror DDL missing \(table.name)")
            #expect(rpc.contains("'\(table.name)'"), "RPC allowlist missing \(table.name)")
        }
        for local in SyncSchema.localOnlyTables {
            #expect(!schema.contains("create table \(local) "),
                    "\(local) is local-only and must not be mirrored")
        }
        #expect(!schema.contains("file_bookmark"),
                "file_bookmark is local-only (AppSpec §7) and must not be mirrored")
        #expect(!schema.lowercased().contains("references "),
                "mirrors carry NO foreign keys (SyncSpec §2 — load-bearing)")
        #expect(!schema.lowercased().contains("unique"),
                "mirrors carry NO uniqueness beyond the PK (SyncSpec §2)")
    }

    /// The SQL pins target code, not prose: drop `--` comment lines.
    private func strippingComments(_ sql: String) -> String {
        sql.split(separator: "\n", omittingEmptySubsequences: false)
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("--") }
            .joined(separator: "\n")
    }
}
