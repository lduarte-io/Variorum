import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-198 — R-VX184-5, THE NEWEST COPIED SETUP WINS (her pre-run sitting,
// 2026-10-12: "the whole path where you have to deny it and then reset it is
// a bit annoying and cumbersome even for my beta testers"; the run record
// `notes/plans/fixes/vx-184-mcp-launch-polish.md`, U1 — "VX-198"). A key minted
// by a Copy setup command RE-BINDS a bound name on its first presentation,
// approval and grants kept; the key it replaced then refuses (its own reason
// in her Activity list, its own sentence on the wire); an unissued key, a
// bare connection and another name's key refuse as before. These pins read
// only the pre-fix API (`decision.admits`, the rows, the log's act strings),
// so they COMPILE on the pre-fix tree, where they were watched RED.

@Suite("VX-198 — the newest copied setup re-binds the name")
struct MCPSetupKeyRebindTests {
    private func boundHash(_ db: AppDatabase, _ name: String) throws -> String? {
        try db.read { db in
            try String.fetchOne(db, sql: "SELECT setup_key_hash FROM mcp_client WHERE name = ?", arguments: [name])
        }
    }

    private func log(_ db: AppDatabase) throws -> [String] {
        try db.read { db in
            try Row.fetchAll(db, sql: "SELECT client_name, act, outcome FROM mcp_activity ORDER BY id")
                .map { "\($0["client_name"] as String) \($0["act"] as String) \($0["outcome"] as String)" }
        }
    }

    @Test func aFreshCopyRebindsABoundNameKeepingItsApprovalAndGrants() throws {
        try withOperations { ops, db in
            let first = try ops.mintMCPSetupKey()
            let client = try #require(
                try ops.admitMCPConnection(name: "claude-code", version: "2.1", presentedKey: first).client)
            let book = try ops.createReading(name: "drafts", kind: .book)
            try ops.approveMCPClient(
                client.id, granting: .init(rung: .read, scopeKind: .book, scopeID: book.id, duration: .always))

            // VX-258 (A JUSTIFIED EDIT, the ritual — her ruling: a key re-binds with zero clicks only the name its setup was copied FOR): her
            // second copy is from Claude Code's own tab.
            let rerun = try ops.mintMCPSetupKey(copiedFor: "claude-code")   // she copies the setup again and runs it
            let rebound = try ops.admitMCPConnection(name: "claude-code", version: "2.2", presentedKey: rerun)
            #expect(rebound.decision.admits, "the newest copied setup is admitted, no Deny needed")
            #expect(rebound.client?.id == client.id && rebound.client?.state == .approved,
                    "the same client, its approval kept")
            #expect(rebound.client?.version == "2.2", "an admitted connection refreshes the declared version")
            #expect(try boundHash(db, "claude-code") == MCPSetupKeyRule.hash(rerun), "the name carries the newer key")
            #expect(try db.read { try Queries.mcpGrants($0, clientID: client.id) }.count == 1, "her grants kept")
            #expect(try db.read { try Queries.mcpUnclaimedSetupKeyCount($0) } == 0, "the copy is claimed, not pending")

            // The key it replaced refuses — and so does every road but the newest.
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: first).decision.admits
                    == false, "the replaced key")
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: "vmk1_neverminted")
                .decision.admits == false, "a key never minted here")
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: nil).decision.admits
                    == false, "no key")
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: rerun).decision.admits,
                    "the newest key keeps admitting")
            #expect(try log(db) == [
                "claude-code connect_rebound allowed",
                "claude-code connect_replaced_key refused",
                "claude-code connect_not_this_names_key refused",
                "claude-code connect_bare refused",
            ])
        }
    }

    /// Only a FRESH key re-binds: a key already bound to ANOTHER name stays an
    /// impostor's under a bound name, and a refused presentation claims
    /// nothing. The replaced key's reason is remembered for ITS name only —
    /// under any other name it is a key this library doesn't hold.
    @Test func onlyAFreshKeyRebindsAndTheReplacedReasonBelongsToItsName() throws {
        try withOperations { ops, db in
            let codexKey = try ops.mintMCPSetupKey()
            _ = try ops.admitMCPConnection(name: "codex", version: nil, presentedKey: codexKey)
            let first = try ops.mintMCPSetupKey()
            _ = try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: first)

            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: codexKey)
                .decision.admits == false, "another name's key never re-binds")
            #expect(try boundHash(db, "claude-code") == MCPSetupKeyRule.hash(first), "untouched by the refusal")
            #expect(try boundHash(db, "codex") == MCPSetupKeyRule.hash(codexKey))

            let rerun = try ops.mintMCPSetupKey()
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: rerun).decision.admits)
            _ = try ops.admitMCPConnection(name: "a-stranger", version: nil, presentedKey: first)
            #expect(try log(db) == [
                "claude-code connect_not_this_names_key refused",
                "claude-code connect_rebound allowed",
                "a-stranger connect_not_issued refused",
            ])
        }
    }
}
